---@diagnostic disable: lowercase-global, global-in-nil-env

function create_qpu(cursor)
  return setmetatable({
    cursor = cursor,
    actions = {},

    init = function(_ENV)
      steps, score = 0, 0
    end,

    update = function(_ENV, board)
      left = false
      right = false
      up = false
      down = false
      x = false
      o = false

      local next_action = actions[1]
      if next_action then
        del(actions, next_action)
        _ENV[next_action] = true
      else
        new_x = flr(rnd(board.cols - 1)) + 1 -- カーソルは 2 個分の幅があるので、ボードの右端には移動できない
        new_y = flr(rnd(board.rows)) + 1

        local gate = board:gate_at(new_x, new_y)
        local right_gate = board:gate_at(new_x + 1, new_y)

        if not
            (
            (gate:is_i() and right_gate:is_i()) or gate:is_garbage() or right_gate:is_garbage() or
                gate.type == right_gate.type) then
          if new_x < cursor.x then
            move(_ENV, "left", cursor.x - new_x)
          elseif cursor.x < new_x then
            move(_ENV, "right", new_x - cursor.x)
          end

          if new_y < cursor.y then
            move(_ENV, "up", cursor.y - new_y)
          elseif cursor.y < new_y then
            move(_ENV, "down", new_y - cursor.y)
          end

          swap(_ENV)
        end
      end
    end,

    move = function(_ENV, direction, times)
      for _a = 1, times do
        add(actions, direction)

        for _s = 1, 5 + flr(rnd(10)) do
          add(actions, "sleep")
        end
      end
    end,

    swap = function(_ENV)
      add(actions, "o")

      for _s = 1, 20 + flr(rnd(10)) do
        add(actions, "sleep")
      end
    end
  }, { __index = _ENV })
end
