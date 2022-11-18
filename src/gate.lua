---@diagnostic disable: global-in-nil-env, lowercase-global

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

function create_gate(_type, _span, _height)
  return setmetatable({
    type = _type,
    span = _span or 1,
    height = _height or 1,
    _state = "idle",
    _fall_screen_dy = 0,

    -------------------------------------------------------------------------------
    -- gate state
    -------------------------------------------------------------------------------

    -- ゲートが idle である場合 true を返す
    is_idle = function(_ENV)
      return _state == "idle"
    end,

    -- 他のゲートが通過 (ドロップ) できる場合 true を返す
    is_empty = function(_ENV)
      return type == "i" and not is_swapping(_ENV)
    end,

    -- マッチ状態である場合 true を返す
    is_match = function(_ENV)
      return _state == "match"
    end,

    -- おじゃまユニタリがゲートに変化した後の硬直中
    is_freeze = function(_ENV)
      return _state == "freeze"
    end,

    -- マッチできる場合 true を返す
    is_reducible = function(_ENV)
      return type ~= "i" and type ~= "!" and is_idle(_ENV)
    end,

    is_falling = function(_ENV)
      return _state == "falling"
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

    -- ゲートが下に落とせる状態にあるかどうかを返す
    is_fallable = function(_ENV)
      return not (type == "i" or type == "!" or is_swapping(_ENV) or is_freeze(_ENV))
    end,

    -------------------------------------------------------------------------------
    -- gate type
    -------------------------------------------------------------------------------

    is_i = function(_ENV)
      return type == "i"
    end,

    is_control = function(_ENV)
      return type == "control"
    end,

    is_cnot_x = function(_ENV)
      return type == "cnot_x"
    end,

    is_swap = function(_ENV)
      return type == "swap"
    end,

    -- おじゃまゲートの先頭 (左下) である場合 true を返す
    --
    -- 注: ゲートがおじゃまゲートの一部であるかどうかを判定するには、
    -- board:_is_part_of_garbage(x, y) を使う
    is_garbage = function(_ENV)
      return type == "g"
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

    replace_with = function(_ENV, other, match_index, garbage_span, garbage_height, _chain_id)
      new_gate, _match_index, _garbage_span, _garbage_height, _tick_match, chain_id, other.chain_id =
      other, match_index or 0, garbage_span, garbage_height, 1, _chain_id, _chain_id

      change_state(_ENV, "match")
    end,

    fall = function(_ENV)
      assert(is_fallable(_ENV), "gate " .. type .. "(" .. x .. ", " .. y .. ")")

      if is_falling(_ENV) then
        return
      end

      _fall_screen_dy = 0

      change_state(_ENV, "falling")
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
        assert(not is_garbage(_ENV))

        if _tick_swap < gate_swap_animation_frame_count then
          _tick_swap = _tick_swap + 1
        else
          -- SWAP 完了
          local new_x = x + 1
          local right_gate = board.gates[new_x][y]

          assert(_is_swapping_with_right(_ENV), "_state = " .. _state)
          assert(right_gate:_is_swapping_with_left(), right_gate._state)

          if right_gate.type ~= "i" then
            create_particle_set(board:screen_x(x) - 2, board:screen_y(y) + 3,
              "1,yellow,yellow,5,left|1,yellow,yellow,5,left|0,yellow,yellow,5,left|0,yellow,yellow,5,left")
          end
          if type ~= "i" then
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

          -- 次の board:put で x の値が変化するので、
          -- もともとの x の値をバックアップしていく
          local orig_x = x

          board:put(new_x, y, _ENV)
          board:put(orig_x, y, right_gate)

          if other_x == nil and right_gate.other_x == nil then -- 1.
            -- NOP
          elseif type ~= "i" and right_gate.type == "i" then -- 2.
            board.gates[other_x][y].other_x = new_x
          elseif type == "i" and right_gate.type ~= "i" then -- 3.
            board.gates[right_gate.other_x][y].other_x = orig_x
          elseif other_x and right_gate.other_x then -- 4.
            other_x, right_gate.other_x = orig_x, new_x
          else
            assert(false, "we should not reach here")
          end

          chain_id, right_gate.chain_id = nil, nil

          change_state(_ENV, "idle")
          right_gate:change_state("idle")
        end
      elseif is_falling(_ENV) then
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
      elseif is_match(_ENV) then
        assert(not is_garbage(_ENV))

        if _tick_match <= gate_match_animation_frame_count + _match_index * gate_match_delay_per_gate then
          _tick_match = _tick_match + 1
        else
          board:put(x, y, new_gate)

          sfx(3, -1, (_match_index % 6 - 1) * 4, 4)
          create_particle_set(board:screen_x(x) + 3, board:screen_y(y) + 3,
            "3,white,dark_gray,20|3,white,dark_gray,20|2,white,dark_gray,20|2,dark_purple,dark_gray,20|2,light_gray,dark_gray,20|1,white,dark_gray,20|1,white,dark_gray,20|1,light_gray,dark_gray,20|1,light_gray,dark_gray,20|0,dark_purple,dark_gray,20")

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
    -- observer pattern methods
    -------------------------------------------------------------------------------

    -- オブザーバ (board) を登録する
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

      return (typestr[type] or type) .. statestr[_state]
    end
    --#endif
  }, { __index = _ENV })
end

-------------------------------------------------------------------------------
-- helpers
-------------------------------------------------------------------------------

function cnot_x_gate(other_x)
  local cnot_x = create_gate('cnot_x')
  cnot_x.other_x = other_x
  return cnot_x
end

function swap_gate(other_x)
  local swap = create_gate('swap')
  swap.other_x = other_x
  return swap
end

function garbage_gate(_span, _height, _color)
  assert(_span)

  local garbage = create_gate('g', _span, _height)
  garbage.color = _color or 2

  if garbage.color == 2 then
    garbage.inner_border_color = 14
  elseif garbage.color == 3 then
    garbage.inner_border_color = 11
  elseif garbage.color == 4 then
    garbage.inner_border_color = 9
  end

  garbage.render = function(_ENV)
    local x0, y0, x1, y1, bg_color = board:screen_x(x), board:screen_y(y - height + 1) + _fall_screen_dy,
        board:screen_x(x + span) - 2, board:screen_y(y + 1) - 2 + _fall_screen_dy,
        _state ~= "over" and garbage.color or 5
    draw_rounded_box(x0, y0 + 1, x1, y1 + 1, 1, 1) -- 影
    draw_rounded_box(x0, y0, x1, y1, bg_color, bg_color) -- 本体
    draw_rounded_box(x0 + 1, y0 + 1, x1 - 1, y1 - 1, _state ~= "over" and garbage.inner_border_color or 1) -- 内側の線
  end

  garbage._garbage_first_drop = true

  return garbage
end

function garbage_match_gate()
  return create_gate('!')
end
