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
              -- 注目しているゲート each_x, each_y を左に動かす場合。
              -- 左側に余裕が必要なので、1 < each_x の範囲で考える。
              if 1 < each_x and each_y < board.rows then
                --    each
                --     |
                --     v
                --   ? X
                --   _ ■
                local left_gate = board.gates[each_x - 1][each_y]
                if board:is_gate_empty(each_x - 1, each_y + 1) and -- 左下が空
                    left_gate:is_idle() and
                    (board:is_gate_empty(each_x - 1, each_y) or left_gate:is_single_gate()) then
                  move_and_swap(_ENV, each_x - 1, each_y)
                  return
                end
              end

              -- 注目しているゲート each_x, each_y を右に動かす場合。
              -- 右側に余裕が必要なので、each_x < board.cols の範囲で考える。
              if each_x < board.cols and each_y < board.rows then
                --  each
                --   |
                --   v
                --   X ?
                --   ■ _
                local right_gate = board.gates[each_x + 1][each_y]
                if board:is_gate_empty(each_x + 1, each_y + 1) and -- 右下が空
                    right_gate:is_idle() and
                    (board:is_gate_empty(each_x + 1, each_y) or right_gate:is_single_gate()) then
                  move_and_swap(_ENV, each_x, each_y)
                  return
                end
              end

              -- 注目しているゲート each_x, each_y を左に動かす場合。
              -- 左側に余裕が必要なので、1 < each_x の範囲で考える。
              if 1 < each_x and each_y < board.rows then
                --    each
                --     |
                --     v
                --   ? X
                --   X ■
                local left_gate = board.gates[each_x - 1][each_y]
                local gate_bottom_left = board.gates[each_x - 1][each_y + 1]
                if gate_bottom_left:is_idle() and gate_bottom_left.type == each.type and
                    left_gate:is_idle() and
                    (board:is_gate_empty(each_x - 1, each_y) or left_gate:is_single_gate()) then
                  move_and_swap(_ENV, each_x - 1, each_y)
                  return
                end
              end

              -- 注目しているゲート each_x, each_y を右に動かす場合。
              -- 右側に余裕が必要なので、each_x < board.cols の範囲で考える。
              if each_x < board.cols and each_y < board.rows then
                --  each
                --   |
                --   v
                --   X ?
                --   ■ X
                local right_gate = board.gates[each_x + 1][each_y]
                local gate_bottom_right = board.gates[each_x + 1][each_y + 1]
                if gate_bottom_right:is_idle() and gate_bottom_right.type == each.type and
                    right_gate:is_idle() and
                    (board:is_gate_empty(each_x + 1, each_y) or right_gate:is_single_gate()) then
                  move_and_swap(_ENV, each_x, each_y)
                  return
                end
              end

              if 1 < each_x and each_y < board.rows then
                -- ゲートを連続して左に移動すると落とせる場合、
                -- そのゲートを左に動かす。
                --
                --     each
                --      |
                --      v
                --      X
                --  _ ■ ■
                local fallable = false

                -- 最初に穴までどれほど離れているか調べる
                for i = each_x - 1, 1, -1 do
                  if not board:is_gate_empty(i, each_y) then
                    break
                  end
                  if board:is_gate_empty(i, each_y + 1) then
                    fallable = true
                    break
                  end
                end

                if fallable then
                  move_and_swap(_ENV, each_x - 1, each_y, true)
                  return
                end
              end

              if 1 < each_x and each_y < board.rows then
                -- ゲートを連続して左に移動するとマッチできる場合、
                -- そのゲートを左に動かす。
                --
                --     each
                --      |
                --      v
                --      X
                --  X ■ ■
                local fallable = false

                -- 最初に穴までどれほど離れているか調べる
                for i = each_x - 1, 1, -1 do
                  local bottom_left_gate = board.gates[i][each_y + 1]
                  if not board:is_gate_empty(i, each_y) then
                    break
                  end
                  if bottom_left_gate.type == each.type and bottom_left_gate:is_idle() then
                    fallable = true
                    break
                  end
                end

                if fallable then
                  move_and_swap(_ENV, each_x - 1, each_y, true)
                  return
                end
              end

              if each_x < board.cols and each_y < board.rows then
                -- ゲートを連続して右に移動すると落とせる場合、
                -- そのゲートを右に動かす。
                --
                -- each
                --  |
                --  v
                --  X
                --  ■ ■ _
                local fallable = false

                -- 最初に穴があるか調べる
                for i = each_x + 1, board.cols do
                  if not board:is_gate_empty(i, each_y) then
                    break
                  end
                  if board:is_gate_empty(i, each_y + 1) then
                    fallable = true
                    break
                  end
                end

                if fallable then
                  move_and_swap(_ENV, each_x, each_y, true)
                  return
                end
              end

              if 1 < each_x and each_y < board.rows then
                -- ゲートを連続して左に移動すると左下の同じゲートとマッチできる場合、
                -- 左に動かす。
                --
                --     each
                --      |
                --      v
                --  ? ? X
                --  X ■ ■
                local fallable = false

                -- 最初にマッチするゲートまで移動可能か調べる
                for i = each_x - 1, 1, -1 do
                  local gate_i = board.gates[i][each_y]
                  if not (gate_i:is_idle() and (board:is_gate_empty(i, each_y) or gate_i:is_single_gate())) then
                    break
                  end

                  local bottom_left_gate = board.gates[i][each_y + 1]
                  if bottom_left_gate.type == each.type and bottom_left_gate:is_idle() then
                    fallable = true
                    break
                  end
                end

                if fallable then
                  move_and_swap(_ENV, each_x - 1, each_y, true)
                  return
                end
              end

              if 1 < each_x and 1 < each_y then
                --   H ■ ■ ■ ■
                --   ? H <-- each
                do
                  local left_gate = board.gates[each_x - 1][each_y]
                  local top_left_gate = board.gates[each_x - 1][each_y - 1]

                  if top_left_gate:is_idle() and top_left_gate.type == each.type and -- 左上が同じゲートでマッチ可能
                    left_gate:is_idle() and
                    (board:is_gate_empty(each_x - 1, each_y) or left_gate:is_single_gate()) then
                    move_and_swap(_ENV, each_x - 1, each_y)
                    return
                  end
                end

                --  X ■ ■
                --  ? ? X <-- each
                do
                  local matchable = false

                  -- マッチするゲートまで移動可能か調べる
                  for i = each_x - 1, 1, -1 do
                    local gate_i = board.gates[i][each_y - 1]
                    if not (gate_i:is_idle() and (board:is_gate_empty(i, each_y) or gate_i:is_single_gate())) then
                      break
                    end

                    local top_left_gate = board.gates[i][each_y - 1]
                    if top_left_gate.type == each.type and top_left_gate:is_idle() then
                      matchable = true
                      break
                    end
                  end

                  if matchable then
                    move_and_swap(_ENV, each_x - 1, each_y, true)
                    return
                  end
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
    end
  }, { __index = _ENV })

  qpu:init()

  return qpu
end
