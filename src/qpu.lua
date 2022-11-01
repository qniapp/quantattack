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
        for new_x = 1, board.cols - 1 do
          for new_y = board.rows - 1, 1, -1 do
            -- 入れ換えると右側がそろう場合
            --
            -- [X  ]
            --  ■ X
            if is_single_gate(_ENV, new_x, new_y) and (is_single_gate(_ENV, new_x + 1, new_y) or board:is_empty(new_x + 1, new_y)) and
                board:gate_at(new_x, new_y).type == board:gate_at(new_x + 1, new_y + 1).type then
              move_and_swap(_ENV, new_x, new_y)
              return
            end

            -- 入れ換えると左側がそろう場合
            --
            -- [  X]
            --  X ■
            if (is_single_gate(_ENV, new_x, new_y) or board:is_empty(new_x, new_y)) and is_single_gate(_ENV, new_x + 1, new_y) and
                board:gate_at(new_x + 1, new_y).type == board:gate_at(new_x, new_y + 1).type then
              move_and_swap(_ENV, new_x, new_y)
              return
            end

            -- 入れ替えることで右に落とせる場合
            --
            -- [X  ]
            --  H
            if is_single_gate(_ENV, new_x, new_y) and board:is_empty(new_x + 1, new_y) and
                board:is_empty(new_x + 1, new_y + 1) then
              move_and_swap(_ENV, new_x, new_y)
              return
            end

            -- 入れ替えることで左に落とせる場合
            --
            -- [  X]
            --    H
            if board:is_empty(new_x, new_y) and is_single_gate(_ENV, new_x + 1, new_y) and
                board:is_empty(new_x, new_y + 1) then
              move_and_swap(_ENV, new_x, new_y)
              return
            end
          end
        end

        -- 何もすることがない場合、ランダムに入れ替える
        -- NOTE: カーソルは 2 個分の幅があるので、ボードの右端には移動できない
        local new_x = flr(rnd(board.cols - 1)) + 1
        local new_y = flr(rnd(board.rows)) + 1

        -- x, y で入れ替えをする意味がある/可能な場合、
        -- x, y まで移動 (move) & 入れ替え (swap) のコマンドを積み上げる
        if not
            (
            (board:is_empty(new_x, new_y) and board:is_empty(new_x + 1, new_y)) or
                board:is_garbage(new_x, new_y) or
                board:is_cnot(new_x, new_y) or
                board:is_garbage(new_x + 1, new_y) or
                board:is_cnot(new_x + 1, new_y) or
                board:gate_at(new_x, new_y).type == board:gate_at(new_x + 1, new_y).type) then
          move_and_swap(_ENV, new_x, new_y)
        end
      end
    end,

    is_single_gate = function(_ENV, x, y)
      return not board:is_empty(x, y) and not board:is_garbage(x, y) and not board:is_cnot(x, y)
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

    add_move_command = function(_ENV, direction, times)
      for _a = 1, times do
        add(commands, direction)

        for _s = 1, 5 + flr(rnd(10)) do
          add(commands, "sleep")
        end
      end
    end,

    add_swap_command = function(_ENV)
      add(commands, "o")

      for _s = 1, 20 + flr(rnd(10)) do
        add(commands, "sleep")
      end
    end
  }, { __index = _ENV })
end
