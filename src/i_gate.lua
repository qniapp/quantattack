---@diagnostic disable: global-in-nil-env, lowercase-global, unbalanced-assignments
function gate_class()
  local gate_base = setmetatable({
    _init = function(_ENV)
      _state = "idle"
    end,
  }, { __index = _ENV })

  gate_base:_init()

  return gate_base
end

function i_gate()
  local i = setmetatable({
    gate_swap_animation_frame_count = 4,

    -- TODO: gate ベースクラスから継承して、ここには何も書かなくていいようにする
    _init = function(_ENV)
      _state = "idle"
    end,

    -------------------------------------------------------------------------------
    -- update and render
    -------------------------------------------------------------------------------

    update = function(_ENV)
      if is_idle(_ENV) then
        _update_idle(_ENV)
      elseif is_swapping(_ENV) then
        _update_swap(_ENV)
      end
    end,

    -- TODO: gate ベースクラスから継承して、ここには何も書かなくていいようにする
    _update_idle = function(_ENV)
    end,

    _update_swap = function(_ENV)
      -- TODO: update_swap() とする
      -- TODO: そもそもちゃんと 4 フレームで終わってるか確認
      if _tick_swap < gate_swap_animation_frame_count then
        _tick_swap = _tick_swap + 1
      else
        -- SWAP 完了
        local new_x = x + 1
        local orig_x = x
        local right_gate = board.gates[new_x][y]

        -- FIXME: この処理はそもそも board 側でやるのが正しい
        board:put(new_x, y, _ENV)
        board:put(orig_x, y, right_gate)

        if other_x == nil and right_gate.other_x == nil then -- 1.
          -- NOP
        elseif not is_i(_ENV) and right_gate:is_i() then -- 2.
          board.gates[other_x][y].other_x = new_x
        elseif is_i(_ENV) and not right_gate:is_i() then -- 3.
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

    -- TODO: gate ベースクラスから継承して、ここには何も書かなくていいようにする
    render = function(_ENV)
      -- NOP
    end,

    -------------------------------------------------------------------------------
    -- ゲートの種類
    -------------------------------------------------------------------------------

    -- おじゃまゲートの先頭 (おじゃまゲート全体の左下) である場合 true を返す
    -- TODO: gate ベースクラスから継承して、デフォルト false を返すようにする
    -- TODO: is_garbage_head() に名前を変更
    -- TODO: 引数の _ENV いらない
    is_garbage = function(_ENV)
      return false
    end,

    -- TODO: 引数の _ENV いらない
    is_i = function(_ENV)
      return true
    end,

    -- TODO: gate ベースクラスから継承、デフォルト false
    -- TODO: 引数の _ENV いらない
    is_control = function(_ENV)
      return false
    end,

    -- TODO: gate ベースクラスから継承、デフォルト false
    -- TODO: 引数の _ENV いらない
    is_cnot_x = function(_ENV)
      return false
    end,

    -- TODO: gate ベースクラスから継承、デフォルト false
    -- TODO: 引数の _ENV いらない
    is_swap = function(_ENV)
      return false
    end,

    -- TODO: gate ベースクラスから継承、デフォルト false
    -- TODO: 引数の _ENV いらない
    is_single_gate = function(_ENV)
      return false
    end,

    -- TODO: gate ベースクラスから継承して、デフォルト false を返すようにする
    -- TODO: 引数の _ENV いらない
    is_reducible = function(_ENV)
      return false
    end,

    -- TODO: gate ベースクラスから継承して、デフォルト false を返すようにする
    -- TODO: 引数の _ENV いらない
    is_fallable = function(_ENV)
      return false
    end,

    -------------------------------------------------------------------------------
    -- ゲートの状態
    -------------------------------------------------------------------------------

    -- TODO: gate ベースクラスから継承
    is_idle = function(_ENV)
      return _state == "idle"
    end,

    is_empty = function(_ENV)
      return not is_swapping(_ENV)
    end,

    -- TODO: gate ベースクラスから継承
    -- ???: そのそも I ゲートは falling 状態にならないから、デフォルト false でよい?
    is_falling = function(_ENV)
      return _state == "falling"
    end,

    -- マッチ状態である場合 true を返す
    -- TODO: gate ベースクラスから継承
    is_match = function(_ENV)
      return _state == "match"
    end,

    -- TODO: gate ベースクラスから継承
    is_swapping = function(_ENV)
      return _is_swapping_with_right(_ENV) or _is_swapping_with_left(_ENV)
    end,

    -- TODO: gate ベースクラスから継承
    _is_swapping_with_left = function(_ENV)
      return _state == "swapping_with_left"
    end,

    -- TODO: gate ベースクラスから継承
    _is_swapping_with_right = function(_ENV)
      return _state == "swapping_with_right"
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

    -------------------------------------------------------------------------------
    -- 未整理
    -------------------------------------------------------------------------------

    -- TODO: gate ベースクラスから継承する
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
      local statestr =
      {
        idle = " ",
        swapping_with_left = "<",
        swapping_with_right = ">",
      }

      return '_' .. statestr[_state]
    end
    --#endif
  }, { __index = _ENV })

  i:_init()

  return i
end
