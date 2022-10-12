require("engine/application/constants")
require("engine/core/class")
require("engine/render/color")

local gate = new_class()

local swap_animation_frame_count = 4
local match_animation_frame_count = 45

local state_idle = "idle"
local state_dropping = "dropping"
local state_match = "match"
local state_swapping_with_left = "swapping_with_left"
local state_swapping_with_right = "swapping_with_right"

local drop_speed = 3

function gate:_init(type, span)
  self._type = type
  self.span = span or 1
  self._state = state_idle
  self._screen_dy = 0
end

-- gate type

-- I ゲートである場合 true を返す
function gate:is_i()
  return self._type == "i"
end

-- H ゲートである場合 true を返す
function gate:is_h()
  return self._type == "h"
end

-- X ゲートである場合 true を返す
function gate:is_x()
  return self._type == "x"
end

-- Y ゲートである場合 true を返す
function gate:is_y()
  return self._type == "y"
end

-- Z ゲートである場合 true を返す
function gate:is_z()
  return self._type == "z"
end

-- S ゲートである場合 true を返す
function gate:is_s()
  return self._type == "s"
end

-- T ゲートである場合 true を返す
function gate:is_t()
  return self._type == "t"
end

-- SWAP ゲートである場合 true を返す
function gate:is_swap()
  return self._type == "swap"
end

-- Control ゲートである場合 true を返す
function gate:is_control()
  return self._type == "control"
end

-- CNOT ゲート内の X ゲートである場合 true を返す
function gate:is_cnot_x()
  return self._type == "cnot_x"
end

-- おじゃまゲートの先頭 (左端) である場合 true を返す
function gate:is_garbage()
  return self._type == "g"
end

-- gate state

-- ゲートが idle である場合 true を返す
function gate:is_idle()
  return self._state == state_idle
end

-- 他のゲートが通過 (ドロップ) できる場合 true を返す
function gate:is_empty()
  return (self:is_i() and not self:is_swapping()) or
      self:is_dropping()
end

-- マッチ状態である場合 true を返す
function gate:is_match()
  return self._state == state_match
end

-- マッチできる場合 true を返す
function gate:is_reducible()
  return (not self:is_i()) and self:is_idle() or self:is_garbage()
end

function gate:update(board, x, y)
  if self:is_idle() then
    self.puff = false

    if self._tick_dropped then
      self._tick_dropped = self._tick_dropped + 1

      if self._tick_dropped == 12 then
        self._tick_dropped = nil
      end
    end
  elseif self:is_swapping() then
    --#if assert
    assert(not self:is_garbage())
    --#endif

    if self._tick_swap < swap_animation_frame_count then
      self._tick_swap = self._tick_swap + 1
    else
      -- SWAP 完了

      --#if assert
      assert(self:_is_swapping_with_right())
      --#endif

      local new_x = x + 1
      local right_gate = board:gate_at(new_x, y)

      -- A を SWAP や CNOT の一部とすると、
      --
      --   [BC]
      -- --[A_], [A-]--
      -- --[-A], [_A]--
      --   [AA]
      --
      -- の 4 パターンで左側だけ考える

      if self.other_x == nil and right_gate.other_x == nil then
        board:put(new_x, y, self)
        board:put(x, y, right_gate)
      elseif not self:is_i() and right_gate:is_i() then
        board:put(new_x, y, self)
        board:put(x, y, right_gate)
        board:gate_at(self.other_x, y).other_x = new_x
      elseif self:is_i() and not right_gate:is_i() then
        board:put(new_x, y, self)
        board:put(x, y, right_gate)
        board:gate_at(right_gate.other_x, y).other_x = x
      elseif self.other_x and right_gate.other_x then
        board:put(new_x, y, self)
        board:put(x, y, right_gate)
        self.other_x, right_gate.other_x = x, new_x
      end

      self._state, right_gate._state = state_idle, state_idle
    end
  elseif self:is_dropping() then
    local screen_y = board:screen_y(self._start_y) + self._screen_dy
    local next_y = board:y(screen_y + drop_speed)
    local max_next_y = board.raised_dots > 0 and board.row_next_gates or board.rows

    if self._start_y == next_y or
        (board:is_gate_droppable(x, y, next_y) and next_y <= max_next_y) then
      self._screen_dy = self._screen_dy + drop_speed
    else
      self._screen_dy = 0
      self.y = board:y(screen_y)

      board:remove_gate(x, y)
      board:put(x, self.y, self)

      self._state = state_idle
      self._tick_dropped = 0
    end
  elseif self:is_match() then
    --#if assert
    assert(not self:is_garbage())
    --#endif

    if self._tick_match < match_animation_frame_count then
      self._tick_match = self._tick_match + 1
    else
      local new_gate = self._reduce_to
      board:put(x, y, new_gate)
      if new_gate:is_i() then
        new_gate.puff = true
      end
    end
  end
end

function gate:render(screen_x, screen_y)
  if self:is_i() then
    return
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

      spr(sprite_id, screen_x + x * tile_size, screen_y + self._screen_dy)
    end
  else
    local screen_dx = 0
    local diff = (self._tick_swap or 0) * (tile_size / swap_animation_frame_count)
    if self:_is_swapping_with_right() then
      screen_dx = diff
    elseif self:_is_swapping_with_left() then
      screen_dx = -diff
    end

    spr(self:_sprite(), screen_x + screen_dx, screen_y + self._screen_dy)
  end
end

function gate:_sprite()
  --#if assert
  assert(self.sprites, self._type)
  assert(self.sprites[self._state], self._state)
  --#endif

  if self:is_idle() and self._tick_dropped then
    return split(self.sprites.dropped)[self._tick_dropped]
  end

  if self:is_match() then
    local mod = self._tick_match % 12
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

function gate:replace_with(other)
  self._state = state_match
  self._reduce_to = other
  self._tick_match = 0
end

-------------------------------------------------------------------------------
-- drop
-------------------------------------------------------------------------------

-- ゲートが下に落とせる状態にあるかどうかを返す
function gate:is_droppable()
  return not (self:is_i() or self:is_dropping() or self:is_swapping())
end

function gate:drop(x, start_y)
  --#if assert
  assert(1 <= x)
  assert(x <= 6)
  assert(1 <= start_y)
  assert(start_y <= 12)
  assert(self:is_droppable())
  --#endif

  self._state = state_dropping
  self._screen_dy = 0
  self._start_y = start_y
end

function gate:is_dropping()
  return self._state == state_dropping
end

-------------------------------------------------------------------------------
-- swap
-------------------------------------------------------------------------------

function gate:is_swapping()
  return self:_is_swapping_with_right() or self:_is_swapping_with_left()
end

function gate:_is_swapping_with_left()
  return self._state == state_swapping_with_left
end

function gate:_is_swapping_with_right()
  return self._state == state_swapping_with_right
end

function gate:swap_with_right(new_x)
  --#if assert
  assert(2 <= new_x)
  --#endif

  self._state = state_swapping_with_right
  self._tick_swap = 0
end

function gate:swap_with_left(new_x)
  --#if assert
  assert(1 <= new_x)
  --#endif

  self._state = state_swapping_with_left
  self._tick_swap = 0
end

-------------------------------------------------------------------------------
-- debug
-------------------------------------------------------------------------------

--#if debug
function gate:_tostring()
  local type = self._type
  type = type == "control" and "•" or type
  type = type == "cnot_x" and "x" or type
  type = type == "swap" and "S" or type

  if self:is_idle() then
    return type
  elseif self:is_swapping() then -- yellow
    return "\27[30;43m" .. type .. "\27[39;49m"
  elseif self:is_dropping() then -- blue
    return "\27[37;44m" .. type .. "\27[39;49m"
  elseif self:is_match() then -- red
    return "\27[37;41m" .. type .. "\27[39;49m"
  else
    return self._type .. " (" .. self._state .. ")"
  end
end

--#endif

return gate
