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
function create_qpu(cursor, sleep, raise)
  local qpu = setmetatable({
    cursor = cursor,
    _sleep = sleep,
    _raise = raise,

    init = function(_ENV)
      steps, score = 0, 0
      commands = {} -- 入力したコマンドの列
      if sleep == nil then
        _sleep = true
      end
      if raise == nil then
        _raise = true
      end
    end,

    update = function(_ENV, board)
      left, right, up, down, x, o = false, false, false, false, false, false

      local next_command = commands[1]
      if next_command then
        del(commands, next_command)
        _ENV[next_command] = true
      else
        if _raise and board.top_gate_y > 10 then
          add_raise_command(_ENV)
        else
          if not flatten_gates(_ENV, board) then
            if not board.contains_garbage_match_gate then
              reduce_cnots(_ENV, board)
              reduce_single_gates(_ENV, board)
            end
          end
        end
      end
    end,

    -- board の上から (y が小さい順に) ゲートを見ていって、
    -- 下に落とせるゲートを落とす
    flatten_gates = function(_ENV, board)
      for each_y = 7, board.rows - 1 do
        for each_x = 1, board.cols do
          -- TODO: board.reducible_gates を y, x の順にループできるようにする。
          -- つまり、
          --
          --   for y, row in pairs(reducible_gates) do
          --     for x, each in pairs(row) do
          --
          -- のように書けるようにすることで、
          -- each の nil チェックを不要にする

          local each = board.reducible_gates[each_x][each_y]

          if not each or not each:is_single_gate() then
            goto next_gate
          end

          if find_left_and_right(_ENV, _is_empty, board, each) then
            return true
          end

          ::next_gate::
        end
      end

      return false
    end,

    reduce_single_gates = function(_ENV, board)
      for each_y = 7, board.rows do
        for each_x = 1, board.cols do
          local each = board.reducible_gates[each_x][each_y]

          if not each or not each:is_single_gate() then
            goto next_gate
          end

          if each_y < board.rows then
            if find_left_and_right(_ENV, _is_match, board, each) then
              return
            end
          end

          if 1 < each_y then
            if find_left_and_right(_ENV, _is_match, board, each, true) then
              return
            end
          end

          ::next_gate::
        end
      end
    end,

    reduce_cnots = function(_ENV, board)
      for each_y = 7, board.rows do
        for each_x = 1, board.cols do
          local each = board.reducible_gates[each_x][each_y]

          if not each or each:is_single_gate() then
            goto next_gate
          end

          -- d-2. 上の X-C を左にずらす
          --
          -- [X--]-C
          --  X-C  ■
          if each_y < board.rows and
              each:is_cnot_x() and each.other_x == each_x + 2 and
              board:reducible_gate_at(each_x, each_y + 1):is_cnot_x() and
              board:reducible_gate_at(each_x, each_y + 1).other_x == each_x + 1 then
            move_and_swap(_ENV, each_x + 1, each_y, true)
            return
          end

          -- e-2. 下の X-C を左にずらす
          --
          --  X-C  ■
          -- [X--]-C
          if each_y > 1 and
              each:is_cnot_x() and each.other_x == each_x + 2 and
              board:reducible_gate_at(each_x, each_y - 1):is_cnot_x() and
              board:reducible_gate_at(each_x, each_y - 1).other_x == each_x + 1 then
            move_and_swap(_ENV, each_x + 1, each_y, true)
            return
          end

          -- a. CNOT を縮める
          --
          --   [X-]--C
          --   [C-]--X
          if (each:is_cnot_x() or each:is_control()) and each_x + 1 < each.other_x then
            move_and_swap(_ENV, each_x, each_y, true)
            return
          end

          -- b. CNOT を同じ方向にそろえる
          --
          --   C-X --> X-C
          --   X-C --> X-C
          if each:is_control() and each.other_x == each_x + 1 then
            move_and_swap(_ENV, each_x, each_y, true)
            return
          end

          -- c. CNOT を右に移動
          --
          --   X-[C ]
          if each_x < board.cols and
              each:is_control() and each.other_x < each_x and _is_empty(board, each_x + 1, each_y) then
            move_and_swap(_ENV, each_x, each_y, true)
            return
          end

          -- d-1. 上の X-C を左にずらす
          --
          -- [  X]-C
          --  X-C  ■
          if each_x > 1 and each_y < board.rows and
              _is_empty(board, each_x - 1, each_y) and each:is_cnot_x() and each.other_x == each_x + 1 and
              board:reducible_gate_at(each_x, each_y + 1):is_control() and
              board:reducible_gate_at(each_x, each_y + 1).other_x == each_x - 1 then
            move_and_swap(_ENV, each_x - 1, each_y, true)
            return
          end

          -- e. 下の X-C を左にずらす
          --
          --  X-C  ■
          -- [  X]-C
          if each_x > 1 and each_y > 1 and
              _is_empty(board, each_x - 1, each_y) and each:is_cnot_x() and each.other_x == each_x + 1 and
              board:reducible_gate_at(each_x, each_y - 1):is_control() and
              board:reducible_gate_at(each_x, each_y - 1).other_x == each_x - 1 then
            move_and_swap(_ENV, each_x - 1, each_y, true)
            return
          end

          ::next_gate::
        end
      end
    end,

    find_left_and_right = function(_ENV, f, board, gate, upper)
      local gate_x, gate_y, other_row_gate_y = gate.x, gate.y, gate.y + (upper and -1 or 1)
      local find_left, find_right = true, true

      for dx = 1, board.cols - 1 do
        if find_left and
          _is_swappable(board, gate_x - dx, gate_y) then
          if f(board, gate_x - dx, other_row_gate_y, gate) then
            move_and_swap(_ENV, gate_x - 1, gate_y, true)
            return true
          end
        else
          find_left = false
        end

        if find_right and
          _is_empty(board, gate_x + dx, gate_y) then
          if f(board, gate_x + dx, other_row_gate_y, gate) then
            move_and_swap(_ENV, gate_x, gate_y, true)
            return true
          end
        else
          find_right = false
        end
      end

      return false
    end,

    move_and_swap = function(_ENV, gate_x, gate_y, quick)
      if gate_x < cursor.x then
        add_move_command(_ENV, "left", cursor.x - gate_x, quick)
      elseif cursor.x < gate_x then
        add_move_command(_ENV, "right", gate_x - cursor.x, quick)
      end

      if gate_y < cursor.y then
        add_move_command(_ENV, "up", cursor.y - gate_y, quick)
      elseif cursor.y < gate_y then
        add_move_command(_ENV, "down", gate_y - cursor.y, quick)
      end

      add_swap_command(_ENV)
    end,

    add_move_command = function(_ENV, direction, count, quick)
      for i = 1, count do
        add(commands, direction)

        if _sleep then
          if not quick then
            add_sleep_command(_ENV, 5 + flr(rnd(10)))
          end
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

  qpu:init()

  return qpu
end
