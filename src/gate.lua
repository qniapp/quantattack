require("engine/application/constants")
require("engine/core/class")
require("engine/render/color")

local puff_particle = require("puff_particle")
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

function gate:is_garbage_match()
  return self._type == "!"
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
    self._screen_dy = self._screen_dy + drop_speed
    local new_screen_y = board:screen_y(y) + self._screen_dy
    local new_y = board:y(new_screen_y)

    if new_y == y then
      -- 同じ場所にとどまっているので、何もしない
    elseif board:is_gate_droppable(x, y, new_y) and new_y <= board.rows then
      -- 一個下が空いている場合そこに移動する
      board:remove_gate(x, y)
      board:put(x, new_y, self)
      self._screen_dy = self._screen_dy - tile_size

      -- SWAP または CNOT の場合、ペアとなるゲートもここで移動する
      if self.other_x and x < self.other_x then
        local other_gate = board:gate_at(self.other_x, y)
        board:remove_gate(self.other_x, y)
        board:put(self.other_x, new_y, other_gate)
        other_gate._screen_dy = other_gate._screen_dy - tile_size
      end
    else
      -- 一個下が空いていない場合、落下を終了する
      sfx(self:is_garbage() and 1 or 4)

      self._screen_dy = 0
      self._state = state_idle
      self._tick_dropped = 0

      if self.other_x and x < self.other_x then
        local other_gate = board:gate_at(self.other_x, y)

        other_gate._screen_dy = 0
        other_gate._state = state_idle
        other_gate._tick_dropped = 0
      end
    end
  elseif self:is_match() then
    --#if assert
    assert(not self:is_garbage())
    --#endif

    if self._tick_match <= match_animation_frame_count + (self._match_index - 1) * 15 then -- TODO: 15 をどっかに定数化
      self._tick_match = self._tick_match + 1
    else
      local new_gate = self._reduce_to
      board:put(x, y, new_gate)
      new_gate:_puff(board, x, y, self._match_index)
    end
  end
end

function gate:_puff(board, board_x, board_y, puff_index)
  local x = board:screen_x(board_x) + 3
  local y = board:screen_y(board_y) + 3

  sfx(3, -1, (puff_index - 1) * 4, 4)

  puff_particle(x, y, 3)
  puff_particle(x, y, 3)
  puff_particle(x, y, 2)
  puff_particle(x, y, 2, colors.dark_purple)
  puff_particle(x, y, 2, colors.light_grey)
  puff_particle(x, y, 1)
  puff_particle(x, y, 1)
  puff_particle(x, y, 1, colors.light_grey)
  puff_particle(x, y, 1, colors.light_grey)
  puff_particle(x, y, 0, colors.dark_purple)
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
  if self:is_idle() and self._tick_dropped then
    return split(self.sprites.dropped)[self._tick_dropped]
  elseif self:is_match() then
    local sequence = split(self.sprites.match)
    return self._tick_match <= 15 and sequence[self._tick_match] or sequence[#sequence]
  else
    return self.sprites.default
  end
end

function gate:replace_with(other, match_index)
  self._state = state_match
  self._reduce_to = other
  self._match_index = match_index or 1
  self._tick_match = 1
end

-------------------------------------------------------------------------------
-- drop
-------------------------------------------------------------------------------

-- ゲートが下に落とせる状態にあるかどうかを返す
function gate:is_droppable()
  return not (self:is_i() or self:is_garbage_match() or self:is_dropping() or self:is_swapping())
end

function gate:drop()
  --#if assert
  assert(self:is_droppable())
  --#endif

  self._state = state_dropping
  self._screen_dy = 0
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
  type = type == "i" and "_" or type
  type = type == "control" and "C" or type
  type = type == "cnot_x" and "X" or type
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
