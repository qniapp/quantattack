require("engine/core/class")

local quantum_gate = new_class()

quantum_gate.size = 8
quantum_gate._types = { "h", "x", "y", "z", "s", "t" }
quantum_gate._num_frames_swap = 2
quantum_gate._num_frames_match = 45
quantum_gate._dy = 2
quantum_gate.state_swapping_with_left = "swapping_with_left"
quantum_gate.state_swapping_with_right = "swapping_with_right"
quantum_gate.state_swap_finished = "swap_finished"

quantum_gate.random_single_gate = function()
  local type = quantum_gate._types[flr(rnd(#quantum_gate._types)) + 1]
  return quantum_gate(type)
end

function quantum_gate:_init(type)
  self.type = type
  self.state = "idle"
  self.dy = 0
end

-- gate type

function quantum_gate:is_i()
  return self.type == "i"
end

function quantum_gate:is_h()
  return self.type == "h"
end

function quantum_gate:is_x()
  return self.type == "x"
end

function quantum_gate:is_y()
  return self.type == "y"
end

function quantum_gate:is_z()
  return self.type == "z"
end

function quantum_gate:is_s()
  return self.type == "s"
end

function quantum_gate:is_t()
  return self.type == "t"
end

function quantum_gate:is_swap()
  return self.type == "swap"
end

function quantum_gate:is_control()
  return self.type == "control"
end

function quantum_gate:is_cnot_x()
  return self.type == "cnot_x"
end

function quantum_gate:is_garbage()
  return self.type == "g"
end

function quantum_gate:is_placeholder()
  return self.type == "?"
end

-- gate state

function quantum_gate:is_idle()
  return self.state == "idle"
end

function quantum_gate:is_busy()
  return not (self:is_i() or self:is_idle() or self:is_dropped())
end

function quantum_gate:is_dropping()
  return self.state == "dropping"
end

function quantum_gate:is_dropped()
  return self.state == "dropped"
end

function quantum_gate:is_match()
  return self.state == "match"
end

function quantum_gate:is_reducible()
  return self:is_garbage() or (not self:is_busy())
end

function quantum_gate:is_droppable()
  return not (self:is_i() or self:is_dropping() or self:is_swapping())
end

function quantum_gate:update()
  if self:is_placeholder() then
    return
  end

  if self:is_swapping() then
    if self.tick_swap < quantum_gate._num_frames_swap then
      self.tick_swap = self.tick_swap + 1
    else
      self.state = quantum_gate.state_swap_finished
    end
  elseif self:is_swap_finished() then
    self.state = "idle"
  elseif self:is_dropping() then
    if self.start_screen_y + self.dy == self.stop_screen_y then
      self.state = "dropped"
    end
  elseif self:is_dropped() then
    self.dy = 0
    self.state = "idle"
  elseif self:is_match() then
    if self.tick_match == nil then
      self.tick_match = 0
    elseif self.tick_match < quantum_gate._num_frames_match then
      self.tick_match = self.tick_match + 1
    else
      self.tick_match = nil
      self.type = self.reduce_to.type
      self.state = "idle"
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
  elseif self:is_dropping() then
    self.dy = self.dy + quantum_gate._dy
    if screen_y + self.dy > self.stop_screen_y then
      self.dy = self.stop_screen_y - screen_y
    end
  end

  spr(self:_sprite(), screen_x + dx, screen_y + self.dy)
end

function quantum_gate:_sprite()
  local _sprites = {
    h = {
      idle = 0,
      match_up = 8,
      match_middle = 24,
      match_down = 40
    },
    x = {
      idle = 1,
      match_up = 9,
      match_middle = 25,
      match_down = 41,
    },
    y = {
      idle = 2,
      match_up = 10,
      match_middle = 26,
      match_down = 42,
    },
    z = {
      idle = 3,
      match_up = 11,
      match_middle = 27,
      match_down = 43,
    },
    s = {
      idle = 4,
      match_up = 12,
      match_middle = 28,
      match_down = 44,
    },
    t = {
      idle = 5,
      match_up = 13,
      match_middle = 29,
      match_down = 45,
    },
  }
  local sprites = _sprites[self.type]

  if self:is_idle() or
      self:is_swapping() or
      self:is_swap_finished() or
      self:is_dropping() or
      self:is_dropped() then
    return sprites.idle
  elseif self:is_match() then
    local mod = self.tick_match % 12
    if mod <= 2 then
      return sprites.match_up
    elseif mod <= 5 then
      return sprites.match_middle
    elseif mod <= 8 then
      return sprites.match_down
    elseif mod <= 11 then
      return sprites.match_middle
    end
  else
    assert(false, "unknown state: " .. self.state)
  end
end

function quantum_gate:replace_with(other)
  self.reduce_to = other
  self.state = "match"
end

function quantum_gate:drop(start_screen_y, stop_screen_y)
  self.dy = 0
  self.start_screen_y = start_screen_y
  self.stop_screen_y = stop_screen_y
  self.state = "dropping"
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
  return self.state == quantum_gate.state_swap_finished
end

function quantum_gate:swap_with_right(new_x)
  --#if assert
  assert(2 <= new_x)
  --#endif

  self.tick_swap = 0
  self.new_x_after_swap = new_x
  self.state = quantum_gate.state_swapping_with_right
end

function quantum_gate:swap_with_left(new_x)
  --#if assert
  assert(1 <= new_x)
  --#endif

  self.tick_swap = 0
  self.new_x_after_swap = new_x
  self.state = quantum_gate.state_swapping_with_left
end

-- private

function quantum_gate:_is_swapping_with_right()
  return self.state == quantum_gate.state_swapping_with_right
end

function quantum_gate:_is_swapping_with_left()
  return self.state == quantum_gate.state_swapping_with_left
end

return quantum_gate
