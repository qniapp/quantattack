---@diagnostic disable: global-in-nil-env, lowercase-global, unbalanced-assignments, undefined-field, undefined-global

local gate_match_animation_frame_count,
gate_match_delay_per_gate,
gate_swap_animation_frame_count =
45, 8, 4

local sprites = {
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

--- @param _type "i" | "h" | "x" | "y" | "z" | "s" | "t" | "control" | "cnot_x" | "swap" | "g" | "!" gate type
--- @param _span? 1 | 2 | 3 | 4 | 5 | 6 span of the gate
--- @param _height? integer height of the gate
function gate._init(_ENV, _type, _span, _height)
  type, span, height, _state, _fall_screen_dy = _type, _span or 1, _height or 1, "idle", 0
end

-------------------------------------------------------------------------------
-- ゲートの種類と状態
-------------------------------------------------------------------------------

function gate:is_idle()
  return self._state == "idle"
end

function gate.is_fallable(_ENV)
  return not (type == "i" or type == "!" or is_swapping(_ENV) or is_freeze(_ENV))
end

function gate:is_falling()
  return self._state == "falling"
end

function gate.is_reducible(_ENV)
  return type ~= "i" and type ~= "!" and is_idle(_ENV)
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

function gate.is_single_gate(_ENV)
  return type == 'h' or type == 'x' or type == 'y' or type == 'z' or type == 's' or type == 't'
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
function gate.replace_with(_ENV, other, match_index, _chain_id, garbage_span, garbage_height)
  new_gate, _match_index, _tick_match, chain_id, other.chain_id, _garbage_span, _garbage_height =
  other, match_index or 0, 1, _chain_id, _chain_id, garbage_span, garbage_height

  change_state(_ENV, "match")
end

-------------------------------------------------------------------------------
-- update and render
-------------------------------------------------------------------------------

function gate.update(_ENV)
  if is_idle(_ENV) then
    if _tick_landed then
      _tick_landed = _tick_landed + 1

      if _tick_landed == 13 then
        _tick_landed = nil
      end
    end
  elseif is_swapping(_ENV) then
    if _tick_swap < gate_swap_animation_frame_count then
      _tick_swap = _tick_swap + 1
    else
      chain_id = nil
      change_state(_ENV, "idle")
    end
  elseif is_falling(_ENV) then
    -- NOP
  elseif is_match(_ENV) then
    if _tick_match <= gate_match_animation_frame_count + _match_index * gate_match_delay_per_gate then
      _tick_match = _tick_match + 1
    else
      change_state(_ENV, "idle")

      if _garbage_span then
        new_gate._tick_freeze = 0
        new_gate._freeze_frame_count = (_garbage_span * _garbage_height - _match_index) * gate_match_delay_per_gate
        new_gate:change_state("freeze")
      end
    end
  elseif is_freeze(_ENV) then
    if _tick_freeze < _freeze_frame_count then
      _tick_freeze = _tick_freeze + 1
    else
      change_state(_ENV, "idle")
    end
  end
end

--- @param screen_x integer x position of the screen
--- @param screen_y integer y position of the screen
function gate:render(screen_x, screen_y)
  local shake_dx, shake_dy, swap_screen_dx, sprite = 0, 0

  do
    local _ENV = self

    if type == "i" then
      return
    end

    swap_screen_dx = (_tick_swap or 0) * (8 / gate_swap_animation_frame_count)
    if _is_swapping_with_left(_ENV) then
      swap_screen_dx = -swap_screen_dx
    end

    local sprite_set = sprites[type]

    if is_idle(_ENV) and _tick_landed then
      sprite = sprite_set.landed[_tick_landed]
    elseif is_match(_ENV) then
      local sequence = sprite_set.match
      sprite = _tick_match <= gate_match_delay_per_gate and sequence[_tick_match] or sequence[#sequence]
    elseif _state == "over" then
      sprite = sprite_set.match[#sprite_set.match]
    else
      sprite = sprite_set.default
    end
  end

  if type == "!" then
    palt(0, false)
    pal(13, self.body_color)
  end

  if _state == "over" then
    shake_dx, shake_dy = rnd(2) - 1, rnd(2) - 1
    pal(13, 9)
    pal(7, 1)
  end

  spr(sprite, screen_x + swap_screen_dx + shake_dx, screen_y + self._fall_screen_dy + shake_dy)

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
function gate.change_state(_ENV, new_state)
  _tick_swap = 0

  local old_state = _state
  _state = new_state
  observer:observable_update(_ENV, old_state)
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
