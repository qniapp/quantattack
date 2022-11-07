---@diagnostic disable: global-in-nil-env, lowercase-global, unbalanced-assignments

require("engine/application/constants")
require("engine/core/helper")
require("helpers")
require("gate")

local reduction_rules = require("reduction_rules")

function print_outlined(str, x, y, color) -- 21 tokens, 6.3 seconds
  print(str, x - 1, y, 0)
  print(str, x + 1, y)
  print(str, x, y - 1)
  print(str, x, y + 1)
  print(str, x, y, color)
end

function create_board(_offset_x)
  local board = setmetatable({
    cols = 6,
    rows = 13,
    row_next_gates = 14, -- rows + 1
    gates = {},
    width = 48, -- 6 * tile_size
    height = 96, -- 12 * tile_size
    offset_x = _offset_x or 10,
    offset_y = 32, -- screen_height - 12 * tile_size (128 - 96)
    changed = false,
    bounce_speed = 0,
    bounce_screen_dy = 0,
    chain_count = {},
    reduce_cache = {},
    reducible_gate_at_cache = {},
    is_empty_cache = {},
    is_gate_fallable_cache = {},

    init = function(_ENV)
      state = "play"
      raised_dots = 0
      win = false
      lose = false
      waiting_garbage_gates = {}

      -- fill the board with I gates
      for x = 1, cols do
        gates[x] = {}
        for y = 1, row_next_gates do
          put(_ENV, x, y, i_gate())
        end
      end
    end,

    initialize_with_random_gates = function(_ENV)
      init(_ENV)

      for y = row_next_gates, 6, -1 do
        for x = 1, cols do
          if y >= rows - 2 or
              (y < rows - 2 and rnd(1) > (y - 11) * -0.1 and (not is_empty(_ENV, x, y + 1))) then
            repeat
              put(_ENV, x, y, _random_single_gate(_ENV))
            until #reduce(_ENV, x, y, true).to == 0
          end
        end
      end
    end,

    reduce_gates = function(_ENV, game, player, other_board)
      -- 同時消しで変化したゲートの数
      -- 同じフレーム内で一度に消えたゲートを数えるため、
      -- 連鎖数のカウント (chain_count) のようにフレームをまたいで数える必要はなく、
      -- 一度の reduce_gates() 呼び出し内での数をカウントする。
      local combo_count = nil

      for x = 1, cols do
        for y = 1, rows do
          local reduction = reduce(_ENV, x, y)

          -- コンボ (同時消し) とチェイン (連鎖) の処理
          if #reduction.to > 0 then
            local chain_id = reduction.chain_id

            if player then
              game.reduce_callback(reduction.score, player)
            end

            if chain_count[chain_id] == nil then
              chain_count[chain_id] = 0
            end

            if combo_count then
              -- 同時消し
              combo_count = combo_count + #reduction.to
              game.combo_callback(combo_count, x, y, player, _ENV, other_board)
            else
              combo_count = #reduction.to
            end

            chain_count[chain_id] = chain_count[chain_id] + 1

            -- 連鎖
            if chain_count[chain_id] > 1 and game then
              game.chain_callback(chain_count[chain_id], x, y, player, _ENV, other_board)
            end

            for index, r in pairs(reduction.to) do
              local dx = r.dx and reduction.dx or 0
              local dy = r.dy or 0
              local new_gate = create_gate(r.gate_type)

              if new_gate.type == "swap" or new_gate.type == "cnot_x" or new_gate.type == "control" then
                if r.dx then
                  new_gate.other_x = x
                else
                  new_gate.other_x = x + reduction.dx
                end
              end

              gates[x + dx][y + dy]:replace_with(new_gate, index, nil, nil, chain_id)

              -- ゲートが消える、または変化するとき、その上にあるゲートすべてにフラグを付ける
              for chainable_y = y + dy - 1, 1, -1 do
                local gate_to_fall = gates[x + dx][chainable_y]
                if not gate_to_fall:is_i() then
                  if gate_to_fall:is_match() then
                    goto next
                  end
                  gate_to_fall.chain_id = chain_id
                end
              end

              ::next::
            end
          end
        end
      end

      -- おじゃまゲートのマッチ
      for y = rows, 1, -1 do
        for x = 1, cols do
          local gate = gates[x][y]
          local span = gate.span

          if gate:is_garbage() then
            local adjacent_gates = {}
            local match = false

            if x > 1 then
              add(adjacent_gates, gates[x - 1][y])
            end

            if x + span <= cols then
              add(adjacent_gates, gates[x + span][y])
            end

            for gx = x, x + span - 1 do
              if y > 1 then
                add(adjacent_gates, gates[gx][y - 1])
              end
              if y < rows then
                add(adjacent_gates, gates[gx][y + 1])
              end
            end

            for _, each in pairs(adjacent_gates) do
              if (each:is_match() and each.type ~= "!") then
                match = true
              end
            end

            if match then
              for i = 0, span - 1 do
                for j = 0, gate.height - 1 do
                  put(_ENV, x + i, y - j, garbage_match_gate())

                  local new_gate
                  if j == 0 then -- 一行目にはランダムなゲートを入れる
                    new_gate = _random_single_gate(_ENV)
                  elseif j == 1 and i == 0 then
                    -- 二行目の先頭にはおじゃまゲート
                    new_gate = garbage_gate(span, gate.height - 1)
                  else
                    new_gate = i_gate()
                  end

                  gates[x + i][y - j]:replace_with(new_gate, i + j * span, span, gate.height)
                end
              end
            end
          end
        end
      end
    end,

    reduce = function(_ENV, x, y, include_next_gates)
      if include_next_gates then
        return _reduce_nocache(_ENV, x, y, true)
      else
        return memoize(_ENV, _reduce_nocache, reduce_cache, x, y)
      end
    end,

    _reduce_nocache = function(_ENV, x, y, include_next_gates)
      local reduction = { to = {}, score = 0 }
      local gate = gates[x][y]

      if not gate:is_reducible() then return reduction end

      local rules = reduction_rules[gate.type]
      if not rules then return reduction end

      for _, rule in pairs(rules) do
        -- other_x と dx を決める
        local gate_pattern_rows, other_x, dx = rule[1]

        if (include_next_gates and y + #gate_pattern_rows - 1 > row_next_gates) or
            (not include_next_gates and y + #gate_pattern_rows - 1 > rows) then
          goto next_rule
        end

        for i, gate_types in pairs(gate_pattern_rows) do
          -- other_x と dx を決める際に、パターンにマッチしないゲートがあれば
          -- 先にここではじいておく
          if gate_types[1] ~= "?" then
            if reducible_gate_at(_ENV, x, y + i - 1).type ~= gate_types[1] then
              goto next_rule
            end
          end

          if gate_types[2] then
            local current_gate = reducible_gate_at(_ENV, x, y + i - 1)

            if current_gate.other_x then
              if current_gate.type == gate_types[1] then
                other_x = current_gate.other_x
                dx = other_x - x
                goto check_match
              else
                goto next_rule
              end
            end
          end
        end

        ::check_match::
        -- chainable フラグがついたブロックがマッチしたゲートの中に 1 個でも含まれていたら連鎖
        local chain_id = x .. "," .. y

        -- マッチするかチェック
        for i, gate_types in pairs(gate_pattern_rows) do
          local current_y = y + i - 1

          if gate_types[1] ~= "?" then
            local gate1 = reducible_gate_at(_ENV, x, current_y)
            if gate1.type ~= gate_types[1] or
                (gate1.other_x and gate1.other_x ~= other_x) then
              goto next_rule
            end

            if gate1.chain_id then
              chain_id = gate1.chain_id
            end
          end

          if gate_types[2] then
            local gate2 = reducible_gate_at(_ENV, other_x, current_y)
            if gate2.type ~= gate_types[2] or
                (gate2.other_x and gate2.other_x ~= x) then
              goto next_rule
            end

            if gate2.chain_id then
              chain_id = gate2.chain_id
            end
          end
        end

        reduction = { to = rule[2], dx = dx, gate_count = rule[3], score = rule[4] or 1, chain_id = chain_id }
        goto matched

        ::next_rule::
      end

      ::matched::
      return reduction
    end,

    -- ボード上の X 座標を画面上の X 座標に変換
    screen_x = function(_ENV, x)
      return offset_x + (x - 1) * tile_size
    end,

    -- ボード上の Y 座標を画面上の Y 座標に変換
    -- 一行目は表示しないことに注意
    screen_y = function(_ENV, y)
      return offset_y + (y - 2) * tile_size - raised_dots + bounce_screen_dy
    end,

    _random_single_gate = function(_ENV)
      local single_gate_types = { h_gate, x_gate, y_gate, z_gate, s_gate, t_gate }
      local gate_type = single_gate_types[flr(rnd(#single_gate_types)) + 1]

      return gate_type()
    end,

    -------------------------------------------------------------------------------
    -- board の状態
    -------------------------------------------------------------------------------

    top_gate_y = function(_ENV)
      for y = 1, rows do
        for x = 1, cols do
          if not is_empty(_ENV, x, y) then
            return y
          end
        end
      end

      return rows
    end,

    is_busy = function(_ENV)
      for x = 1, cols do
        for y = 1, row_next_gates do
          if not gates[x][y]:is_idle() then
            return true
          end
        end
      end

      return false
    end,

    is_game_over = function(_ENV)
      return state == "over"
    end,

    -------------------------------------------------------------------------------
    -- board の操作
    -------------------------------------------------------------------------------

    gate_at = function(_ENV, x, y)
      assert(1 <= x and x <= cols, "x = " .. x)
      assert(1 <= y and y <= row_next_gates, "y = " .. y)

      local gate = gates[x][y]

      assert(gate)

      return gate
    end,

    reducible_gate_at = function(_ENV, x, y)
      return memoize(_ENV, _reducible_gate_at_nocache, reducible_gate_at_cache, x, y)
    end,

    _reducible_gate_at_nocache = function(_ENV, x, y)
      local gate = gates[x][y]

      return gate:is_reducible() and gate or i_gate()
    end,

    put = function(_ENV, x, y, gate)
      assert(1 <= x and x <= cols, x)
      assert(1 <= y and y <= row_next_gates, y)

      gate.x = x
      gate.y = y
      gates[x][y] = gate
      gate:attach(_ENV)
      observable_update(_ENV, gate)
    end,

    remove_gate = function(_ENV, x, y)
      put(_ENV, x, y, i_gate())
    end,

    send_garbage = function(_ENV, span, _height)
      -- もしキューの中に幅 6 のおじゃまゲートが存在し、
      -- 新たに幅 6 のおじゃまゲートを作ろうとする場合、
      -- 古いおじゃまゲートをキューから削除して、
      -- 新しいおじゃまゲートをキューに追加

      if span == 6 then
        for _, each in pairs(waiting_garbage_gates) do
          if each.span == 6 and each.height == _height - 1 then
            each.height = _height
            return
          end
        end
      end

      local garbage = garbage_gate(span, _height)
      garbage.wait_time = 120
      add(waiting_garbage_gates, garbage)
    end,

    update_waiting_garbage_gates = function(_ENV)
      for _, each in pairs(waiting_garbage_gates) do
        each.wait_time = each.wait_time - 1
        if each.wait_time == 0 then
          local x
          if each.span == 6 then
            x = 1
          else
            x = flr(rnd(cols - each.span + 1)) + 1
          end

          del(waiting_garbage_gates, each)
          put(_ENV, x, 1, each)
          each:fall()
        end
      end
    end,

    insert_gates_at_bottom = function(_ENV, steps)
      -- 各ゲートを 1 つ上にずらす
      for y = 1, row_next_gates - 1 do
        for x = 1, cols do
          put(_ENV, x, y, gates[x][y + 1])
          remove_gate(_ENV, x, y + 1)
        end
      end

      local min_cnot_probability = 0.3
      local max_cnot_probability = 0.7
      local p = min_cnot_probability + flr(steps / 5) * 0.1
      p = p > max_cnot_probability and max_cnot_probability or p

      if rnd(1) < p then
        local control_x
        local cnot_x_x
        repeat
          control_x = flr(rnd(cols)) + 1
          cnot_x_x = flr(rnd(cols)) + 1
        until control_x ~= cnot_x_x

        put(_ENV, control_x, row_next_gates, control_gate(cnot_x_x))
        put(_ENV, cnot_x_x, row_next_gates, cnot_x_gate(control_x))
      end

      -- 最下段の空いている部分に新しいゲートを置く
      for x = 1, cols do
        if is_empty(_ENV, x, row_next_gates) then
          repeat
            put(_ENV, x, row_next_gates, _random_single_gate(_ENV))
          until #reduce(_ENV, x, rows, true).to == 0
        end
      end
    end,

    -------------------------------------------------------------------------------
    -- ユーザーによるゲート操作
    -------------------------------------------------------------------------------

    -- (x_left, y) と (x_left + 1, y) のゲートを入れ替える
    -- 入れ替えできた場合は true を、そうでない場合は false を返す
    swap = function(_ENV, x_left, y)
      local x_right = x_left + 1

      assert(1 <= x_left and x_left <= cols - 1)
      assert(2 <= x_right and x_right <= cols)
      assert(1 <= y and y <= rows)

      local left_gate = gates[x_left][y]
      local right_gate = gates[x_right][y]

      if is_part_of_garbage(_ENV, x_left, y) or is_part_of_garbage(_ENV, x_right, y) or
          not (left_gate:is_idle() and right_gate:is_idle()) then
        return false
      end

      -- 回路が A--[A?] のようになっている場合
      -- [A?] は入れ替えできない。
      if left_gate.other_x and left_gate.other_x < x_left and not is_empty(_ENV, x_right, y) then
        return false
      end

      -- 回路が [?A]--A のようになっている場合も、
      -- [?A] は入れ替えできない。
      if not is_empty(_ENV, x_left, y) and right_gate.other_x and x_right < right_gate.other_x then
        return false
      end

      -- left_gate の上、または right_gate の上のゲートが落下中である場合も
      -- 入れ替えできない
      if y > 1 and
          (gates[x_left][y - 1]:is_falling() or gates[x_right][y - 1]:is_falling()) then
        return false
      end

      left_gate:swap_with_right()
      right_gate:swap_with_left()

      return true
    end,

    -------------------------------------------------------------------------------
    -- update, render
    -------------------------------------------------------------------------------

    update = function(_ENV, game, player, other_board)
      if _gates_piled_up(_ENV) or win or lose then
        state = "over"
      end

      update_waiting_garbage_gates(_ENV)
      _update_bounce(_ENV)

      if state == "play" then
        _update_game(_ENV, game, player, other_board)
      elseif state == "over" then
        if lose then
          for x = 1, cols do
            for y = 1, row_next_gates do
              gates[x][y]._state = "over"
            end
          end
        end
      end
    end,

    render = function(_ENV)
      for x = 1, cols do
        -- draw wires
        local line_x = screen_x(_ENV, x) + 3
        line(line_x, offset_y,
          line_x, offset_y + height,
          5)
      end

      -- ゲートの描画
      --
      -- 1 行目は画面に表示しないバッファとして使うので、
      -- 2 行目以降を表示する
      for y = row_next_gates, 2, -1 do
        for x = 1, cols do
          local gate, scr_x, scr_y = gates[x][y], screen_x(_ENV, x), screen_y(_ENV, y)

          -- CNOT や SWAP の接続を描画
          -- TODO: gate 側で描画する。
          if gate.other_x and x < gate.other_x then
            local connection_y = scr_y + 3
            line(scr_x + 3, connection_y,
              screen_x(_ENV, gate.other_x) + 3, connection_y,
              lose and 5 or 10)
          end

          gate:render()

          -- マスクを描画
          if y == row_next_gates then
            spr(85, scr_x, scr_y)
          end
        end
      end

      -- WIN! または LOSE を描画
      if is_game_over(_ENV) then
        local sx, sy
        if win then
          sx, sy = 0, 80
        else
          sx, sy = 32, 80
        end
        sspr(sx, sy, 32, 16, offset_x + width / 2 - 16, offset_y + 16)
        print_outlined("push any key!", offset_x - 1, offset_y + 80, 8)
      end
    end,

    -- 最上段にゲートが存在し、
    -- raised_dots == 7 の場合 true を返す
    _gates_piled_up = function(_ENV)
      if raised_dots == tile_size - 1 then
        for x = 1, cols do
          -- FIXME: x, 1 がおじゃまゲートの一部であった場合、
          -- おじゃまゲート先頭について is_falling() を調べる
          -- そのようなメソッド board:is_gate_falling() を board に追加
          -- board 内では gate:is_falling() ではなく board:is_gate_falling() を使う
          if gate_at(_ENV, x, 1):is_falling() then
            return false
          end

          -- TODO: return true を上のと一箇所にまとめる
          if not is_empty(_ENV, x, 1) then
            return true
          end
        end
      end

      return false
    end,

    _update_game = function(_ENV, game, player, other_board)
      if changed then
        reduce_gates(_ENV, game, player, other_board)
        changed = false
      end

      -- 落下と更新処理をすべてのゲートに対して行う。
      --
      -- swap などのペアとなるゲートを正しく落とすために、
      -- 一番下の行から上に向かって順に処理
      for y = row_next_gates, 1, -1 do
        for x = 1, cols do
          local gate = gates[x][y]

          -- 落下できるゲートを落とす
          if not gate:is_falling() and is_gate_fallable(_ENV, x, y) then
            if gate.other_x then
              local other_gate = gates[gate.other_x][y]
              if x < gate.other_x and is_gate_fallable(_ENV, gate.other_x, y) then
                gate:fall()
                other_gate:fall()
              end
            else
              gate:fall()
            end
          end

          -- ゲートを更新
          gate:update()
        end
      end

      for chain_id, _ in pairs(chain_count) do
        -- 連鎖可能フラグ (chain_id) の立ったゲートが 1 つもなかった場合、
        -- chain_count をリセット
        for x = 1, cols do
          for y = 1, rows do
            if gates[x][y].chain_id == chain_id then
              goto next_chain_id
            end
          end
        end
        chain_count[chain_id] = nil

        ::next_chain_id::
      end
    end,

    -------------------------------------------------------------------------------
    -- おじゃまユニタリが接地したときの bounce エフェクト
    -------------------------------------------------------------------------------

    -- bounce エフェクトを開始
    bounce = function(_ENV)
      bounce_screen_dy = 0 -- bounce による Y 方向のずれ
      bounce_speed = -4 -- Y 方向の速度
    end,

    _update_bounce = function(_ENV)
      if bounce_speed ~= 0 then
        bounce_speed = bounce_speed + 0.9
        bounce_screen_dy = bounce_screen_dy + bounce_speed

        if bounce_screen_dy > 0 then
          bounce_screen_dy, bounce_speed = 0, -bounce_speed
        end
      end
    end,

    -------------------------------------------------------------------------------
    -- ゲートの種類判定
    -------------------------------------------------------------------------------

    -- x, y が空かどうかを返す
    -- おじゃまユニタリと SWAP, CNOT ゲートも考慮する
    is_empty = function(_ENV, x, y)
      return memoize(_ENV, _is_empty_nocache, is_empty_cache, x, y)
    end,

    _is_empty_nocache = function(_ENV, x, y)
      return gates[x][y]:is_empty() and
          not (is_part_of_garbage(_ENV, x, y) or is_part_of_cnot(_ENV, x, y) or is_part_of_swap(_ENV, x, y))
    end,

    -- x, y がおじゃまゲートの一部であるかどうかを返す
    is_part_of_garbage = function(_ENV, x, y)
      return _garbage_head_gate(_ENV, x, y) ~= nil
    end,

    -- x, y がおじゃまゲートの一部であった場合、
    -- おじゃまゲート先頭のゲートを返す
    -- 一部でない場合は nil を返す
    _garbage_head_gate = function(_ENV, x, y)
      for ghead_y = rows, y, -1 do
        for ghead_x = 1, cols do
          local ghead = gates[ghead_x][ghead_y]

          if ghead:is_garbage() and
              ghead_x <= x and x <= ghead_x + ghead.span - 1 and -- 幅に x が含まれる
              y <= ghead_y and y >= ghead_y - ghead.height + 1 then -- 高さに y が含まれる
            return ghead
          end
        end
      end

      return nil
    end,

    -- x, y が CNOT の一部であるかどうかを返す
    is_part_of_cnot = function(_ENV, x, y)
      return _cnot_head_gate(_ENV, x, y) ~= nil
    end,

    -- x, y が CNOT の一部であった場合、
    -- CNOT 左端のゲート (control または cnot_x) を返す
    -- 一部でない場合は nil を返す
    _cnot_head_gate = function(_ENV, x, y)
      for tmp_x = 1, x - 1 do
        local gate = gates[tmp_x][y]

        if (gate:is_cnot_x() or gate:is_control()) and x < gate.other_x then
          return gate
        end
      end

      local gate = gates[x][y]
      return (gate:is_cnot_x() or gate:is_control()) and gate or nil
    end,

    -- x, y が SWAP ペアの一部であるかどうかを返す
    is_part_of_swap = function(_ENV, x, y)
      return _swap_head_gate(_ENV, x, y) ~= nil
    end,

    -- x, y が SWAP ペアの一部であった場合、
    -- SWAP ペア左端のゲートを返す
    -- 一部でない場合は nil を返す
    _swap_head_gate = function(_ENV, x, y)
      for tmp_x = 1, x - 1 do
        local gate = gates[tmp_x][y]

        if gate:is_swap() and x < gate.other_x then
          return gate
        end
      end

      local gate = gates[x][y]
      return gate:is_swap() and gate or nil
    end,

    -------------------------------------------------------------------------------
    -- ゲートの状態
    -------------------------------------------------------------------------------

    -- TODO: 使わない場合このメソッドを削除
    is_gate_idle = function(_ENV, x, y)
      -- x, y のゲートが
      --   * おじゃまゲートの一部であった場合、
      --   * CNOT の一部であった場合、
      --   * SWAP の一部であった場合、
      -- 先頭のゲートについて is_idle() を返す
      -- そうでない場合は、gates[x][y]:is_idle() を返す
      local gate = _garbage_head_gate(_ENV, x, y) or _cnot_head_gate(_ENV, x, y) or _swap_head_gate(_ENV, x, y) or
          gates[x][y]
      return gate:is_idle()
    end,

    -- ゲート x, y が x, y + 1 に落とせるかどうかを返す。
    is_gate_fallable = function(_ENV, x, y)
      return memoize(_ENV, _is_gate_fallable_nocache, is_gate_fallable_cache, x, y)
    end,

    -- ゲート x, y が x, y + 1 に落とせるかどうかを返す。
    _is_gate_fallable_nocache = function(_ENV, x, y)
      if y >= rows then
        return false
      end

      local gate = gates[x][y]
      if not gate:is_fallable() then
        return false
      end

      local start_x, end_x = x, x + gate.span - 1
      if gate.other_x then
        start_x, end_x = min(x, gate.other_x), max(x, gate.other_x)
      end

      for tmp_x = start_x, end_x do
        if not (is_empty(_ENV, tmp_x, y + 1) or gates[tmp_x][y + 1]:is_falling()) then
          return false
        end
      end

      return true
    end,

    -------------------------------------------------------------------------------
    -- memoization
    -------------------------------------------------------------------------------

    -- 引数 x, y を取る関数 func をメモ化した関数を返す
    memoize = function(_ENV, f, cache, x, y)
      if cache[x] == nil then
        cache[x] = {}
      end

      local result = cache[x][y]

      if result == nil then
        result = f(_ENV, x, y)
        cache[x][y] = result
      end

      return result
    end,

    -------------------------------------------------------------------------------
    -- observer pattern
    -------------------------------------------------------------------------------

    -- ボード内にあるいずれかのゲートが更新されたので、
    -- changed フラグを立て各種キャッシュもクリア
    observable_update = function(_ENV, observable)
      changed = true
      reduce_cache = {}
      reducible_gate_at_cache = {}
      is_empty_cache = {}
      is_gate_fallable_cache = {}
    end,

    -------------------------------------------------------------------------------
    -- debug
    -------------------------------------------------------------------------------

    --#if debug
    _tostring = function(_ENV)
      local str = ''

      for y = 1, row_next_gates do
        for x = 1, cols do
          str = str .. gates[x][y]:_tostring() .. " "
        end
        str = str .. "\n"
      end

      return str
    end
    --#endif
  }, { __index = _ENV })

  board:init()

  return board
end
