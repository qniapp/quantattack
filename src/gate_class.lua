---@diagnostic disable: global-in-nil-env, lowercase-global, unbalanced-assignments

function gate_class()
  local gate_base = setmetatable({
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
    end,

    -------------------------------------------------------------------------------
    -- ゲートの種類
    -------------------------------------------------------------------------------

    is_control = function()
      return false
    end,

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

    is_fallable = function()
      return false
    end,

    is_reducible = function()
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

    is_falling = function(_ENV)
      return _state == "falling"
    end,

    -- マッチ状態である場合 true を返す
    is_match = function(_ENV)
      return _state == "match"
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
    -- update and render
    -------------------------------------------------------------------------------

    update = function(_ENV)
      if is_idle(_ENV) then
        _update_idle(_ENV)
      elseif is_swapping(_ENV) then
        _update_swap(_ENV)
      end
    end,

    _update_idle = function()
      -- NOP
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
  }, { __index = _ENV })

  gate_base:_init()

  return gate_base
end
