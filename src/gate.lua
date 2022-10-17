require("engine/application/constants")
require("engine/core/class")
require("engine/render/color")
require("particle")

local gate = new_class()

local swap_animation_frame_count = 4
local match_animation_frame_count = 45

local state_idle = "idle"
local state_dropping = "dropping"
local state_match = "match"
local state_swapping_with_left = "swapping_with_left"
local state_swapping_with_right = "swapping_with_right"
local state_freeze = "freeze"

local drop_speed = 3

local sprites = {
  h = {
    default = 0,
    dropped = split("16,16,16,16,48,48,32,32,32,16,16,16"),
    match = split("9,9,9,25,25,25,9,9,9,41,41,41,0,0,0,57")
  },
  x = {
    default = 1,
    dropped = split("17,17,17,17,49,49,33,33,33,17,17,17"),
    match = split("10,10,10,26,26,26,10,10,10,42,42,42,1,1,1,58")
  },
  y = {
    default = 2,
    dropped = split("18,18,18,18,50,50,34,34,34,18,18,18"),
    match = split("11,11,11,27,27,27,11,11,11,43,43,43,2,2,2,59")
  },
  z = {
    default = 3,
    dropped = split("19,19,19,19,51,51,35,35,35,19,19,19"),
    match = split("12,12,12,28,28,28,12,12,12,44,44,44,3,3,3,60")
  },
  s = {
    default = 4,
    dropped = split("20,20,20,20,52,52,36,36,36,20,20,20"),
    match = split("13,13,13,29,29,29,13,13,13,45,45,45,4,4,4,61")
  },
  t = {
    default = 5,
    dropped = split("21,21,21,21,53,53,37,37,37,21,21,21"),
    match = split("14,14,14,30,30,30,14,14,14,46,46,46,5,5,5,62")
  },
  control = {
    default = 6,
    dropped = split("22,22,22,22,54,54,38,38,38,22,22,22"),
    match = split("15,15,15,31,31,31,15,15,15,47,47,47,6,6,6,63")
  },
  cnot_x = {
    default = 7,
    dropped = split("23,23,23,23,55,55,39,39,39,23,23,23"),
    match = split("64,64,64,80,80,80,64,64,64,96,96,96,7,7,7,112")
  },
  swap = {
    default = 8,
    dropped = split("24,24,24,24,56,56,40,40,40,24,24,24"),
    match = split("65,65,65,81,81,81,65,65,65,97,97,97,8,8,8,113")
  },
  ["!"] = {
    default = 89,
    dropped = split("89,89,89,89,89,89,89,89,89,89,89,89"),
    match = split("89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89")
  },
}

function gate:_init(type, span)
  self._type = type
  self.span = span or 1
  self._state = state_idle
  self._screen_dy = 0
end

-- gate type

function gate:is_i()
  return self._type == "i"
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

-- おじゃまユニタリがゲートに変化した後の硬直中
function gate:is_freeze()
  return self._state == state_freeze
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
      local new_x = x + 1
      local right_gate = board:gate_at(new_x, y)

      --#if assert
      assert(self:_is_swapping_with_right(), self._state)
      assert(right_gate:_is_swapping_with_left(), right_gate._state)
      --#endif

      -- 星屑? エフェクト
      if not right_gate:is_i() then
        create_particle_set(board:screen_x(x) - 2,
          board:screen_y(y) + 3,
          "1,yellow,yellow,5,left|1,yellow,yellow,5,left|0,yellow,yellow,5,left|0,yellow,yellow,5,left")
      end
      if not self:is_i() then
        create_particle_set(board:screen_x(new_x) + 10,
          board:screen_y(y) + 3,
          "1,yellow,yellow,5,right|1,yellow,yellow,5,right|0,yellow,yellow,5,right|0,yellow,yellow,5,right")
      end

      -- A を SWAP や CNOT の一部とすると、
      --
      -- 1.   [BC]
      -- 2. --[A_], [A-]--
      -- 3. --[-A], [_A]--
      -- 4.   [AA]
      --
      -- の 4 パターンで左側だけ考える

      board:put(new_x, y, self)
      board:put(x, y, right_gate)

      if self.other_x == nil and right_gate.other_x == nil then -- 1.
        -- NOP
      elseif not self:is_i() and right_gate:is_i() then -- 2.
        board:gate_at(self.other_x, y).other_x = new_x
      elseif self:is_i() and not right_gate:is_i() then -- 3.
        board:gate_at(right_gate.other_x, y).other_x = x
      elseif self.other_x and right_gate.other_x then -- 4.
        self.other_x, right_gate.other_x = x, new_x
      else
        --#if assert
        assert(false, "we should not reach here")
        --#endif
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
      sfx((self:is_garbage() and not self._garbage_drop_sfx_played) and 1 or 4)
      self._garbage_drop_sfx_played = true

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

    if self._tick_match <= match_animation_frame_count + self._match_index * 15 then -- TODO: 15 をどっかに定数化
      self._tick_match = self._tick_match + 1
    else
      local new_gate = self._reduce_to
      board:put(x, y, new_gate)

      -- puff!
      sfx(3, -1, (self._match_index - 1) * 4, 4)
      create_particle_set(board:screen_x(x) + 3,
        board:screen_y(y) + 3,
        "3,white,dark_gray,20|3,white,dark_gray,20|2,white,dark_gray,20|2,dark_purple,dark_gray,20|2,light_gray,dark_gray,20|1,white,dark_gray,20|1,white,dark_gray,20|1,light_gray,dark_gray,20|1,light_gray,dark_gray,20|0,dark_purple,dark_gray,20")

      if self._garbage_span then
        new_gate._tick_freeze = 0
        new_gate._freeze_frame_count = (self._garbage_span - self._match_index) * 15
        new_gate._state = state_freeze
      end
    end
  elseif self:is_freeze() then
    if self._tick_freeze < self._freeze_frame_count then
      self._tick_freeze = self._tick_freeze + 1
    else
      self._state = state_idle
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
  if self:is_idle() and self._tick_dropped then
    return sprites[self._type].dropped[self._tick_dropped]
  elseif self:is_match() then
    local sequence = sprites[self._type].match
    return self._tick_match <= 15 and sequence[self._tick_match] or sequence[#sequence]
  else
    return sprites[self._type].default
  end
end

function gate:replace_with(other, match_index, garbage_span)
  self._state = state_match
  self._reduce_to = other
  self._match_index = match_index or 0
  self._garbage_span = garbage_span
  self._tick_match = 1
end

-------------------------------------------------------------------------------
-- drop
-------------------------------------------------------------------------------

-- ゲートが下に落とせる状態にあるかどうかを返す
function gate:is_droppable()
  return not (self:is_i() or self:is_garbage_match() or self:is_dropping() or self:is_swapping() or self:is_freeze())
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
  local typestr, statestr = {
    i = '_',
    control = 'C',
    cnot_x = 'X',
    swap = 'S'
  },
      {
        idle = " ",
        swapping_with_left = "<",
        swapping_with_right = ">",
        dropping = "|",
        match = "*",
        freeze = "f"
      }

  return (typestr[self._type] or self._type) .. statestr[self._state]
end

--#endif

return gate
