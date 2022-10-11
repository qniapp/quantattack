require("engine/core/class")

local quantum_gate = new_class()

-------------------------------------------------------------------------------
-- class constants
-------------------------------------------------------------------------------

quantum_gate.size = 8

-- private

local swap_animation_frame_count = 4
local match_animation_frame_count = 45

local state_idle = "idle"
local state_dropping = "dropping"
local state_match = "match"
local state_swapping_with_left = "swapping_with_left"
local state_swapping_with_right = "swapping_with_right"

quantum_gate._dy = 3 -- ゲートの落下速度

function quantum_gate:_init(type, span)
  self._type = type
  self.span = span or 1
  self._state = state_idle
end

-- gate type

-- I ゲートである場合 true を返す
function quantum_gate:is_i()
  return self._type == "i"
end

-- H ゲートである場合 true を返す
function quantum_gate:is_h()
  return self._type == "h"
end

-- X ゲートである場合 true を返す
function quantum_gate:is_x()
  return self._type == "x"
end

-- Y ゲートである場合 true を返す
function quantum_gate:is_y()
  return self._type == "y"
end

-- Z ゲートである場合 true を返す
function quantum_gate:is_z()
  return self._type == "z"
end

-- S ゲートである場合 true を返す
function quantum_gate:is_s()
  return self._type == "s"
end

-- T ゲートである場合 true を返す
function quantum_gate:is_t()
  return self._type == "t"
end

-- SWAP ゲートである場合 true を返す
function quantum_gate:is_swap()
  return self._type == "swap"
end

-- Control ゲートである場合 true を返す
function quantum_gate:is_control()
  return self._type == "control"
end

-- CNOT ゲート内の X ゲートである場合 true を返す
function quantum_gate:is_cnot_x()
  return self._type == "cnot_x"
end

-- おじゃまゲートの先頭 (左端) である場合 true を返す
function quantum_gate:is_garbage()
  return self._type == "g"
end

-- gate state

-- ゲートが idle である場合 true を返す
function quantum_gate:is_idle()
  return self._state == state_idle
end

-- 他のゲートが通過 (ドロップ) できる場合 true を返す
function quantum_gate:is_empty()
  return (self:is_i() and not self:is_swapping()) or
      self:is_dropping()
end

-- マッチ状態である場合 true を返す
function quantum_gate:is_match()
  return self._state == state_match
end

-- マッチできる場合 true を返す
function quantum_gate:is_reducible()
  return (not self:is_i()) and self:is_idle() or self:is_garbage()
end

function quantum_gate:update(board, x, y)
  if self:is_idle() then
    self.puff = false
  elseif self:is_swapping() then
    --#if assert
    assert(not self:is_garbage())
    --#endif

    if self._tick_swap < swap_animation_frame_count then
      self._tick_swap = self._tick_swap + 1
    else
      local new_x

      -- SWAP 完了
      if self:_is_swapping_with_left() then
        new_x = x - 1
      else
        new_x = x + 1
      end

      if self:is_swap() then
        board:gate_at(self.other_x, y).other_x = new_x
      end

      local gate_to_swap_with = board:gate_at(new_x, y)
      if not gate_to_swap_with:is_swap() then
        board:put(new_x, y, self)
        board:put(x, y, gate_to_swap_with)
        gate_to_swap_with._state = state_idle
      end

      self._state = state_idle
    end
  elseif self:is_dropping() then
    local screen_y = board:screen_y(self.start_y) + self._distance_dropped
    local next_screen_y = screen_y + quantum_gate._dy
    local next_y = board:y(next_screen_y)
    local max_next_y = board.raised_dots > 0 and board.row_next_gates or board.rows

    if self.start_y == next_y or
      (board:is_gate_droppable(x, y, next_y) and next_y <= max_next_y) then
      self._distance_dropped = self._distance_dropped + quantum_gate._dy
    else
      self._distance_dropped = 0
      self.y = board:y(screen_y)

      board:remove_gate(x, y)
      board:put(x, board:y(screen_y), self)

      self._state = state_idle
    end
  elseif self:is_match() then
    --#if assert
    assert(not self:is_garbage())
    --#endif

    if self.tick_match == nil then
      self.tick_match = 0
    elseif self.tick_match < match_animation_frame_count then
      self.tick_match = self.tick_match + 1
    else
      self.tick_match = nil
      self._type = self.reduce_to._type
      self.sprites = self.reduce_to.sprites
      self._state = state_idle
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

  local dy = 0
  if self:is_dropping() then
    dy = self._distance_dropped
  end

  if self.span > 1 then
    for x = 0, self.span - 1 do
      local sprite_id = self._sprite_middle
      if (x == 0) then -- 左端
        sprite_id = self._sprite_left
      end
      if (x == self.span - 1) then -- 右端
        sprite_id = self._sprite_right
      end

      spr(sprite_id, screen_x + x * quantum_gate.size, screen_y + dy)
    end
  else
    local dx = 0
    if self:_is_swapping_with_right() then
      dx = self._tick_swap * (quantum_gate.size / swap_animation_frame_count)
    elseif self:_is_swapping_with_left() then
      dx = -self._tick_swap * (quantum_gate.size / swap_animation_frame_count)
    end

    spr(self:_sprite(), screen_x + dx, screen_y + dy)
  end
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
  self._state = state_match
end

-------------------------------------------------------------------------------
-- drop
-------------------------------------------------------------------------------

-- ゲートが下に落とせる状態にあるかどうかを返す
function quantum_gate:is_droppable()
  return not (self:is_i() or self:is_dropping() or self:is_swapping())
end

function quantum_gate:drop(x, start_y)
  --#if assert
  assert(1 <= x)
  assert(x <= 6)
  assert(1 <= start_y)
  assert(start_y <= 12)
  assert(self:is_droppable())
  --#endif

  self.x = x
  self._distance_dropped = 0
  self.start_y = start_y
  self._state = state_dropping
end

function quantum_gate:is_dropping()
  return self._state == state_dropping
end

-------------------------------------------------------------------------------
-- swap
-------------------------------------------------------------------------------

function quantum_gate:is_swapping()
  return self:_is_swapping_with_right() or self:_is_swapping_with_left()
end

function quantum_gate:_is_swapping_with_left()
  return self._state == state_swapping_with_left
end

function quantum_gate:_is_swapping_with_right()
  return self._state == state_swapping_with_right
end

function quantum_gate:swap_with_right(new_x)
  --#if assert
  assert(2 <= new_x)
  --#endif

  self._tick_swap = 0
  self._state = state_swapping_with_right
end

function quantum_gate:swap_with_left(new_x)
  --#if assert
  assert(1 <= new_x)
  --#endif

  self._tick_swap = 0
  self._state = state_swapping_with_left
end

-------------------------------------------------------------------------------
-- debug
-------------------------------------------------------------------------------

--#if debug
function quantum_gate:_tostring()
  if self:is_idle() then
    return self._type
  else
    return self._type .. " (" .. self._state .. ")"
  end
end

--#endif

return quantum_gate
