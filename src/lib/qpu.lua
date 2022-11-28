---@diagnostic disable: lowercase-global, global-in-nil-env

local function _is_empty(board, gate_x, gate_y)
  if gate_x < 1 or board.cols < gate_x then
    return false
  end

  return board.gates[gate_x][gate_y]:is_idle() and board:is_gate_empty(gate_x, gate_y)
end

local function _is_match(board, gate_x, gate_y, gate)
  local other_gate = board.gates[gate_x][gate_y]
  return other_gate.type == gate.type and other_gate:is_idle()
end

local function _is_swappable(board, gate_x, gate_y)
  if gate_x < 1 or board.cols < gate_x then
    return false
  end

  local gate = board.gates[gate_x][gate_y]
  return gate:is_idle() and (board:is_gate_empty(gate_x, gate_y) or gate:is_single_gate())
end

-- 新しい QPU プレーヤーを返す
function create_qpu(cursor, board)
  local qpu = setmetatable({
    cursor = cursor,
    board = board,

    init = function(_ENV)
      steps, score, commands, sleep, raise = 0, 0, {}, true, true
    end,

    update = function(_ENV)
      left, right, up, down, x, o = false, false, false, false, false, false

      local next_command = commands[1]
      if next_command then
        del(commands, next_command)
        _ENV[next_command] = true
      else
        if raise and board.top_gate_y > 10 then
          add(commands, "x")
          add_sleep_command(_ENV, 3)
        else
          if not for_all_reducible_gates(_ENV, _flatten_gate) then
            if not board.contains_garbage_match_gate then
              for_all_reducible_gates(_ENV, _reduce_cnot)
              for_all_reducible_gates(_ENV, _reduce_single_gate)
            end
          end
        end
      end
    end,

    _flatten_gate = function(_ENV, each, each_x, each_y)
      if each_y < board.rows and each:is_single_gate() then
        if find_left_and_right(_ENV, _is_empty, each, false, true) then
          return true
        end
      end
    end,

    _reduce_single_gate = function(_ENV, each, each_x, each_y)
      if each:is_single_gate() then
        if each_y < board.rows then
          if find_left_and_right(_ENV, _is_match, each) then
            return true
          end
        end

        if 1 < each_y then
          if find_left_and_right(_ENV, _is_match, each) then
            return true
          end
        end
      end
    end,

    _reduce_cnot = function(_ENV, each, each_x, each_y)
      if not each:is_single_gate() then
        -- d-2. 上の X-C を左にずらす
        --
        -- [X--]-C
        --  X-C  ■
        if each_y < board.rows and
            each.type == "cnot_x" and each.other_x == each_x + 2 and
            board:reducible_gate_at(each_x, each_y + 1).type == "cnot_x" and
            board:reducible_gate_at(each_x, each_y + 1).other_x == each_x + 1 then
          move_and_swap(_ENV, each_x + 1, each_y, true)
          return true
        end

        -- e-2. 下の X-C を左にずらす
        --
        --  X-C  ■
        -- [X--]-C
        if each_y > 1 and
            each.type == "cnot_x" and each.other_x == each_x + 2 and
            board:reducible_gate_at(each_x, each_y - 1).type == "cnot_x" and
            board:reducible_gate_at(each_x, each_y - 1).other_x == each_x + 1 then
          move_and_swap(_ENV, each_x + 1, each_y, true)
          return true
        end

        -- a. CNOT を縮める
        --
        --   [X-]--C
        --   [C-]--X
        if (each.type == "cnot_x" or each.type == "control") and each_x + 1 < each.other_x then
          move_and_swap(_ENV, each_x, each_y, true)
          return true
        end

        -- b. CNOT を同じ方向にそろえる
        --
        --   C-X --> X-C
        --   X-C --> X-C
        if each.type == "control" and each.other_x == each_x + 1 then
          move_and_swap(_ENV, each_x, each_y, true)
          return true
        end

        -- c. CNOT を右に移動
        --
        --   X-[C ]
        if each_x < board.cols and
            each.type == "control" and each.other_x < each_x and _is_empty(board, each_x + 1, each_y) then
          move_and_swap(_ENV, each_x, each_y, true)
          return true
        end

        -- d-1. 上の X-C を左にずらす
        --
        -- [  X]-C
        --  X-C  ■
        if each_x > 1 and each_y < board.rows and
            _is_empty(board, each_x - 1, each_y) and each.type == "cnot_x" and each.other_x == each_x + 1 and
            board:reducible_gate_at(each_x, each_y + 1).type == "control" and
            board:reducible_gate_at(each_x, each_y + 1).other_x == each_x - 1 then
          move_and_swap(_ENV, each_x - 1, each_y, true)
          return true
        end

        -- e. 下の X-C を左にずらす
        --
        --  X-C  ■
        -- [  X]-C
        if each_x > 1 and each_y > 1 and
            _is_empty(board, each_x - 1, each_y) and each.type == "cnot_x" and each.other_x == each_x + 1 and
            board:reducible_gate_at(each_x, each_y - 1).type == "control" and
            board:reducible_gate_at(each_x, each_y - 1).other_x == each_x - 1 then
          move_and_swap(_ENV, each_x - 1, each_y, true)
          return true
        end
      end
    end,

    find_left_and_right = function(_ENV, f, gate, upper, quick)
      local gate_x, gate_y, other_row_gate_y = gate.x, gate.y, gate.y + (upper and -1 or 1)
      local find_left, find_right = true, true

      for dx = 1, board.cols - 1 do
        if not (find_left or find_right) then
          return false
        end

        if find_left then
          if _is_swappable(board, gate_x - dx, gate_y) then
            if f(board, gate_x - dx, other_row_gate_y, gate) then
              move_and_swap(_ENV, gate_x - 1, gate_y, quick)
              return true
            end
          else
            find_left = false
          end
        end

        if find_right then
          if _is_empty(board, gate_x + dx, gate_y) then
            if f(board, gate_x + dx, other_row_gate_y, gate) then
              move_and_swap(_ENV, gate_x, gate_y, quick)
              return true
            end
          else
            find_right = false
          end
        end
      end

      return false
    end,

    move_and_swap = function(_ENV, gate_x, gate_y, quick)
      add_move_command(_ENV, gate_x < cursor.x and "left" or "right", abs(cursor.x - gate_x), quick)
      add_move_command(_ENV, gate_y < cursor.y and "up" or "down", abs(cursor.y - gate_y), quick)
      add_swap_command(_ENV)
    end,

    add_move_command = function(_ENV, direction, count, quick)
      for i = 1, count do
        add(commands, direction)

        if sleep and not quick then
          add_sleep_command(_ENV, 5 + ceil_rnd(10))
        end
      end
    end,

    add_swap_command = function(_ENV)
      add(commands, "o")
      -- NOTE: ゲートの入れ替えコマンドを送った後は、
      -- 必ず次のように入れ替え完了するまで sleep する。
      -- これをしないと「左に連続して移動して落とす」などの
      -- 操作がうまく行かない。
      add_sleep_command(_ENV, 4)
    end,

    add_sleep_command = function(_ENV, count)
      for i = 1, count do
        add(commands, "sleep")
      end
    end,

    for_all_reducible_gates = function(_ENV, f)
      for each_y = 7, board.rows do
        for each_x = 1, board.cols do
          local each = board.reducible_gates[each_x][each_y]
          if each then
            if f(_ENV, each, each_x, each_y) then
              return true
            end
          end
        end
      end

      return false
    end
  }, { __index = _ENV })

  qpu:init()

  return qpu
end
