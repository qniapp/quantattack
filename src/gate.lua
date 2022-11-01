require("engine/application/constants")
require("engine/core/class")
require("particle")

local gate = new_class()

gate.match_animation_frame_count = 45
gate.match_delay_per_gate = 15
gate.swap_animation_frame_count = 4

local fall_speed = 3

local sprites = {
  h = {
    default = 0,
    landed = split("16,16,16,16,48,48,32,32,32,16,16,16"),
    match = split("9,9,9,25,25,25,9,9,9,41,41,41,0,0,0,57")
  },
  x = {
    default = 1,
    landed = split("17,17,17,17,49,49,33,33,33,17,17,17"),
    match = split("10,10,10,26,26,26,10,10,10,42,42,42,1,1,1,58")
  },
  y = {
    default = 2,
    landed = split("18,18,18,18,50,50,34,34,34,18,18,18"),
    match = split("11,11,11,27,27,27,11,11,11,43,43,43,2,2,2,59")
  },
  z = {
    default = 3,
    landed = split("19,19,19,19,51,51,35,35,35,19,19,19"),
    match = split("12,12,12,28,28,28,12,12,12,44,44,44,3,3,3,60")
  },
  s = {
    default = 4,
    landed = split("20,20,20,20,52,52,36,36,36,20,20,20"),
    match = split("13,13,13,29,29,29,13,13,13,45,45,45,4,4,4,61")
  },
  t = {
    default = 5,
    landed = split("21,21,21,21,53,53,37,37,37,21,21,21"),
    match = split("14,14,14,30,30,30,14,14,14,46,46,46,5,5,5,62")
  },
  control = {
    default = 6,
    landed = split("22,22,22,22,54,54,38,38,38,22,22,22"),
    match = split("15,15,15,31,31,31,15,15,15,47,47,47,6,6,6,63")
  },
  cnot_x = {
    default = 7,
    landed = split("23,23,23,23,55,55,39,39,39,23,23,23"),
    match = split("64,64,64,80,80,80,64,64,64,96,96,96,7,7,7,112")
  },
  swap = {
    default = 8,
    landed = split("24,24,24,24,56,56,40,40,40,24,24,24"),
    match = split("65,65,65,81,81,81,65,65,65,97,97,97,8,8,8,113")
  },
  ["!"] = {
    default = 89,
    landed = split("89,89,89,89,89,89,89,89,89,89,89,89"),
    match = split("89,89,89,89,89,89,89,89,89,89,89,89,89,89,89,89")
  },
}

function gate:_init(type, span)
  self.type = type
  self.span = span or 1
  self._state = "idle"
  self._screen_dy = 0
  self.chain_id = nil
end

-- gate type

function gate:is_i()
  return self.type == "i"
end

function gate:is_control()
  return self.type == "control"
end

function gate:is_cnot_x()
  return self.type == "cnot_x"
end

-- おじゃまゲートの先頭 (左端) である場合 true を返す
function gate:is_garbage()
  return self.type == "g"
end

-- gate state

-- ゲートが idle である場合 true を返す
function gate:is_idle()
  return self._state == "idle"
end

-- 他のゲートが通過 (ドロップ) できる場合 true を返す
function gate:is_empty()
  return (self:is_i() and not self:is_swapping()) or
      self:is_falling()
end

-- マッチ状態である場合 true を返す
function gate:is_match()
  return self._state == "match"
end

-- おじゃまユニタリがゲートに変化した後の硬直中
function gate:is_freeze()
  return self._state == "freeze"
end

-- マッチできる場合 true を返す
function gate:is_reducible()
  return not self:is_i() and self:is_idle()
end

function gate:update(board, x, y)
  if self:is_idle() then
    if y <= board.rows then
      local gate_below = board.gates[x][y + 1]

      if gate_below.chain_id == nil or (gate_below:is_i() and not board:is_empty(x, y + 1)) then
        self.chain_id = nil
      end
    end

    if self._tick_landed then
      self._tick_landed = self._tick_landed + 1

      if self._tick_landed == 12 then
        self._tick_landed = nil
      end
    end
  elseif self:is_swapping() then
    --#if assert
    assert(not self:is_garbage())
    --#endif

    if self._tick_swap < gate.swap_animation_frame_count then
      self._tick_swap = self._tick_swap + 1
    else
      -- SWAP 完了
      local new_x = x + 1
      local right_gate = board.gates[new_x][y]

      --#if assert
      assert(self:_is_swapping_with_right(), self._state)
      assert(right_gate:_is_swapping_with_left(), right_gate._state)
      --#endif

      if not right_gate:is_i() then
        create_particle_set(board:screen_x(x) - 2, board:screen_y(y) + 3,
          "1,yellow,yellow,5,left|1,yellow,yellow,5,left|0,yellow,yellow,5,left|0,yellow,yellow,5,left")
      end
      if not self:is_i() then
        create_particle_set(board:screen_x(new_x) + 10, board:screen_y(y) + 3,
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

      self._state, right_gate._state = "idle", "idle"
    end
  elseif self:is_falling() then
    self._screen_dy = self._screen_dy + fall_speed
    local new_y = y
    if self._screen_dy >= tile_size then
      new_y = new_y + 1
    end

    if new_y == y then
      -- 同じ場所にとどまっているので、何もしない
    elseif board:is_gate_fallable(x, y) then
      -- 一個下が空いている場合そこに移動する
      board:remove_gate(x, y)
      board:put(x, new_y, self)
      self._screen_dy = self._screen_dy - tile_size

      -- SWAP または CNOT の場合、ペアとなるゲートもここで移動する
      if self.other_x and x < self.other_x then
        local other_gate = board.gates[self.other_x][y]
        board:remove_gate(self.other_x, y)
        board:put(self.other_x, new_y, other_gate)
        other_gate._screen_dy = self._screen_dy
      end
    else
      -- 一個下が空いていない場合、落下を終了

      -- おじゃまユニタリの最初の落下
      if self._garbage_first_drop then
        board:bounce()
        sfx(1)
        self._garbage_first_drop = false
      else
        sfx(4)
      end

      self._screen_dy = 0
      self._state = "idle"
      self._tick_landed = 0

      if self.other_x and x < self.other_x then
        local other_gate = board.gates[self.other_x][y]
        other_gate._state = "idle"
        other_gate._tick_landed = 0
        other_gate._screen_dy = 0
      end

      board.changed = true
    end
  elseif self:is_match() then
    --#if assert
    assert(not self:is_garbage())
    --#endif

    if self._tick_match <= gate.match_animation_frame_count + self._match_index * gate.match_delay_per_gate then
      self._tick_match = self._tick_match + 1
    else
      local new_gate = self._reduce_to
      board:put(x, y, new_gate)

      sfx(3, -1, (self._match_index - 1) * 4, 4)
      create_particle_set(board:screen_x(x) + 3, board:screen_y(y) + 3,
        "3,white,dark_gray,20|3,white,dark_gray,20|2,white,dark_gray,20|2,dark_purple,dark_gray,20|2,light_gray,dark_gray,20|1,white,dark_gray,20|1,white,dark_gray,20|1,light_gray,dark_gray,20|1,light_gray,dark_gray,20|0,dark_purple,dark_gray,20")

      if self._garbage_span then
        new_gate._tick_freeze = 0
        new_gate._freeze_frame_count = (self._garbage_span - self._match_index) * 15
        new_gate._state = "freeze"
      end
    end
  elseif self:is_freeze() then
    if self._tick_freeze < self._freeze_frame_count then
      self._tick_freeze = self._tick_freeze + 1
    else
      self._state = "idle"
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
    local diff = (self._tick_swap or 0) * (tile_size / gate.swap_animation_frame_count)
    if self:_is_swapping_with_right() then
      screen_dx = diff
    elseif self:_is_swapping_with_left() then
      screen_dx = -diff
    end

    spr(self:_sprite(), screen_x + screen_dx, screen_y + self._screen_dy)
  end
end

function gate:_sprite()
  if self:is_idle() and self._tick_landed then
    return sprites[self.type].landed[self._tick_landed]
  elseif self:is_match() then
    local sequence = sprites[self.type].match
    return self._tick_match <= 15 and sequence[self._tick_match] or sequence[#sequence]
  else
    return sprites[self.type].default
  end
end

function gate:replace_with(other, match_index, garbage_span, chain_id)
  self._state = "match"
  self._reduce_to = other
  self._match_index = match_index or 0
  self._garbage_span = garbage_span
  self._tick_match = 1
  self.chain_id = chain_id
  other.chain_id = chain_id
end

-------------------------------------------------------------------------------
-- fall
-------------------------------------------------------------------------------

-- ゲートが下に落とせる状態にあるかどうかを返す
function gate:is_fallable()
  return not (self:is_i() or self.type == "!" or self:is_falling() or self:is_swapping() or self:is_freeze())
end

function gate:fall()
  --#if assert
  assert(self:is_fallable())
  --#endif

  self._state = "falling"
  self._screen_dy = 0
end

function gate:is_falling()
  return self._state == "falling"
end

function gate:is_landed()
  return self._state == "landed"
end

-------------------------------------------------------------------------------
-- swap
-------------------------------------------------------------------------------

function gate:is_swapping()
  return self:_is_swapping_with_right() or self:_is_swapping_with_left()
end

function gate:_is_swapping_with_left()
  return self._state == "swapping_with_left"
end

function gate:_is_swapping_with_right()
  return self._state == "swapping_with_right"
end

function gate:swap_with_right(new_x)
  --#if assert
  assert(2 <= new_x)
  --#endif

  self._state = "swapping_with_right"
  self._tick_swap = 0
end

function gate:swap_with_left(new_x)
  --#if assert
  assert(1 <= new_x)
  --#endif

  self._state = "swapping_with_left"
  self._tick_swap = 0
end

-------------------------------------------------------------------------------
-- helpers
-------------------------------------------------------------------------------

function i_gate()
  return gate('i')
end

function h_gate()
  return gate('h')
end

function x_gate()
  return gate('x')
end

function y_gate()
  return gate('y')
end

function z_gate()
  return gate('z')
end

function s_gate()
  return gate('s')
end

function t_gate()
  return gate('t')
end

function control_gate(other_x)
  local control = gate('control')
  control.other_x = other_x
  return control
end

function cnot_x_gate(other_x)
  local cnot_x = gate('cnot_x')
  cnot_x.other_x = other_x
  return cnot_x
end

function swap_gate(other_x)
  local swap = gate('swap')
  swap.other_x = other_x
  return swap
end

function garbage_gate(span)
  --#if assert
  assert(span)
  --#endif

  local garbage = gate('g', span)
  garbage._sprite_middle = 87
  garbage._sprite_left = 86
  garbage._sprite_right = 88
  garbage._garbage_first_drop = true

  return garbage
end

function garbage_match_gate()
  return gate('!')
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
        falling = "|",
        match = "*",
        freeze = "f"
      }

  return (typestr[self.type] or self.type) .. statestr[self._state]
end

--#endif

return gate
