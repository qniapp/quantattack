---@diagnostic disable: global-in-nil-env, lowercase-global, unbalanced-assignments

require("gate_class")

function i_gate()
  local i = setmetatable({
    is_i = function()
      return true
    end,

    is_empty = function(_ENV)
      return not is_swapping(_ENV)
    end,

    is_reducible = function()
      return false
    end,

    -------------------------------------------------------------------------------
    -- update and render
    -------------------------------------------------------------------------------

    _update_swap = function(_ENV)
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

          -- FIXME: is_i() は常に成り立つので、次の elseif をなくす
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

    -------------------------------------------------------------------------------
    -- debug
    -------------------------------------------------------------------------------

    --#if debug
    _tostring = function(_ENV)
      return '_' .. statestr[_state]
    end
    --#endif
  }, { __index = gate_class() }):_init()

  return i
end
