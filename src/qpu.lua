---@diagnostic disable: lowercase-global, global-in-nil-env

function create_qpu(cursor)
  return setmetatable({
    cursor = cursor,
    commands = {},

    -- TODO: 引数に board を渡せるようにする
    init = function(_ENV)
      steps, score = 0, 0
    end,

    update = function(_ENV, board)
      -- QPU の入力
      left, right, up, down, x, o = false, false, false, false, false, false

      local next_action = commands[1]

      if next_action then
        del(commands, next_action)
        _ENV[next_action] = true
      else
        for new_y = 1, board.rows do
          for new_x = 1, board.cols do
            local each = board.reducible_gates[new_x][new_y]
            if not each then
              goto next_gate
            end

            -- TODO: new_y < board.rows and each:is_single_gate() の条件をまとめる
            if new_x < board.cols and new_y < board.rows and each:is_single_gate() then
              -- まずは平らに均す
              -- 連続して右に移動すると落とせるまたは消せる場合
              --
              --   X     or   X
              --   ■ ■ _      ■ ■ X
              for i = new_x + 1, board.cols do
                local gate_bottom_right = board.gates[i][new_y + 1]
                if board:is_gate_empty(i, new_y + 1) or (gate_bottom_right:is_idle() and gate_bottom_right.type == each.type) then
                  if board:is_gate_empty(new_x + 1, new_y) then
                    move_and_swap(_ENV, new_x, new_y)
                    return
                  else
                    break
                  end
                end
              end

              -- 入れ換えると右側がそろう場合
              --
              -- [X ?]
              --  ■ X
              local right_gate = board.gates[new_x + 1][new_y]
              if (right_gate:is_idle() and right_gate:is_single_gate() or board:is_gate_empty(new_x + 1, new_y)) and
                  each.type == board:reducible_gate_at(new_x + 1, new_y + 1).type then
                move_and_swap(_ENV, new_x, new_y)
                return
              end
            end

            if 1 < new_x and new_y < board.rows and each:is_single_gate() then
              -- まずは平らに均す
              -- 連続して左に移動すると落とせるまたは消せる場合
              --
              --      X   or     X
              --  _ ■ ■      X ■ ■
              for i = new_x - 1, 1, -1 do
                local gate_bottom_left = board.gates[i][new_y + 1]
                if board:is_gate_empty(i, new_y + 1) or (gate_bottom_left:is_idle() and gate_bottom_left.type == each.type) then
                  if board:is_gate_empty(new_x - 1, new_y) then
                    move_and_swap(_ENV, new_x - 1, new_y)
                    return
                  else
                    break
                  end
                end
              end

              -- 入れ換えると左側がそろう場合
              --
              -- [? X]
              --  X ■
              local left_gate = board.gates[new_x - 1][new_y]
              if (left_gate:is_idle() and left_gate:is_single_gate() or board:is_gate_empty(new_x - 1, new_y)) and
                  each.type == board:reducible_gate_at(new_x - 1, new_y + 1).type then
                move_and_swap(_ENV, new_x - 1, new_y)
                return
              end
            end

            -- 1. CNOT を縮める
            -- [X-]--C
            -- [C-]--X
            if (each:is_cnot_x() or each:is_control()) and new_x + 1 < each.other_x then
              move_and_swap(_ENV, new_x, new_y)
              return
            end

            -- 2. CNOT を同じ方向にそろえる
            -- C-X --> X-C
            if each:is_control() and each.other_x == new_x + 1 then
              move_and_swap(_ENV, new_x, new_y)
              return
            end

            -- 3. CNOT を右に移動
            -- X-[C ]
            if new_x < board.cols and
              each:is_control() and each.other_x < new_x and board:is_gate_empty(new_x + 1, new_y) then
              move_and_swap(_ENV, new_x, new_y)
              return
            end

            -- 下の X-C を左にずらして消す。
            --
            --  X-C
            -- [  X]-C
            if new_x > 1 and new_y > 1 and
              board:is_gate_empty(new_x - 1, new_y) and each:is_cnot_x() and each.other_x == new_x + 1 and
                board:reducible_gate_at(new_x, new_y - 1):is_control() and
                board:reducible_gate_at(new_x, new_y - 1).other_x == new_x - 1 then
              move_and_swap(_ENV, new_x - 1, new_y)
              move_and_swap(_ENV, new_x, new_y)
              return
            end

            ::next_gate::
          end
        end
      end
    end,

    move_and_swap = function(_ENV, new_x, new_y)
      if new_x < cursor.x then
        add_move_command(_ENV, "left", cursor.x - new_x)
      elseif cursor.x < new_x then
        add_move_command(_ENV, "right", new_x - cursor.x)
      end

      if new_y < cursor.y then
        add_move_command(_ENV, "up", cursor.y - new_y)
      elseif cursor.y < new_y then
        add_move_command(_ENV, "down", new_y - cursor.y)
      end

      add_swap_command(_ENV)
    end,

    add_move_command = function(_ENV, direction, count)
      for i = 1, count do
        add(commands, direction)
        add_sleep_command(_ENV, 5 + flr(rnd(10)))
      end
    end,

    add_swap_command = function(_ENV)
      add(commands, "o")
    end,

    add_sleep_command = function(_ENV, count)
      for i = 1, count do
        add(commands, "sleep")
      end
    end
  }, { __index = _ENV })
end
