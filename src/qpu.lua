---@diagnostic disable: lowercase-global, global-in-nil-env

-- 新しい QPU プレーヤーを返す
--
-- TODO: ユニットテスト
function create_qpu(cursor)
  local qpu = setmetatable({
    cursor = cursor,

    init = function(_ENV)
      steps, score = 0, 0
      commands = {} -- 入力したコマンドの列
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
              -- 注目しているゲート each_x, each_y を右に動かす場合。
              -- 右側に余裕が必要なので、each_x < board.cols の範囲で考える。
              --
              -- TODO: each_y < board.rows の条件を一か所にまとめる
              if each_x < board.cols and each_y < board.rows then
                -- おじゃまゲートに対応しやすくするために、平らにならす。
                -- ゲートを連続して右に移動すると落とせる、または同じゲートとマッチさせて消せる場合、
                -- そのゲートを右に動かす。
                --
                --  each
                --   |
                --   v
                --   X     or   X
                --   ■ ■ _      ■ ■ X
                for i = each_x + 1, board.cols do
                  local gate_bottom_right = board.gates[i][each_y + 1]
                  if board:is_gate_empty(i, each_y + 1) or
                      (gate_bottom_right:is_idle() and gate_bottom_right.type == each.type) then
                    if board:is_gate_empty(each_x + 1, each_y) then
                      move_and_swap(_ENV, each_x, each_y)
                      return
                    else
                      break
                    end
                  end
                end

                -- 入れ換えると右列がそろう場合、ゲートを右に動かして消す。
                --
                --  each
                --   |
                --   v
                --   X ?
                --   ■ X
                local right_gate = board.gates[each_x + 1][each_y]
                if right_gate:is_idle() and
                    (board:is_gate_empty(each_x + 1, each_y) or -- 「?」ゲートが空
                        (
                        right_gate:is_single_gate() and board:reducible_gate_at(each_x + 1, each_y + 1).type == each.type
                        )) then -- 「？」ゲートが each と同じ場合
                  move_and_swap(_ENV, each_x, each_y)
                  return
                end
              end


              -- 注目しているゲート each_x, each_y を左に動かす場合。
              -- 左側に余裕が必要なので、1 < each_x の範囲で考える。
              if 1 < each_x and each_y < board.rows then
                -- ゲートを連続して左に移動すると落とせる、または同じゲートとマッチさせて消せる場合、
                -- そのゲートを左に動かす。
                --
                --     each
                --      |
                --      v
                --      X   or      X
                --  _ ■ ■       X ■ ■
                for i = each_x - 1, 1, -1 do
                  local gate_bottom_left = board.gates[i][each_y + 1]
                  if board:is_gate_empty(i, each_y + 1) or
                      (gate_bottom_left:is_idle() and gate_bottom_left.type == each.type) then
                    if board:is_gate_empty(each_x - 1, each_y) then
                      move_and_swap(_ENV, each_x - 1, each_y)
                      return
                    else
                      break
                    end
                  end
                end

                -- 入れ換えると左列がそろう場合、ゲートを左に動かして消す。
                --
                --    each
                --     |
                --     v
                --   ? X
                --   X ■
                local left_gate = board.gates[each_x - 1][each_y]
                if left_gate:is_idle() and
                    (board:is_gate_empty(each_x - 1, each_y) or -- 「?」ゲートが空
                        (
                        left_gate:is_single_gate() and board:reducible_gate_at(each_x - 1, each_y + 1).type == each.type
                        )
                    ) then -- 「？」ゲートが each と同じ場合
                  move_and_swap(_ENV, each_x - 1, each_y)
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

            -- 下の X-C を左にずらして消す。
            --
            --  X-C
            -- [  X]-C
            if each_x > 1 and each_y > 1 and
                board:is_gate_empty(each_x - 1, each_y) and each:is_cnot_x() and each.other_x == each_x + 1 and
                board:reducible_gate_at(each_x, each_y - 1):is_control() and
                board:reducible_gate_at(each_x, each_y - 1).other_x == each_x - 1 then
              move_and_swap(_ENV, each_x - 1, each_y)
              move_and_swap(_ENV, each_x, each_y)
              return
            end

            ::next_gate::
          end
        end
      end
    end,

    move_and_swap = function(_ENV, gate_x, gate_y)
      if gate_x < cursor.x then
        add_move_command(_ENV, "left", cursor.x - gate_x)
      elseif cursor.x < gate_x then
        add_move_command(_ENV, "right", gate_x - cursor.x)
      end

      if gate_y < cursor.y then
        add_move_command(_ENV, "up", cursor.y - gate_y)
      elseif cursor.y < gate_y then
        add_move_command(_ENV, "down", gate_y - cursor.y)
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

  qpu:init()

  return qpu
end
