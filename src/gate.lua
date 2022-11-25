---@diagnostic disable: global-in-nil-env, lowercase-global, unbalanced-assignments

require("particle")

gate_match_animation_frame_count = 45
gate_match_delay_per_gate = 8
gate_swap_animation_frame_count = 4
gate_fall_speed = 2

local sprites = {
  -- default|landed|match|over
  h = "0|16,16,16,16,48,48,32,32,32,16,16,16|9,9,9,25,25,25,9,9,9,41,41,41,0,0,0,57|117",
  x = "1|17,17,17,17,49,49,33,33,33,17,17,17|10,10,10,26,26,26,10,10,10,42,42,42,1,1,1,58|70",
  y = "2|18,18,18,18,50,50,34,34,34,18,18,18|11,11,11,27,27,27,11,11,11,43,43,43,2,2,2,59|86",
  z = "3|19,19,19,19,51,51,35,35,35,19,19,19|12,12,12,28,28,28,12,12,12,44,44,44,3,3,3,60|102",
  s = "4|20,20,20,20,52,52,36,36,36,20,20,20|13,13,13,29,29,29,13,13,13,45,45,45,4,4,4,61|118",
  t = "5|21,21,21,21,53,53,37,37,37,21,21,21|14,14,14,30,30,30,14,14,14,46,46,46,5,5,5,62|71",
  control = "6|22,22,22,22,54,54,38,38,38,22,22,22|15,15,15,31,31,31,15,15,15,47,47,47,6,6,6,63|87",
  cnot_x = "7|23,23,23,23,55,55,39,39,39,23,23,23|64,64,64,80,80,80,64,64,64,96,96,96,7,7,7,112|70",
  swap = "8|24,24,24,24,56,56,40,40,40,24,24,24|65,65,65,81,81,81,65,65,65,97,97,97,8,8,8,113|103",
  ["!"] = "101|101,101,101,101,101,101,101,101,101,101,101,101|101,101,101,101,101,101,101,101,101,101,101,101,101,101,101,101|119"
}

for key, each in pairs(sprites) do
  local default, landed, match, over = unpack(split(each, "|"))
  ---@diagnostic disable-next-line: assign-type-mismatch
  sprites[key] = {
    default = default,
    landed = split(landed),
    match = split(match),
    over = over
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


--- @param type "i" | "h" | "x" | "y" | "z" | "s" | "t" | "control" | "cnot_x" | "swap" | "g" | "!" gate type
--- @param span? 1 | 2 | 3 | 4 | 5 | 6 span of the gate
--- @param height? integer height of the gate
--- @return Gate
function gate(type, span, height)
  --#if assert
  assert(type == "i" or type == "h" or type == "x" or type == "y" or type == "z" or
    type == "s" or type == "t" or type == "control" or type == "cnot_x" or type == "swap" or
    type == "g" or type == "!",
    "invalid type: " .. type)
  --#endif

  local gate_base = setmetatable({
    type = type,
    span = span or 1,
    height = height or 1,

    --- @param _ENV Gate
    _init = function(_ENV)
      _state, _fall_screen_dy = "idle", 0
      return _ENV
    end,

    -------------------------------------------------------------------------------
    -- ゲートの種類と状態
    -------------------------------------------------------------------------------

    --- @param _ENV Gate
    is_idle = function(_ENV)
      return _state == "idle"
    end,

    --- @param _ENV Gate
    is_fallable = function(_ENV)
      return not (type == "i" or type == "!" or is_swapping(_ENV) or is_freeze(_ENV))
    end,

    --- @param _ENV Gate
    is_falling = function(_ENV)
      return _state == "falling"
    end,

    --- @param _ENV Gate
    is_reducible = function(_ENV)
      return type ~= "i" and type ~= "!" and is_idle(_ENV)
    end,

    -- マッチ状態である場合 true を返す
    --- @param _ENV Gate
    is_match = function(_ENV)
      return _state == "match"
    end,

    -- おじゃまユニタリがゲートに変化した後の硬直中
    --- @param _ENV Gate
    is_freeze = function(_ENV)
      return _state == "freeze"
    end,

    --- @param _ENV Gate
    is_swapping = function(_ENV)
      return _is_swapping_with_right(_ENV) or _is_swapping_with_left(_ENV)
    end,

    --- @private
    --- @param _ENV Gate
    _is_swapping_with_left = function(_ENV)
      return _state == "swapping_with_left"
    end,

    --- @private
    --- @param _ENV Gate
    _is_swapping_with_right = function(_ENV)
      return _state == "swapping_with_right"
    end,

    --- @param _ENV Gate
    is_empty = function(_ENV)
      return type == "i" and not is_swapping(_ENV)
    end,

    --- @param _ENV Gate
    is_single_gate = function(_ENV)
      return type == 'h' or type == 'x' or type == 'y' or type == 'z' or type == 's' or type == 't'
    end,

    -------------------------------------------------------------------------------
    -- ゲート操作
    -------------------------------------------------------------------------------

    --- @param _ENV Gate
    swap_with_right = function(_ENV)
      chain_id = nil

      change_state(_ENV, "swapping_with_right")
    end,

    --- @param _ENV Gate
    swap_with_left = function(_ENV)
      chain_id = nil

      change_state(_ENV, "swapping_with_left")
    end,

    --- @param _ENV Gate
    fall = function(_ENV)
      --#if assert
      assert(is_fallable(_ENV), "gate " .. type .. "(" .. x .. ", " .. y .. ")")
      --#endif

      if is_falling(_ENV) then
        return
      end

      _fall_screen_dy = 0

      change_state(_ENV, "falling")
    end,

    --- @param _ENV Gate
    --- @param other Gate
    --- @param match_index integer
    --- @param _chain_id string
    --- @param garbage_span? integer
    --- @param garbage_height? integer
    replace_with = function(_ENV, other, match_index, _chain_id, garbage_span, garbage_height)
      new_gate, _match_index, _tick_match, chain_id, other.chain_id, _garbage_span, _garbage_height =
      other, match_index or 0, 1, _chain_id, _chain_id, garbage_span, garbage_height

      change_state(_ENV, "match")
    end,

    -------------------------------------------------------------------------------
    -- update and render
    -------------------------------------------------------------------------------

    --- @param _ENV Gate
    update = function(_ENV)
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
          sfx(3, -1, (_match_index % 6 - 1) * 4, 4)
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
    end,

    --- @param _ENV Gate
    --- @param screen_x integer x position of the screen
    --- @param screen_y integer y position of the screen
    render = function(_ENV, screen_x, screen_y)
      if type == "i" then
        return
      end

      local swap_screen_dx = (_tick_swap or 0) * (8 / gate_swap_animation_frame_count)
      if _is_swapping_with_left(_ENV) then
        swap_screen_dx = -swap_screen_dx
      end

      local sprite_set, sprite = sprites[type]
      local shake_dx, shake_dy = 0, 0

      if is_idle(_ENV) and _tick_landed then
        sprite = sprite_set.landed[_tick_landed]
      elseif is_match(_ENV) then
        local sequence = sprite_set.match
        sprite = _tick_match <= gate_match_delay_per_gate and sequence[_tick_match] or sequence[#sequence]
      elseif _state == "over" then
        shake_dx, shake_dy = rnd(2) - 1, rnd(2) - 1
        sprite = sprite_set.match[#sprite_set.match]
      else
        sprite = sprite_set.default
      end

      if type == "!" then
        palt(0, false)
        pal(13, body_color)
      end

      if _state == "over" then
        pal(13, 9)
        pal(7, 1)
      end

      spr(sprite, screen_x + swap_screen_dx + shake_dx, screen_y + _fall_screen_dy + shake_dy)

      palt()
      pal()
    end,

    -------------------------------------------------------------------------------
    -- observer pattern
    -------------------------------------------------------------------------------

    --- @param _ENV Gate
    --- @param _observer table
    attach = function(_ENV, _observer)
      observer = _observer
    end,

    --- @param _ENV Gate
    --- @param new_state string
    change_state = function(_ENV, new_state)
      _tick_swap = 0

      local old_state = _state
      _state = new_state
      observer:observable_update(_ENV, old_state)
    end,

    -------------------------------------------------------------------------------
    -- debug
    -------------------------------------------------------------------------------

    --#if debug
    --- @param _ENV Gate
    _tostring = function(_ENV)
      return (type_string[type] or type) .. state_string[_state]
    end
    --#endif
  }, { __index = _ENV })

  gate_base:_init()

  --#if assert
  assert(0 < gate_base.span, "span must be greater than 0")
  assert(gate_base.span < 7, "span must be less than 7")
  assert(type == "g" or
    ((type == "i" or type == "h" or type == "x" or type == "y" or type == "z" or
        type == "s" or type == "t" or
        type == "control" or type == "cnot_x" or type == "swap" or type == "!") and
        gate_base.span == 1),
    "invalid span: " .. gate_base.span)
  assert(gate_base.height > 0, "height must be greater than 0")
  assert(type == "g" or
    ((type == "i" or type == "h" or type == "x" or type == "y" or type == "z" or
        type == "s" or type == "t" or
        type == "control" or type == "cnot_x" or type == "swap" or type == "!") and
        gate_base.height == 1),
    "invalid height: " .. gate_base.height)
  --#endif

  return gate_base
end
