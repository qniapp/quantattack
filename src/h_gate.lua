---@diagnostic disable: global-in-nil-env

require("gate_class")

function h_gate()
  local h = setmetatable({
    type = "h",

    is_single_gate = function()
      return true
    end,

    -- gate_class に移動
    is_fallable = function(_ENV)
      return not (is_swapping(_ENV) or is_freeze(_ENV))
    end,

    -------------------------------------------------------------------------------
    -- update and render
    -------------------------------------------------------------------------------

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
        elseif not is_i(_ENV) and right_gate:is_i() then -- 2.
          board.gates[other_x][y].other_x = new_x

          -- FIXME: is_i() は常に成り立たないので、次の elseif をなくす
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

    -- TODO: gate_class に移動
    fall = function(_ENV)
      assert(is_fallable(_ENV), "gate " .. type .. "(" .. x .. ", " .. y .. ")")

      if is_falling(_ENV) then
        return
      end

      _fall_screen_dy = 0

      change_state(_ENV, "falling")
    end,

    -------------------------------------------------------------------------------
    -- debug
    -------------------------------------------------------------------------------

    --#if debug
    _tostring = function(_ENV)
      return 'h' .. statestr[_state]
    end
    --#endif
  }, { __index = gate_class() }):_init()

  return h
end
