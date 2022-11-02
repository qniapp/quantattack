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

        for new_x = 1, board.cols - 1 do
          for new_y = board.rows - 1, 1, -1 do
            local left_gate = board:reducible_gate_at(new_x, new_y)
            local right_gate = board:reducible_gate_at(new_x + 1, new_y)

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
            if board:is_single_gate(new_x, new_y) and
                (board:is_single_gate(new_x + 1, new_y) or board:is_empty(new_x + 1, new_y)) and
                left_gate.type == board:reducible_gate_at(new_x + 1, new_y + 1).type then
              move_and_swap(_ENV, new_x, new_y)
              return
            end

            -- 入れ換えると左側がそろう場合
            --
            -- [  X]
            --  X ■
            if (board:is_single_gate(new_x, new_y) or board:is_empty(new_x, new_y)) and
                board:is_single_gate(new_x + 1, new_y) and
                right_gate.type == board:reducible_gate_at(new_x, new_y + 1).type then
              move_and_swap(_ENV, new_x, new_y)
              return
            end

            -- 入れ替えることで右に落とせる場合
            --
            -- [X  ]
            --  H
            if board:is_single_gate(new_x, new_y) and board:is_empty(new_x + 1, new_y) and
                board:is_empty(new_x + 1, new_y + 1) then
              move_and_swap(_ENV, new_x, new_y)
              return
            end

            -- 入れ替えることで左に落とせる場合
            --
            -- [  X]
            --    H
            if board:is_empty(new_x, new_y) and board:is_single_gate(new_x + 1, new_y) and
                board:is_empty(new_x, new_y + 1) then
              move_and_swap(_ENV, new_x, new_y)
              return
            end
          end
        end

        -- 何もすることがない場合、ランダムに入れ替える
        local random_x = flr(rnd(board.cols - 1)) + 1
        local random_y = flr(rnd(board.rows)) + 1

        -- x, y で入れ替えをする意味がある/可能であるかを調べる
        if not ((board:is_empty(random_x, random_y) and board:is_empty(random_x + 1, random_y)) or
            board:is_part_of_garbage(random_x, random_y) or
            board:is_part_of_cnot(random_x, random_y) or
            board:is_part_of_garbage(random_x + 1, random_y) or
            board:is_part_of_cnot(random_x + 1, random_y) or
            board:reducible_gate_at(random_x, random_y).type == board:reducible_gate_at(random_x + 1, random_y).type) then
          move_and_swap(_ENV, random_x, random_y)
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
      add_sleep_command(_ENV, 20)
    end,

    add_raise_command = function(_ENV)
      add(commands, "x")
      add_sleep_command(_ENV, 5)
    end,

    add_sleep_command = function(_ENV, count)
      for i = 1, count do
        add(commands, "sleep")
      end
    end
  }, { __index = _ENV })
end
