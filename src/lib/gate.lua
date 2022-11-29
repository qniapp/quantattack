---@diagnostic disable: global-in-nil-env, lowercase-global, unbalanced-assignments, undefined-field, undefined-global

gate_match_animation_frame_count = 45
gate_match_delay_per_gate = 8
gate_swap_animation_frame_count = 4
gate_fall_speed = 2

sprites = {
  -- default|landed|match
  h = "0|16,16,16,16,48,48,32,32,32,16,16,16|9,9,9,25,25,25,9,9,9,41,41,41,0,0,0,57",
  x = "1|17,17,17,17,49,49,33,33,33,17,17,17|10,10,10,26,26,26,10,10,10,42,42,42,1,1,1,58",
  y = "2|18,18,18,18,50,50,34,34,34,18,18,18|11,11,11,27,27,27,11,11,11,43,43,43,2,2,2,59",
  z = "3|19,19,19,19,51,51,35,35,35,19,19,19|12,12,12,28,28,28,12,12,12,44,44,44,3,3,3,60",
  s = "4|20,20,20,20,52,52,36,36,36,20,20,20|13,13,13,29,29,29,13,13,13,45,45,45,4,4,4,61",
  t = "5|21,21,21,21,53,53,37,37,37,21,21,21|14,14,14,30,30,30,14,14,14,46,46,46,5,5,5,62",
  control = "6|22,22,22,22,54,54,38,38,38,22,22,22|15,15,15,31,31,31,15,15,15,47,47,47,6,6,6,63",
  cnot_x = "7|23,23,23,23,55,55,39,39,39,23,23,23|64,64,64,80,80,80,64,64,64,96,96,96,7,7,7,112",
  swap = "8|24,24,24,24,56,56,40,40,40,24,24,24|65,65,65,81,81,81,65,65,65,97,97,97,8,8,8,113",
  ["!"] = "101|101,101,101,101,101,101,101,101,101,101,101,101|101,101,101,101,101,101,101,101,101,101,101,101,101,101,101,101"
}

for key, each in pairs(sprites) do
  local default, landed, match = unpack(split(each, "|"))
  ---@diagnostic disable-next-line: assign-type-mismatch
  sprites[key] = {
    default = default,
    landed = split(landed),
    match = split(match)
  }
end

--#if debug
local type_string = {
  i = '_',
  control = 'C',
  cnot_x = 'X',
  swap = 'S'
}

local state_string = {
  idle = " ",
  swapping_with_left = "<",
  swapping_with_right = ">",
  falling = "|",
  match = "*",
  freeze = "f",
}
--#endif


--- @class Gate
--- @field type "i" | "h" | "x" | "y" | "z" | "s" | "t" | "control" | "cnot_x" | "swap" | "g" | "!" gate type
--- @field span 1 | 2 | 3 | 4 | 5 | 6 span of the gate
--- @field height integer height of the gate
--- @field render function
--- @field replace_with function
--- @field new_gate Gate
--- @field change_state function
local gate = new_class()

--- @param type "i" | "h" | "x" | "y" | "z" | "s" | "t" | "control" | "cnot_x" | "swap" | "g" | "!" gate type
--- @param span? 1 | 2 | 3 | 4 | 5 | 6 span of the gate
--- @param height? integer height of the gate
function gate:_init(type, span, height)
  --#if assert
  assert(type == "i" or type == "h" or type == "x" or type == "y" or type == "z" or
    type == "s" or type == "t" or type == "control" or type == "cnot_x" or type == "swap" or
    type == "g" or type == "!",
    "invalid type: " .. type)
  --#endif

  self.type = type
  self.span = span or 1
  self.height = height or 1
  self.sprite_set = sprites[type]
  self._state = "idle"
  self._fall_screen_dy = 0

  --#if assert
  assert(0 < self.span, "span must be greater than 0")
  assert(self.span < 7, "span must be less than 7")
  assert(self.type == "g" or
    ((self.type == "i" or self.type == "h" or self.type == "x" or self.type == "y" or self.type == "z" or
        self.type == "s" or self.type == "t" or
        self.type == "control" or self.type == "cnot_x" or self.type == "swap" or self.type == "!") and
        self.span == 1),
    "invalid span: " .. self.span)
  assert(self.height > 0, "height must be greater than 0")
  assert(self.type == "g" or
    ((self.type == "i" or self.type == "h" or self.type == "x" or self.type == "y" or self.type == "z" or
        self.type == "s" or self.type == "t" or
        self.type == "control" or self.type == "cnot_x" or self.type == "swap" or self.type == "!") and
        self.height == 1),
    "invalid height: " .. self.height)
  --#endif
end

-------------------------------------------------------------------------------
-- ゲートの種類と状態
-------------------------------------------------------------------------------

function gate:is_idle()
  return self._state == "idle"
end

function gate:is_fallable()
  return not (self.type == "i" or self.type == "!" or self:is_swapping() or self:is_freeze())
end

function gate:is_falling()
  return self._state == "falling"
end

function gate:is_reducible()
  return self.type ~= "i" and self.type ~= "!" and self:is_idle()
end

-- マッチ状態である場合 true を返す
function gate:is_match()
  return self._state == "match"
end

-- おじゃまユニタリがゲートに変化した後の硬直中
function gate:is_freeze()
  return self._state == "freeze"
end

function gate:is_swapping()
  return self:_is_swapping_with_right() or self:_is_swapping_with_left()
end

--- @private
function gate:_is_swapping_with_left()
  return self._state == "swapping_with_left"
end

--- @private
function gate:_is_swapping_with_right()
  return self._state == "swapping_with_right"
end

function gate:is_empty()
  return self.type == "i" and not self:is_swapping()
end

function gate:is_single_gate()
  return self.type == 'h' or self.type == 'x' or self.type == 'y' or self.type == 'z' or self.type == 's' or
      self.type == 't'
end

-------------------------------------------------------------------------------
-- ゲート操作
-------------------------------------------------------------------------------

function gate:swap_with_right()
  self.chain_id = nil

  self:change_state("swapping_with_right")
end

function gate:swap_with_left()
  self.chain_id = nil

  self:change_state("swapping_with_left")
end

function gate:fall()
  --#if assert
  assert(self:is_fallable(), "gate " .. self.type .. "(" .. self.x .. ", " .. self.y .. ")")
  --#endif

  if self:is_falling() then
    return
  end

  self._fall_screen_dy = 0

  self:change_state("falling")
end

--- @param other Gate
--- @param match_index integer
--- @param _chain_id string
--- @param garbage_span? integer
--- @param garbage_height? integer
function gate:replace_with(other, match_index, _chain_id, garbage_span, garbage_height)
  self.new_gate, self._match_index, self._tick_match, self.chain_id, other.chain_id, self._garbage_span,
      self._garbage_height =
  other, match_index or 0, 1, _chain_id, _chain_id, garbage_span, garbage_height

  self:change_state("match")
end

-------------------------------------------------------------------------------
-- update and render
-------------------------------------------------------------------------------

function gate:update()
  if self:is_idle() then
    if self._tick_landed then
      self._tick_landed = self._tick_landed + 1

      if self._tick_landed == 13 then
        self._tick_landed = nil
      end
    end
  elseif self:is_swapping() then
    if self._tick_swap < gate_swap_animation_frame_count then
      self._tick_swap = self._tick_swap + 1
    else
      self.chain_id = nil
      self:change_state("idle")
    end
  elseif self:is_falling() then
    -- NOP
  elseif self:is_match() then
    if self._tick_match <= gate_match_animation_frame_count + self._match_index * gate_match_delay_per_gate then
      self._tick_match = self._tick_match + 1
    else
      sfx(3, -1, (self._match_index % 6 - 1) * 4, 4)
      self:change_state("idle")

      if self._garbage_span then
        self.new_gate._tick_freeze = 0
        self.new_gate._freeze_frame_count = (self._garbage_span * self._garbage_height - self._match_index) *
            gate_match_delay_per_gate
        self.new_gate:change_state("freeze")
      end
    end
  elseif self:is_freeze() then
    if self._tick_freeze < self._freeze_frame_count then
      self._tick_freeze = self._tick_freeze + 1
    else
      self:change_state("idle")
    end
  end
end

--- @param screen_x integer x position of the screen
--- @param screen_y integer y position of the screen
function gate:render(screen_x, screen_y)
  if self.type == "i" then
    return
  end

  local swap_screen_dx = (self._tick_swap or 0) * (8 / gate_swap_animation_frame_count)
  if self:_is_swapping_with_left() then
    swap_screen_dx = -swap_screen_dx
  end

  local shake_dx, shake_dy, sprite = 0, 0

  if self:is_idle() and self._tick_landed then
    sprite = self.sprite_set.landed[_tick_landed]
  elseif self:is_match() then
    local sequence = self.sprite_set.match
    sprite = self._tick_match <= gate_match_delay_per_gate and sequence[self._tick_match] or sequence[#sequence]
  elseif _state == "over" then
    shake_dx, shake_dy = rnd(2) - 1, rnd(2) - 1
    sprite = self.sprite_set.match[#sprite_set.match]
  else
    sprite = self.sprite_set.default
  end

  if type == "!" then
    palt(0, false)
    pal(13, self.body_color)
  end

  if _state == "over" then
    pal(13, 9)
    pal(7, 1)
  end

  spr(sprite, screen_x + swap_screen_dx + shake_dx, screen_y + self._fall_screen_dy + shake_dy)

  palt()
  pal()
end

-------------------------------------------------------------------------------
-- observer pattern
-------------------------------------------------------------------------------

--- @param observer table
function gate:attach(observer)
  self.observer = observer
end

--- @param new_state string
function gate:change_state(new_state)
  self._tick_swap = 0

  local old_state = self._state
  self._state = new_state
  self.observer:observable_update(self, old_state)
end

-------------------------------------------------------------------------------
-- debug
-------------------------------------------------------------------------------

--#if debug
function gate:_tostring()
  return (type_string[self.type] or self.type) .. state_string[self._state]
end

--#endif

return gate
