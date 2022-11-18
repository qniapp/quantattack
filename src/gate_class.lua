---@diagnostic disable: global-in-nil-env, lowercase-global, unbalanced-assignments

function gate_class()
  local gate_base = setmetatable({
    span = 1,
    gate_swap_animation_frame_count = 4,

    --#if debug
    statestr = {
      idle = " ",
      swapping_with_left = "<",
      swapping_with_right = ">",
    },
    --#endif

    _init = function(_ENV)
      _state = "idle"
      return _ENV
    end,

    -------------------------------------------------------------------------------
    -- ゲートの種類
    -------------------------------------------------------------------------------

    -- TODO: たいして短くならないので、このメソッドを消す
    -- そもそも、子クラスの情報が親 (gate_class) に入ってるのがおかしい
    is_cnot_x = function()
      return false
    end,

    is_swap = function()
      return false
    end,

    -- おじゃまゲートの先頭 (おじゃまゲート全体の左下) である場合 true を返す
    is_garbage = function()
      return false
    end,

    is_single_gate = function()
      return false
    end,

    -------------------------------------------------------------------------------
    -- ゲートの状態
    -------------------------------------------------------------------------------

    is_idle = function(_ENV)
      return _state == "idle"
    end,

    is_fallable = function(_ENV)
      return not (is_swapping(_ENV) or is_freeze(_ENV))
    end,

    is_falling = function(_ENV)
      return _state == "falling"
    end,

    is_reducible = function(_ENV)
      return is_idle(_ENV)
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
      return false
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
        _update_idle(_ENV)
      elseif is_swapping(_ENV) then
        _update_swap(_ENV)
      elseif is_falling(_ENV) then
        _update_falling(_ENV)
      elseif is_match(_ENV) then
        _update_match(_ENV)
      elseif is_freeze(_ENV) then
        _update_freeze(_ENV)
      end
    end,

    _update_idle = function()
      -- NOP
    end,

    _update_swap = function(_ENV)
      if _tick_swap < gate_swap_animation_frame_count then
        _tick_swap = _tick_swap + 1
      else
        -- FIXME: 以下の処理はそもそも board 側でやるのが正しい

        -- SWAP 完了
        local new_x = x + 1
        local orig_x = x
        local right_gate = board.gates[new_x][y]

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

        change_state(_ENV, "idle")
        right_gate:change_state("idle")
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

    _update_match = function(_ENV)
      if _tick_match <= gate_match_animation_frame_count + _match_index * gate_match_delay_per_gate then
        _tick_match = _tick_match + 1
      else
        board:put(x, y, new_gate)
      end
    end,

    _update_freeze = function(_ENV)
      if _tick_freeze < _freeze_frame_count then
        _tick_freeze = _tick_freeze + 1
      else
        change_state(_ENV, "idle")
      end
    end,

    render = function()
      -- NOP
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
