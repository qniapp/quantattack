---@diagnostic disable: lowercase-global, global-in-nil-env

-- 新しい QPU プレーヤーを返す
--
-- TODO: ユニットテスト
function create_qpu(cursor, sleep)
  local qpu = setmetatable({
    cursor = cursor,
    _sleep = sleep,

    init = function(_ENV)
      steps, score = 0, 0
      commands = {} -- 入力したコマンドの列
      if sleep == nil then
        _sleep = true
      end
    end,

    update = function(_ENV, board)
      -- QPU プレーヤーの入力
      -- update ループ内でどれかの変数を true にすると、
      -- QPU プレーヤーの操作として扱われる
      left, right, up, down, x, o = false, false, false, false, false, false

      local next_command = commands[1]

      -- 次のコマンドが存在する場合
      if next_command then
        -- 先頭のコマンドを commands から消して、
        -- left, right, up, down, x, o のうち対応する変数を true にする
        del(commands, next_command)
        _ENV[next_command] = true
      else
        -- コマンドが空な場合
        -- board の上から (y が小さい順に) ゲートを見ていって、
        -- 次のコマンドを決める。
        --
        -- おじゃまゲートは上から降ってくるのでそれを優先して消すのと、
        -- 連鎖は上を消したほうが起こりやすいので、
        -- 上から順にゲートを見ていく。

        -- TODO: board.reducible_gates を y, x の順にループできるようにする。
        -- つまり、
        --
        --   for y, row in pairs(reducible_gates) do
        --     for x, each in pairs(row) do
        --
        -- のように書けるようにすることで、
        -- each の nil チェックを不要にする
        for each_y = 1, board.rows do
          for each_x = 1, board.cols do
            local each = board.reducible_gates[each_x][each_y]
            if not each then
              goto next_gate
            end

            if each:is_single_gate() then
              if 1 < each_x and each_y < board.rows then
                -- ? X <-- each
                -- _ ■
                --
                -- または
                --
                -- ? X <-- each
                -- X ■
                if _is_swappable(_ENV, board, each_x - 1, each_y) and
                    (
                    board:is_gate_empty(each_x - 1, each_y + 1) or
                        _is_match(_ENV, each, board.gates[each_x - 1][each_y + 1])) then
                  move_and_swap(_ENV, each_x - 1, each_y)
                  return
                end
              end

              if each_x < board.cols and each_y < board.rows then
                -- each --> X ?
                --          ■ _
                --
                -- または
                --
                -- each --> X ?
                --          ■ X
                if _is_swappable(_ENV, board, each_x + 1, each_y) and
                    (
                    board:is_gate_empty(each_x + 1, each_y + 1) or
                        _is_match(_ENV, each, board.gates[each_x + 1][each_y + 1])) then
                  move_and_swap(_ENV, each_x, each_y)
                  return
                end
              end

              if 1 < each_x and each_y < board.rows then
                -- ? ? X <-- each
                -- _ ■ ■
                --
                -- または
                --
                -- ? ? X <-- each
                -- X ■ ■
                local moveable = false

                for i = each_x - 1, 1, -1 do
                  if not _is_swappable(_ENV, board, i, each_y) then
                    break
                  end
                  if board:is_gate_empty(i, each_y + 1) or _is_match(_ENV, each, board.gates[i][each_y + 1]) then
                    moveable = true
                    break
                  end
                end

                if moveable then
                  move_and_swap(_ENV, each_x - 1, each_y, true)
                  return
                end
              end

              if each_x < board.cols and each_y < board.rows then
                -- each --> X
                --          ■ ■ _
                --
                -- または
                --
                -- each --> X
                --          ■ ■ X
                local moveable = false

                for i = each_x + 1, board.cols do
                  if not board:is_gate_empty(i, each_y) then
                    break
                  end
                  if board:is_gate_empty(i, each_y + 1) or _is_match(_ENV, each, board.gates[i][each_y + 1]) then
                    moveable = true
                    break
                  end
                end

                if moveable then
                  move_and_swap(_ENV, each_x, each_y, true)
                  return
                end
              end

              if 1 < each_x and 1 < each_y then
                --   H ■ ■ ■ ■
                --   ? H <-- each
                if _is_match(_ENV, each, board.gates[each_x - 1][each_y - 1]) and
                    _is_swappable(_ENV, board, each_x - 1, each_y) then
                  move_and_swap(_ENV, each_x - 1, each_y)
                  return
                end

                --  X ■ ■
                --  ? ? X <-- each
                local matchable = false

                for i = each_x - 1, 1, -1 do
                  if not _is_swappable(_ENV, board, i, each_y - 1) then
                    break
                  end
                  if _is_match(_ENV, each, board.gates[i][each_y - 1]) then
                    matchable = true
                    break
                  end
                end

                if matchable then
                  move_and_swap(_ENV, each_x - 1, each_y, true)
                  return
                end
              end

              if each_x < board.cols and 1 < each_y then
                --    ■ ■ ■ ■ H
                -- each --> H ?
                if _is_match(_ENV, each, board.gates[each_x + 1][each_y - 1]) and
                    _is_swappable(_ENV, board, each_x + 1, each_y) then
                  move_and_swap(_ENV, each_x, each_y)
                  return
                end
              end
            end

            -- 1. CNOT を縮める
            --
            --   [X-]--C
            --   [C-]--X
            if (each:is_cnot_x() or each:is_control()) and each_x + 1 < each.other_x then
              move_and_swap(_ENV, each_x, each_y)
              return
            end

            -- 2. CNOT を同じ方向にそろえる
            --
            --   C-X --> X-C
            --   X-C --> X-C
            if each:is_control() and each.other_x == each_x + 1 then
              move_and_swap(_ENV, each_x, each_y)
              return
            end

            -- 3. CNOT を右に移動
            --
            --   X-[C ]
            if each_x < board.cols and
                each:is_control() and each.other_x < each_x and board:is_gate_empty(each_x + 1, each_y) then
              move_and_swap(_ENV, each_x, each_y)
              return
            end

            ::next_gate::
          end
        end
      end
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

    add_sleep_command = function(_ENV, count)
      for i = 1, count do
        add(commands, "sleep")
      end
    end,

    _is_match = function(_ENV, gate, other_gate)
      return other_gate.type == gate.type and other_gate:is_idle()
    end,

    _is_swappable = function(_ENV, board, gate_x, gate_y)
      local gate = board.gates[gate_x][gate_y]

      return gate:is_idle() and
          (board:is_gate_empty(gate_x, gate_y) or gate:is_single_gate())
    end,
  }, { __index = _ENV })

  qpu:init()

  return qpu
end
