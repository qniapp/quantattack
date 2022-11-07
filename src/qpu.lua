---@diagnostic disable: lowercase-global, global-in-nil-env

function create_qpu(cursor)
  return setmetatable({
    cursor = cursor,
    commands = {},

    init = function(_ENV)
      steps, score = 0, 0
    end,

    update = function(_ENV, board)
      left, right, up, down, x, o = false, false, false, false, false, false

      local next_action = commands[1]

      if next_action then
        del(commands, next_action)
        _ENV[next_action] = true
      else
        if board:top_gate_y() > 5 then
          add_raise_command(_ENV)
          return
        end

        -- 上から探す
        for new_y = 2, board.rows - 1 do
          for new_x = 1, board.cols - 1 do
            local left_gate = board:reducible_gate_at(new_x, new_y)
            local right_gate = board:reducible_gate_at(new_x + 1, new_y)

            -- TODO: left_gate がおじゃまゲートの一部だった場合もはじく
            if not (left_gate:is_idle() and right_gate:is_idle()) then
              goto next_gate
            end

            -- 入れ替えることで右に落とせる場合
            --
            -- [X ]
            --  H
            if left_gate:is_single_gate() and board:is_empty(new_x + 1, new_y) and
                board:is_empty(new_x + 1, new_y + 1) then
              move_and_swap(_ENV, new_x, new_y)
              return
            end

            -- 以下の形をみつけたら、上の X-C を左にずらして消す。
            -- (QPU は X-C をどんどん右にずらすので、この形は頻発する)
            --
            -- [  X]-C
            --  X-C
            if board:is_empty(new_x, new_y) and right_gate:is_cnot_x() and right_gate.other_x == new_x + 2 and
                board:reducible_gate_at(new_x, new_y + 1):is_cnot_x() and board:reducible_gate_at(new_x, new_y + 1).other_x == new_x + 1 then
              move_and_swap(_ENV, new_x, new_y)
              move_and_swap(_ENV, new_x + 1, new_y)
              return
            end

            -- 同様に下の X-C を左にずらして消す。
            --
            --  X-C
            -- [  X]-C
            if new_y > 1 and
              board:is_empty(new_x, new_y) and right_gate:is_cnot_x() and right_gate.other_x == new_x + 2 and
                board:reducible_gate_at(new_x, new_y - 1):is_cnot_x() and board:reducible_gate_at(new_x, new_y - 1).other_x == new_x + 1 then
              move_and_swap(_ENV, new_x, new_y)
              move_and_swap(_ENV, new_x + 1, new_y)
              return
            end

            -- CNOT を消す戦略:
            --
            -- 1. CNOT を縮める
            -- [X-]--C
            -- [C-]--X
            --
            -- 2. CNOT を同じ方向にそろえる
            -- C-X --> X-C
            --
            -- 3. CNOT を右に移動
            -- X-[C ]
            if ((left_gate:is_cnot_x() or left_gate:is_control()) and new_x + 1 < left_gate.other_x) or
                (left_gate:is_control() and left_gate.other_x == new_x + 1) or
                (left_gate:is_control() and left_gate.other_x < new_x and board:is_empty(new_x + 1, new_y)) then
              move_and_swap(_ENV, new_x, new_y)
              return
            end

            -- 入れ換えると右側がそろう場合
            --
            -- [X  ]
            --  ■ X
            if left_gate:is_single_gate() and
                (right_gate:is_single_gate() or board:is_empty(new_x + 1, new_y)) and
                left_gate.type == board:reducible_gate_at(new_x + 1, new_y + 1).type then
              move_and_swap(_ENV, new_x, new_y)
              return
            end

            -- 入れ換えると左側がそろう場合
            --
            -- [  X]
            --  X ■
            if (left_gate:is_single_gate() or board:is_empty(new_x, new_y)) and
                right_gate:is_single_gate() and
                right_gate.type == board:reducible_gate_at(new_x, new_y + 1).type then
              move_and_swap(_ENV, new_x, new_y)
              return
            end

            -- 連続して左に移動すると落とせる場合
            -- 手数のかかる操作なので、優先度は一番下
            --
            --  [ X]
            --   HH
            if board:is_empty(new_x, new_y) and right_gate:is_single_gate() then
              for i = new_x, 1, -1 do
                if not board:is_empty(i, new_y) then
                  goto next_gate
                end
                if board:is_empty(i, new_y + 1) then
                  move_and_swap(_ENV, new_x, new_y)
                  return
                end
              end
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
        add_sleep_command(_ENV, 5)
      end
    end,

    add_swap_command = function(_ENV)
      add(commands, "o")
      add_sleep_command(_ENV, 10)
    end,

    add_raise_command = function(_ENV)
      add(commands, "x")
      add_sleep_command(_ENV, 3)
    end,

    add_sleep_command = function(_ENV, count)
      for i = 1, count do
        add(commands, "sleep")
      end
    end
  }, { __index = _ENV })
end
