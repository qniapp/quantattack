require("engine/core/class")

local quantum_gate = new_class()

-------------------------------------------------------------------------------
-- class constants
-------------------------------------------------------------------------------

quantum_gate.size = 8

-- private

quantum_gate._num_frames_swap = 2
quantum_gate._num_frames_match = 45
quantum_gate._dy = 3 -- ゲートの落下速度
quantum_gate._state_swapping_with_left = "swapping_with_left"
quantum_gate._state_swapping_with_right = "swapping_with_right"
quantum_gate._state_swap_finished = "swap_finished"

function quantum_gate:_init(type, span)
  self._type = type
  self.span = span or 1
  self._state = "idle"
  self._distance_dropped = 0 -- ゲートが落下した距離
end

-- gate type

function quantum_gate:is_i()
  return self._type == "i"
end

function quantum_gate:is_h()
  return self._type == "h"
end

function quantum_gate:is_x()
  return self._type == "x"
end

function quantum_gate:is_y()
  return self._type == "y"
end

function quantum_gate:is_z()
  return self._type == "z"
end

function quantum_gate:is_s()
  return self._type == "s"
end

function quantum_gate:is_t()
  return self._type == "t"
end

function quantum_gate:is_swap()
  return self._type == "swap"
end

function quantum_gate:is_control()
  return self._type == "control"
end

function quantum_gate:is_cnot_x()
  return self._type == "cnot_x"
end

function quantum_gate:is_garbage()
  return self._type == "g"
end

function quantum_gate:is_placeholder()
  return self._type == "?"
end

-- gate state

function quantum_gate:is_idle()
  return self._state == "idle"
end

function quantum_gate:is_empty()
  return self:is_i() or self:is_dropping()
end

function quantum_gate:is_busy()
  return not (self:is_i() or self:is_idle() or self:is_dropped())
end

function quantum_gate:is_match()
  return self._state == "match"
end

function quantum_gate:is_reducible()
  return self:is_garbage() or (not self:is_busy())
end

function quantum_gate:update(board)
  if self:is_placeholder() then
    return
  end

  if self:is_idle() then
    self.puff = false
  elseif self:is_swapping() then
    if self.tick_swap < quantum_gate._num_frames_swap then
      self.tick_swap = self.tick_swap + 1
    else
      self._state = quantum_gate._state_swap_finished
    end
  elseif self:is_swap_finished() then
    self._state = "idle"
  elseif self:is_dropping() then
    local screen_y = board:screen_y(self.start_y) + self._distance_dropped
    local next_screen_y = screen_y + quantum_gate._dy
    local next_y = board:y(next_screen_y)

    if next_y <= board.rows and board:gate_at(self.x, next_y):is_empty() then
      self._distance_dropped = self._distance_dropped + quantum_gate._dy
    else
      self._distance_dropped = 0
      self.y = board:y(screen_y)
      self._state = "dropped"
    end
  elseif self:is_dropped() then
    self._distance_dropped = 0
    self._state = "idle"
  elseif self:is_match() then
    if self.tick_match == nil then
      self.tick_match = 0
    elseif self.tick_match < quantum_gate._num_frames_match then
      self.tick_match = self.tick_match + 1
    else
      self.tick_match = nil
      self._type = self.reduce_to._type
      self.sprites = self.reduce_to.sprites
      self._state = "idle"
      if self:is_i() then
        self.puff = true
      end
    end
  end
end

function quantum_gate:render(screen_x, screen_y)
  if self:is_i() then
    return
  end
  if self:is_placeholder() then
    return
  end

  local dx = 0
  if self:_is_swapping_with_right() then
    dx = self.tick_swap * (quantum_gate.size / quantum_gate._num_frames_swap)
  elseif self:_is_swapping_with_left() then
    dx = -self.tick_swap * (quantum_gate.size / quantum_gate._num_frames_swap)
  end

  local dy = 0
  if self:is_dropping() then
    dy = self._distance_dropped
  end

  spr(self:_sprite(), screen_x + dx, screen_y + dy)
end

function quantum_gate:_sprite()
  --#if assert
  assert(self.sprites, self._type)
  assert(self.sprites[self._state], self._state)
  --#endif

  if self:is_match() then
    local mod = self.tick_match % 12
    local sub_state
    if mod <= 2 then
      sub_state = 'up'
    elseif mod <= 5 then
      sub_state = 'middle'
    elseif mod <= 8 then
      sub_state = 'down'
    elseif mod <= 11 then
      sub_state = 'middle'
    end
    return self.sprites[self._state][sub_state]
  else
    return self.sprites[self._state]
  end
end

function quantum_gate:replace_with(other)
  self.reduce_to = other
  self._state = "match"
end

-------------------------------------------------------------------------------
-- drop
-------------------------------------------------------------------------------

function quantum_gate:is_droppable()
  return not (self:is_i() or self:is_dropping() or self:is_swapping())
end

function quantum_gate:drop(x, start_y)
  --#if assert
  assert(1 <= x)
  assert(x <= 6) -- todo: board の定数を持ってくる
  assert(1 <= start_y)
  assert(start_y <= 12) -- todo: board の定数を持ってくる
  --#endif

  self.x = x
  self._distance_dropped = 0
  self.start_y = start_y
  self._state = "dropping"
end

function quantum_gate:is_dropping()
  return self._state == "dropping"
end

function quantum_gate:is_dropped()
  return self._state == "dropped"
end

-------------------------------------------------------------------------------
-- swap
-------------------------------------------------------------------------------

function quantum_gate:is_swappable()
  return self:is_idle() or self:is_swap_finished()
end

function quantum_gate:is_swapping()
  return self:_is_swapping_with_right() or self:_is_swapping_with_left()
end

function quantum_gate:is_swap_finished()
  return self._state == quantum_gate._state_swap_finished
end

function quantum_gate:swap_with_right(new_x)
  --#if assert
  assert(2 <= new_x)
  --#endif

  self.tick_swap = 0
  self.new_x_after_swap = new_x
  self._state = quantum_gate._state_swapping_with_right
end

function quantum_gate:swap_with_left(new_x)
  --#if assert
  assert(1 <= new_x)
  --#endif

  self.tick_swap = 0
  self.new_x_after_swap = new_x
  self._state = quantum_gate._state_swapping_with_left
end

-- debug

--#if debug
function quantum_gate:_tostring()
  if self:is_idle() then
    return self._type
  else
    return self._type .. " (" .. self._state .. ")"
  end
end

--#endif

-- private

function quantum_gate:_is_swapping_with_right()
  return self._state == quantum_gate._state_swapping_with_right
end

function quantum_gate:_is_swapping_with_left()
  return self._state == quantum_gate._state_swapping_with_left
end

return quantum_gate
