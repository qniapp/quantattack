---@diagnostic disable: global-in-nil-env, lowercase-global, unbalanced-assignments

require("gate")

require("h_gate")
require("helpers")
require("i_gate")
require("s_gate")
require("t_gate")
require("x_gate")
require("y_gate")
require("z_gate")

local reduction_rules = require("reduction_rules")

function create_board(__offset_x)
  local board = setmetatable({
    _offset_x = __offset_x,

    init = function(_ENV)
      -- サイズ関係
      cols, rows = 6, 17
      row_next_gates = rows + 1

      -- 画面上のサイズと位置
      width, height = cols * tile_size, (rows - 1) * tile_size
      offset_x, offset_y, raised_dots = _offset_x or 11, 0, 0

      -- board の状態
      state, win, lose, top_gate_y, _changed = "play", false, false, row_next_gates, false

      -- 各種キャッシュ
      _reduce_cache, _is_gate_empty_cache, _is_gate_fallable_cache, _gate_or_its_head_gate_cache = {}, {}, {}, {}

      _chain_count, pending_garbage_gates, _topped_out_frame_count, _topped_out_delay_frame_count, _bounce_speed,
          _bounce_screen_dy =
      {}, {}, 0, 600, 0, 0

      -- 各種ゲートの取得
      gates, reducible_gates, _garbage_gates, contains_garbage_match_gate = {}, {}, {}, false

      for x = 1, cols do
        gates[x], reducible_gates[x] = {}, {}
        for y = 1, row_next_gates do
          put(_ENV, x, y, i_gate())
        end
      end
    end,

    initialize_with_random_gates = function(_ENV)
      init(_ENV)

      for y = row_next_gates, 10, -1 do
        for x = 1, cols do
          if y >= rows - 2 or
              (y < rows - 2 and rnd(1) > (y - 15) * -0.1 and (not is_gate_empty(_ENV, x, y + 1))) then
            repeat
              put(_ENV, x, y, _random_single_gate(_ENV))
            until #reduce(_ENV, x, y, true).to == 0
          end
        end
      end
    end,

    reduce_gates = function(_ENV, game, player, other_board)
      local chain_id_callbacked, combo_count = {}

      for x, col in pairs(reducible_gates) do
        for y, each in pairs(col) do
          local reduction = reduce(_ENV, x, y)

          -- コンボ (同時消し) とチェイン (連鎖) の処理
          if #reduction.to > 0 then
            local chain_id = reduction.chain_id

            if player then
              game.reduce_callback(reduction.score, player)
            end

            if _chain_count[chain_id] == nil then
              _chain_count[chain_id] = 0
            end

            if combo_count then
              -- 同時消し
              combo_count = combo_count + #reduction.to
              game.combo_callback(combo_count, x, y, player, _ENV, other_board)
            else
              combo_count = #reduction.to
            end

            -- 同じフレームで同じ chain_id を持つ連鎖が発生した場合、
            -- 連鎖数をインクリメントしない
            if not chain_id_callbacked[chain_id] then
              _chain_count[chain_id] = _chain_count[chain_id] + 1
            end

            -- 連鎖
            if not chain_id_callbacked[chain_id] and _chain_count[chain_id] > 1 and game then
              if #pending_garbage_gates > 1 then
                local offset_height_left = game.gate_offset_callback(chain_id, _chain_count[chain_id], x, y, player, _ENV
                  , other_board)

                -- 相殺しても残っていれば、相手に攻撃
                if offset_height_left > 0 then
                  game.chain_callback(chain_id, _chain_count[chain_id], x, y, player, _ENV, other_board)
                end
              else
                -- そうでなければ、相手に攻撃
                game.chain_callback(chain_id, _chain_count[chain_id], x, y, player, _ENV, other_board)
              end
              chain_id_callbacked[chain_id] = true
            end

            for index, r in pairs(reduction.to) do
              -- i_gate() や h_gate() 用の create_gate(type) がないので、
              -- とりあえず場合分けしとく
              -- local dx, dy, new_gate = r.dx and reduction.dx or 0, r.dy or 0, create_gate(r.gate_type)
              local dx, dy, new_gate = r.dx and reduction.dx or 0, r.dy or 0
              if r.gate_type == "i" then
                new_gate = i_gate()
              elseif r.gate_type == "h" then
                new_gate = h_gate()
              elseif r.gate_type == "x" then
                new_gate = x_gate()
              elseif r.gate_type == "y" then
                new_gate = y_gate()
              elseif r.gate_type == "z" then
                new_gate = z_gate()
              elseif r.gate_type == "s" then
                new_gate = s_gate()
              elseif r.gate_type == "t" then
                new_gate = t_gate()
              else
                new_gate = create_gate(r.gate_type)
              end

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
                if gate_to_fall.type ~= "i" then
                  if gate_to_fall:is_match() then
                    goto next_reduction
                  end
                  gate_to_fall.chain_id = chain_id
                end
              end

              ::next_reduction::
            end
          end
        end
      end

      -- おじゃまゲートのマッチ
      for _, gate in pairs(_garbage_gates) do
        local x, y, garbage_span, garbage_height, chain_id = gate.x, gate.y, gate.span, gate.height
        local is_matching = function(g)
          chain_id = g.chain_id
          if g.type == "!" then
            return g:is_match() and gate.color == g.color
          else
            return g:is_match()
          end
        end

        if x > 1 then
          -- 左側
          for i = 0, garbage_height - 1 do
            if y - i > 0 and is_matching(gates[x - 1][y - i]) then
              goto match
            end
          end
        end

        if x + garbage_span <= cols then
          -- 右側
          for i = 0, garbage_height - 1 do
            if y - i > 0 and is_matching(gates[x + garbage_span][y - i]) then
              goto match
            end
          end
        end

        for gx = x, x + garbage_span - 1 do
          if y - garbage_height > 1 then
            -- 上側
            if is_matching(gates[gx][y - garbage_height]) then
              goto match
            end
          end
          if y < rows then
            -- 下側
            if is_matching(gates[gx][y + 1]) then
              goto match
            end
          end
        end

        goto next_gate

        ::match::
        for i = 0, garbage_span - 1 do
          for j = 0, garbage_height - 1 do
            gmg = garbage_match_gate()
            gmg.color = gate.color
            put(_ENV, x + i, y - j, gmg)

            local new_gate
            if j == 0 then
              -- 一行目にはランダムなゲートを入れる
              new_gate = _random_single_gate(_ENV)
            elseif j == 1 and i == 0 then
              -- 二行目の先頭にはおじゃまゲート
              new_gate = garbage_gate(garbage_span, garbage_height - 1, gate.color)
            else
              new_gate = i_gate()
            end

            gates[x + i][y - j]:replace_with(new_gate, i + j * garbage_span, garbage_span, garbage_height,
              j == 0 and chain_id or nil)
          end
        end

        ::next_gate::
      end
    end,

    reduce = function(_ENV, x, y, include_next_gates)
      if include_next_gates then
        return _reduce_nocache(_ENV, x, y, true)
      else
        return _memoize(_ENV, _reduce_nocache, _reduce_cache, x, y)
      end
    end,

    _reduce_nocache = function(_ENV, x, y, include_next_gates)
      local reduction, gate = { to = {}, score = 0 }, gates[x][y]
      local rules = reduction_rules[gate.type]

      if not rules then return reduction end

      for _, rule in pairs(rules) do
        -- other_x と dx を決める
        local gate_pattern_rows, other_x, dx = rule[1]

        if (include_next_gates and y + #gate_pattern_rows - 1 > row_next_gates) or
            (not include_next_gates and y + #gate_pattern_rows - 1 > rows) then
          return reduction
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
      return offset_x + (x - 1) * 8
    end,

    -- ボード上の Y 座標を画面上の Y 座標に変換
    -- 一行目は表示しないことに注意
    screen_y = function(_ENV, y)
      return offset_y + (y - 2) * 8 - raised_dots + _bounce_screen_dy
    end,

    _random_single_gate = function(_ENV)
      local single_gate_types = { h_gate, x_gate, y_gate, z_gate, s_gate, t_gate }
      local gate_type = single_gate_types[flr(rnd(#single_gate_types)) + 1]

      return gate_type()
    end,

    -------------------------------------------------------------------------------
    -- board の状態
    -------------------------------------------------------------------------------

    is_busy = function(_ENV)
      for x = 1, cols do
        for y = 1, row_next_gates do
          local gate = gates[x][y]
          if not (gate:is_idle() or gate:is_swapping()) then
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
      return reducible_gates[x][y] or i_gate()
    end,

    put = function(_ENV, x, y, gate)
      assert(1 <= x and x <= cols, x)
      assert(1 <= y and y <= row_next_gates, y)

      gate.x, gate.y = x, y

      -- おじゃまゲートを別のゲートと置き換える場合
      -- おじゃまゲートキャッシュから消す
      if gates[x] and gates[x][y] and gates[x][y].type == "g" then
        del(_garbage_gates, gates[x][y])
      end

      -- 新たにおじゃまゲートを置く場合
      -- おじゃまゲートキャッシュに追加する
      if gate.type == "g" then
        add(_garbage_gates, gate)
      end

      gates[x][y] = gate
      gate:attach(_ENV)
      gate_update(_ENV, gate)
    end,

    remove_gate = function(_ENV, x, y)
      put(_ENV, x, y, i_gate())
    end,

    send_garbage = function(_ENV, chain_id, span, _height)
      -- 同じ chain_id のおじゃまゲートをまとめる
      if span == 6 then
        for _, each in pairs(pending_garbage_gates) do
          if each.chain_id == chain_id and each.span == 6 then
            if each.height <= _height then
              -- 同じ chain_id でより低いおじゃまゲートがすでにプールに入っている場合、消す
              del(pending_garbage_gates, each)
            else
              -- 同じ chain_id でより高いおじゃまゲートがすでにプールに入っている場合、何もしない
              return
            end
          end
        end
      end

      local colors = { 2, 3, 4 }
      local new_garbage_gate = garbage_gate(span, _height, colors[flr(rnd(#colors)) + 1])
      new_garbage_gate.chain_id = chain_id
      new_garbage_gate.wait_time = 60
      new_garbage_gate.dx = 0
      new_garbage_gate.dy = 0
      add(pending_garbage_gates, new_garbage_gate)
    end,

    _update_pending_garbage_gates = function(_ENV)
      local first_garbage_gate = pending_garbage_gates[1]

      if first_garbage_gate then
        if first_garbage_gate.tick_fall then
          if first_garbage_gate.tick_fall == 0 then
            del(pending_garbage_gates, first_garbage_gate)
            put(_ENV, first_garbage_gate.x, 1, first_garbage_gate)
            first_garbage_gate:fall()
          else
            first_garbage_gate.dx = flr(rnd(3)) - 1
            first_garbage_gate.dy = flr(rnd(3)) - 1
            first_garbage_gate.tick_fall = first_garbage_gate.tick_fall - 1
          end
        elseif first_garbage_gate.wait_time == 0 then
          -- 落とす時の x 座標を決める
          local x
          if first_garbage_gate.span == 6 then
            x = 1
          else
            x = flr(rnd(cols - first_garbage_gate.span + 1)) + 1
          end

          for i = x, x + first_garbage_gate.span - 1 do
            if not is_gate_empty(_ENV, i, 1) or not is_gate_empty(_ENV, i, 2) then
              return
            end
          end

          -- 落とせることが確定
          first_garbage_gate.x = x
          first_garbage_gate.tick_fall = 30
        else
          first_garbage_gate.wait_time = first_garbage_gate.wait_time - 1
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
        local control_x, cnot_x_x

        repeat
          control_x = flr(rnd(cols)) + 1
          cnot_x_x = flr(rnd(cols)) + 1
        until control_x ~= cnot_x_x

        put(_ENV, control_x, row_next_gates, control_gate(cnot_x_x))
        put(_ENV, cnot_x_x, row_next_gates, cnot_x_gate(control_x))
      end

      -- 最下段の空いている部分に新しいゲートを置く
      for x = 1, cols do
        if is_gate_empty(_ENV, x, row_next_gates) then
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

      if _is_part_of_garbage(_ENV, x_left, y) or _is_part_of_garbage(_ENV, x_right, y) or
          not (left_gate:is_idle() and right_gate:is_idle()) then
        return false
      end

      -- 回路が A--[A?] のようになっている場合
      -- [A?] は入れ替えできない。
      if left_gate.other_x and left_gate.other_x < x_left and not is_gate_empty(_ENV, x_right, y) then
        return false
      end

      -- 回路が [?A]--A のようになっている場合も、
      -- [?A] は入れ替えできない。
      if not is_gate_empty(_ENV, x_left, y) and right_gate.other_x and x_right < right_gate.other_x then
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
      if win then
        state = "over"
      end

      _update_pending_garbage_gates(_ENV)
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
              gate:is_match() and 13 or (lose and 5 or 10))
          end

          gate:render()

          -- 一番下のマスクを描画
          if y == row_next_gates then
            spr(85, scr_x, scr_y)
          end
        end
      end

      -- 残り時間ゲージの描画
      if _is_topped_out(_ENV) then
        local _topped_out_frame_count_left = _topped_out_delay_frame_count - _topped_out_frame_count
        local gauge_width = 41
        local time_left_width = _topped_out_frame_count_left / _topped_out_delay_frame_count * gauge_width
        -- おじゃまゲートと混じらないように、黒い背景を入れる
        draw_rounded_box(offset_x + 1, 23, offset_x + 45, 29, 0, 0)
        rectfill(offset_x + 3 + (gauge_width - time_left_width), 25, offset_x + 44, 27, 8) -- ゲージの値
        draw_rounded_box(offset_x + 2, 24, offset_x + 44, 28, 7) -- ゲージの枠
      end

      -- ゲームオーバーの線
      line(offset_x - 2, 40,
        offset_x + 48 + 1, 40,
        _is_topped_out(_ENV) and 8 or 1)

      -- 待機中のおじゃまゲート
      for i, garbage in pairs(pending_garbage_gates) do
        local x0 = offset_x + 1 + (i - 1) * 9 + garbage.dx
        local y0 = offset_y + garbage.dy

        if garbage.tick_fall then
          pal(7, garbage.inner_border_color)
          pal(6, garbage.inner_border_color)
        end

        if garbage.span < 6 then
          sspr(96, 48, 13, 11, x0, y0)
        else
          sspr(80, 48, 13, 11, x0, y0)
          cursor(x0 + 5, y0 + 4)
          color(8)
          print(garbage.height)
        end

        pal()
      end

      -- WIN! または LOSE を描画
      if is_game_over(_ENV) then
        sspr(win and 0 or 32, 80, 32, 16, offset_x + width / 2 - 16, offset_y + 56)
      end

      if push_any_key then
        print_outlined("push any key!", offset_x - 1, offset_y + 100, 8)
      end
    end,

    _is_topped_out = function(_ENV)
      return screen_y(_ENV, top_gate_y) <= 40
    end,

    _update_game = function(_ENV, game, player, other_board)
      if _is_topped_out(_ENV) then
        if not is_busy(_ENV) then
          _topped_out_frame_count = _topped_out_frame_count + 1

          if _topped_out_frame_count >= _topped_out_delay_frame_count then
            lose = true
            state = "over"
          end
        end
      else
        _topped_out_frame_count = 0
      end

      if _changed then
        reduce_gates(_ENV, game, player, other_board)
        _changed = false
      end

      -- 落下と更新処理をすべてのゲートに対して行う。
      -- あわせて top_gate_y も更新
      --
      -- swap などのペアとなるゲートを正しく落とすために、
      -- 一番下の行から上に向かって順に処理
      top_gate_y = row_next_gates
      contains_garbage_match_gate = false

      for y = row_next_gates, 1, -1 do
        for x = 1, cols do
          local gate = gates[x][y]

          if gate.type == "!" then
            contains_garbage_match_gate = true
          end

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

          -- ここで top_gate_y を更新
          if gate.type ~= "i" then
            if gate.type == "g" then
              if not gate._garbage_first_drop and top_gate_y > y - gate.height + 1 then
                top_gate_y = y - gate.height + 1
              end
            elseif top_gate_y > y then
              top_gate_y = y
            end
          end

          -- ゲートを更新
          gate:update()
        end
      end

      for chain_id, _ in pairs(_chain_count) do
        -- 連鎖可能フラグ (chain_id) の立ったゲートが 1 つもなかった場合、
        -- _chain_count をリセット
        for x = 1, cols do
          for y = 1, rows do
            if gates[x][y].chain_id == chain_id then
              goto next_chain_id
            end
          end
        end
        _chain_count[chain_id] = nil

        ::next_chain_id::
      end
    end,

    -------------------------------------------------------------------------------
    -- おじゃまユニタリが接地したときの bounce エフェクト
    -------------------------------------------------------------------------------

    -- bounce エフェクトを開始
    bounce = function(_ENV)
      _bounce_screen_dy, _bounce_speed = 0, -4
    end,

    _update_bounce = function(_ENV)
      if _bounce_speed ~= 0 then
        _bounce_speed = _bounce_speed + 0.9
        _bounce_screen_dy = _bounce_screen_dy + _bounce_speed

        if _bounce_screen_dy > 0 then
          _bounce_screen_dy, _bounce_speed = 0, -_bounce_speed
        end
      end
    end,

    -------------------------------------------------------------------------------
    -- ゲートの種類判定
    -------------------------------------------------------------------------------

    -- x, y が空かどうかを返す
    -- おじゃまユニタリと SWAP, CNOT ゲートも考慮する
    is_gate_empty = function(_ENV, x, y)
      return _memoize(_ENV, _is_gate_empty_nocache, _is_gate_empty_cache, x, y)
    end,

    _is_gate_empty_nocache = function(_ENV, x, y)
      return gates[x][y]:is_empty() and
          not (_is_part_of_garbage(_ENV, x, y) or
              _is_part_of_cnot(_ENV, x, y) or
              _is_part_of_swap(_ENV, x, y))
    end,

    -- x, y がおじゃまゲートの一部であるかどうかを返す
    _is_part_of_garbage = function(_ENV, x, y)
      return _garbage_head_gate(_ENV, x, y) ~= nil
    end,

    _gate_or_its_head_gate = function(_ENV, x, y)
      return _memoize(_ENV, _gate_or_its_head_gate_nocache, _gate_or_its_head_gate_cache, x, y)
    end,

    _gate_or_its_head_gate_nocache = function(_ENV, x, y)
      return _garbage_head_gate(_ENV, x, y) or
          _cnot_head_gate(_ENV, x, y) or
          _swap_head_gate(_ENV, x, y) or
          gates[x][y]
    end,

    -- x, y がおじゃまゲートの一部であった場合、
    -- おじゃまゲート先頭のゲートを返す
    -- 一部でない場合は nil を返す
    _garbage_head_gate = function(_ENV, x, y)
      for _, each in pairs(_garbage_gates) do
        local garbage_x, garbage_y = each.x, each.y
        if garbage_x <= x and x <= garbage_x + each.span - 1 and -- 幅に x が含まれる
            y <= garbage_y and y >= garbage_y - each.height + 1 then -- 高さに y が含まれる
          return each
        end
      end

      return nil
    end,

    -- x, y が CNOT の一部であるかどうかを返す
    _is_part_of_cnot = function(_ENV, x, y)
      return _cnot_head_gate(_ENV, x, y) ~= nil
    end,

    -- x, y が CNOT の一部であった場合、
    -- CNOT 左端のゲート (control または cnot_x) を返す
    -- 一部でない場合は nil を返す
    _cnot_head_gate = function(_ENV, x, y)
      for tmp_x = 1, x - 1 do
        local gate = gates[tmp_x][y]

        if (gate.type == "cnot_x" or gate.type == "control") and x < gate.other_x then
          return gate
        end
      end

      local gate = gates[x][y]
      return (gate.type == "cnot_x" or gate.type == "control") and gate or nil
    end,

    -- x, y が SWAP ペアの一部であるかどうかを返す
    _is_part_of_swap = function(_ENV, x, y)
      return _swap_head_gate(_ENV, x, y) ~= nil
    end,

    -- x, y が SWAP ペアの一部であった場合、
    -- SWAP ペア左端のゲートを返す
    -- 一部でない場合は nil を返す
    _swap_head_gate = function(_ENV, x, y)
      for tmp_x = 1, x - 1 do
        local gate = gates[tmp_x][y]

        if gate.type == "swap" and x < gate.other_x then
          return gate
        end
      end

      local gate = gates[x][y]
      return gate.type == "swap" and gate or nil
    end,

    -------------------------------------------------------------------------------
    -- ゲートの状態
    -------------------------------------------------------------------------------

    -- ゲート x, y が x, y + 1 に落とせるかどうかを返す (メモ化)。
    is_gate_fallable = function(_ENV, x, y)
      return _memoize(_ENV, _is_gate_fallable_nocache, _is_gate_fallable_cache, x, y)
    end,

    -- ゲート x, y が x, y + 1 に落とせるかどうかを返す。
    _is_gate_fallable_nocache = function(_ENV, x, y)
      local gate = gates[x][y]

      if y >= rows or not gate:is_fallable() then
        return false
      end

      local start_x, end_x = x, x + gate.span - 1
      if gate.other_x then
        start_x, end_x = min(x, gate.other_x), max(x, gate.other_x)
      end

      for i = start_x, end_x do
        if not (is_gate_empty(_ENV, i, y + 1) or _gate_or_its_head_gate(_ENV, i, y + 1):is_falling()) then
          return false
        end
      end

      return true
    end,

    -- ボード内にあるいずれかのゲートが更新された場合に呼ばれる。
    -- _changed フラグを立て各種キャッシュも更新・クリアする。
    gate_update = function(_ENV, gate, old_state)
      local x, y = gate.x, gate.y

      if gate:is_reducible() then
        reducible_gates[x][y] = gate
      else
        reducible_gates[x][y] = nil
      end

      _changed = true

      if gate:is_reducible() then
        _reduce_cache = {}
      end

      if not (gate:is_swapping() or gate:is_match()) then
        for i = 1, y do
          _is_gate_fallable_cache[i] = {}
        end
      end

      _is_gate_empty_cache, _gate_or_its_head_gate_cache = {}, {}
    end,

    -------------------------------------------------------------------------------
    -- memoization
    -------------------------------------------------------------------------------

    -- 引数 x, y を取る関数 func をメモ化した関数を返す
    _memoize = function(_ENV, f, cache, x, y)
      if cache[y] == nil then
        cache[y] = {}
      end

      local result = cache[y][x]

      if result == nil then
        result = f(_ENV, x, y)
        cache[y][x] = result
      end

      return result
    end,

    -------------------------------------------------------------------------------
    -- debug
    -------------------------------------------------------------------------------

    --#if debug
    _tostring = function(_ENV)
      local str = ''

      for y = 1, row_next_gates do
        for x = 1, cols do
          local gate = gates[x][y]

          if gate.type == "i" then
            if _is_part_of_garbage(_ENV, x, y) then
              str = str .. "g " .. " "
            else
              str = str .. gates[x][y]:_tostring() .. " "
            end
          else
            str = str .. gates[x][y]:_tostring() .. " "
          end
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
