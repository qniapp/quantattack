---@diagnostic disable: global-in-nil-env, lowercase-global, unbalanced-assignments

require("particle")

gate_match_animation_frame_count = 45
gate_match_delay_per_gate = 8
gate_swap_animation_frame_count = 4
gate_fall_speed = 2

local sprites = {
  h = {
    default = 0,
    landed = split("16,16,16,16,48,48,32,32,32,16,16,16"),
    match = split("9,9,9,25,25,25,9,9,9,41,41,41,0,0,0,57"),
    over = 87,
  },
  x = {
    default = 1,
    landed = split("17,17,17,17,49,49,33,33,33,17,17,17"),
    match = split("10,10,10,26,26,26,10,10,10,42,42,42,1,1,1,58"),
    over = 103,
  },
  y = {
    default = 2,
    landed = split("18,18,18,18,50,50,34,34,34,18,18,18"),
    match = split("11,11,11,27,27,27,11,11,11,43,43,43,2,2,2,59"),
    over = 119,
  },
  z = {
    default = 3,
    landed = split("19,19,19,19,51,51,35,35,35,19,19,19"),
    match = split("12,12,12,28,28,28,12,12,12,44,44,44,3,3,3,60"),
    over = 72
  },
  s = {
    default = 4,
    landed = split("20,20,20,20,52,52,36,36,36,20,20,20"),
    match = split("13,13,13,29,29,29,13,13,13,45,45,45,4,4,4,61"),
    over = 88
  },
  t = {
    default = 5,
    landed = split("21,21,21,21,53,53,37,37,37,21,21,21"),
    match = split("14,14,14,30,30,30,14,14,14,46,46,46,5,5,5,62"),
    over = 104
  },
  control = {
    default = 6,
    landed = split("22,22,22,22,54,54,38,38,38,22,22,22"),
    match = split("15,15,15,31,31,31,15,15,15,47,47,47,6,6,6,63"),
    over = 120
  },
  cnot_x = {
    default = 7,
    landed = split("23,23,23,23,55,55,39,39,39,23,23,23"),
    match = split("64,64,64,80,80,80,64,64,64,96,96,96,7,7,7,112"),
    over = 103
  },
  swap = {
    default = 8,
    landed = split("24,24,24,24,56,56,40,40,40,24,24,24"),
    match = split("65,65,65,81,81,81,65,65,65,97,97,97,8,8,8,113"),
    over = 73
  },
  ["!"] = {
    default = 101,
    landed = split("101,101,101,101,101,101,101,101,101,101,101,101"),
    match = split("101,101,101,101,101,101,101,101,101,101,101,101,101,101,101,101"),
    over = 89
  },
}

function gate_class(_type)
  local gate_base = setmetatable({
    type = _type,
    span = 1,
    height = 1,

    --#if debug
    statestr = {
      idle = " ",
      swapping_with_left = "<",
      swapping_with_right = ">",
      match = "*",
      freeze = "f",
    },
    --#endif

    _init = function(_ENV)
      _state = "idle"
      _fall_screen_dy = 0
      return _ENV
    end,

    -------------------------------------------------------------------------------
    -- ゲートの種類と状態
    -------------------------------------------------------------------------------

    is_idle = function(_ENV)
      return _state == "idle"
    end,

    is_fallable = function(_ENV)
      return not (type == "i" or type == "!" or is_swapping(_ENV) or is_freeze(_ENV))
    end,

    is_falling = function(_ENV)
      return _state == "falling"
    end,

    is_reducible = function(_ENV)
      return type ~= "i" and type ~= "!" and is_idle(_ENV)
    end,

    -- マッチ状態である場合 true を返す
    is_match = function(_ENV)
      return _state == "match"
    end,

    -- おじゃまユニタリがゲートに変化した後の硬直中
    is_freeze = function(_ENV)
      return _state == "freeze"
    end,

    is_swapping = function(_ENV)
      return _is_swapping_with_right(_ENV) or _is_swapping_with_left(_ENV)
    end,

    _is_swapping_with_left = function(_ENV)
      return _state == "swapping_with_left"
    end,

    _is_swapping_with_right = function(_ENV)
      return _state == "swapping_with_right"
    end,

    is_empty = function(_ENV)
      return type == "i" and not is_swapping(_ENV)
    end,

    is_single_gate = function(_ENV)
      return type == 'h' or type == 'x' or type == 'y' or type == 'z' or type == 's' or type == 't'
    end,

    -------------------------------------------------------------------------------
    -- ゲート操作
    -------------------------------------------------------------------------------

    swap_with_right = function(_ENV)
      _tick_swap, chain_id = 0

      change_state(_ENV, "swapping_with_right")
    end,

    swap_with_left = function(_ENV)
      _tick_swap, chain_id = 0

      change_state(_ENV, "swapping_with_left")
    end,

    fall = function(_ENV)
      assert(is_fallable(_ENV), "gate " .. type .. "(" .. x .. ", " .. y .. ")")

      -- ???: すでに落ちてるやつは fall() を呼ばれるべきではない?
      if is_falling(_ENV) then
        return
      end

      _fall_screen_dy = 0

      change_state(_ENV, "falling")
    end,

    -- FIXME: 引数の整理 (なんで garbage_span や garbage_height があるんだっけ?)
    replace_with = function(_ENV, other, match_index, garbage_span, garbage_height, _chain_id)
      new_gate, _match_index, _garbage_span, _garbage_height, _tick_match, chain_id, other.chain_id =
      other, match_index or 0, garbage_span, garbage_height, 1, _chain_id, _chain_id

      change_state(_ENV, "match")
    end,

    -------------------------------------------------------------------------------
    -- update and render
    -------------------------------------------------------------------------------

    update = function(_ENV)
      if is_idle(_ENV) then
        if chain_id and board.gates[x][y + 1].chain_id == nil then
          chain_id = nil
        end

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
        _update_falling(_ENV)
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

    -- FIXME: board 側でやる
    _update_falling = function(_ENV)
      -- 一個下が空いていない場合、落下を終了
      if not board:is_gate_fallable(x, y) then
        -- おじゃまユニタリの最初の落下
        if _garbage_first_drop then
          board:bounce()
          sfx(1)
          _garbage_first_drop = false
        else
          sfx(4)
        end

        _fall_screen_dy = 0
        _tick_landed = 1

        change_state(_ENV, "idle")

        if other_x and x < other_x then
          local other_gate = board.gates[other_x][y]
          other_gate._tick_landed = 1
          other_gate._fall_screen_dy = 0

          other_gate:change_state("idle")
        end
      else
        _fall_screen_dy = _fall_screen_dy + gate_fall_speed

        local new_y = y

        if _fall_screen_dy >= 8 then
          new_y = new_y + 1
        end

        if new_y == y then
          -- 同じ場所にとどまっている場合、何もしない
        elseif board:is_gate_fallable(x, y) then
          local orig_y = y

          -- 一個下が空いている場合、そこに移動する
          board:remove_gate(x, y)
          board:put(x, new_y, _ENV)
          _fall_screen_dy = _fall_screen_dy - 8

          if other_x and x < other_x then
            local other_gate = board.gates[other_x][orig_y]
            board:remove_gate(other_x, orig_y)
            board:put(other_x, new_y, other_gate)
            other_gate._fall_screen_dy = _fall_screen_dy
          end
        end
      end
    end,

    render = function(_ENV)
      if type == "i" then
        return
      end

      local swap_screen_dx = 0
      local diff = (_tick_swap or 0) * (8 / gate_swap_animation_frame_count)
      if _is_swapping_with_right(_ENV) then
        swap_screen_dx = diff
      elseif _is_swapping_with_left(_ENV) then
        swap_screen_dx = -diff
      end

      if type == "!" then
        palt(0, false)
      end

      spr(_sprite(_ENV), board:screen_x(x) + swap_screen_dx, board:screen_y(y) + _fall_screen_dy)

      palt()
    end,

    _sprite = function(_ENV)
      local sprite_set = sprites[type]

      if is_idle(_ENV) and _tick_landed then
        return sprite_set.landed[_tick_landed]
      elseif is_match(_ENV) then
        local sequence = sprite_set.match
        return _tick_match <= gate_match_delay_per_gate and sequence[_tick_match] or sequence[#sequence]
      elseif _state == "over" then
        return sprite_set.over
      else
        return sprite_set.default
      end
    end,

    -------------------------------------------------------------------------------
    -- 変更を board へ通知 (オブザーバパターン)
    -------------------------------------------------------------------------------

    attach = function(_ENV, _board)
      board = _board
    end,

    change_state = function(_ENV, new_state)
      local old_state = _state
      _state = new_state
      board:gate_update(_ENV, old_state)
    end,

    -------------------------------------------------------------------------------
    -- debug
    -------------------------------------------------------------------------------

    --#if debug
    _tostring = function(_ENV)
      return (type_string or type) .. statestr[_state]
    end
    --#endif
  }, { __index = _ENV })

  gate_base:_init()

  return gate_base
end
