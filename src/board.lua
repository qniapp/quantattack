---@diagnostic disable: global-in-nil-env, lowercase-global
require("engine/application/constants")
require("engine/core/helper")
require("helpers")
require("gate")

local reduction_rules = require("reduction_rules")

function create_board(_offset_x)
  local board = setmetatable({
    cols = 6,
    rows = 12,
    row_next_gates = 13, -- rows + 1
    gates = {},
    width = 48, -- 6 * tile_size
    height = 96, -- 12 * tile_size
    offset_x = _offset_x or 10,
    offset_y = 32, -- screen_height - 12 * tile_size (128 - 96)
    changed = false,
    bounce_speed = 0,
    bounce_screen_dy = 0,
    chain_count = {},
    is_empty_cache = {},
    is_gate_fallable_cache = {},

    init = function(_ENV)
      state = "play"
      raised_dots = 0
      win = nil

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

              gates[x + dx][y + dy]:replace_with(new_gate, index, nil, chain_id)

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
              for dx = 0, span - 1 do
                put(_ENV, x + dx, y, garbage_match_gate())
                gates[x + dx][y]:replace_with(_random_single_gate(_ENV), dx, span)
              end
            end
          end
        end
      end
    end,

    reduce = function(_ENV, x, y, include_next_gates)
      local reduction = { to = {}, score = 0 }
      local gate = gates[x][y]

      if not gate:is_reducible() then return reduction end

      local rules = reduction_rules[gate.type]
      if not rules then return reduction end

      for _, rule in pairs(rules) do
        -- other_x と dx を決める
        local gate_pattern_rows = rule[1]
        local other_x
        local dx

        if (include_next_gates and y + #gate_pattern_rows - 1 > row_next_gates) or
            (not include_next_gates and y + #gate_pattern_rows - 1 > rows) then
          goto next_rule
        end

        for i, gates in pairs(gate_pattern_rows) do
          if gates[2] then
            local current_gate = reducible_gate_at(_ENV, x, y + i - 1)

            if current_gate.other_x then
              if current_gate.type == gates[1] then
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
        local chain_id = tostr(x) .. "," .. tostr(y)

        -- マッチするかチェック
        for i, gates in pairs(gate_pattern_rows) do
          local current_y = y + i - 1

          if gates[1] ~= "?" then
            local gate1 = reducible_gate_at(_ENV, x, current_y)
            if gate1.type ~= gates[1] then
              goto next_rule
            end
            if gate1.other_x and gate1.other_x ~= other_x then
              goto next_rule
            end
            if gate1.chain_id then
              chain_id = gate1.chain_id
            end
          end

          if gates[2] and other_x then
            local gate2 = reducible_gate_at(_ENV, other_x, current_y)
            if gate2.type ~= gates[2] then
              goto next_rule
            end
            if gate2.other_x and gate2.other_x ~= x then
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
    screen_y = function(_ENV, y)
      return offset_y + (y - 1) * tile_size - raised_dots + bounce_screen_dy
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
      local gate = gates[x][y]

      return gate:is_reducible() and gate or i_gate()
    end,

    put = function(_ENV, x, y, gate)
      assert(1 <= x and x <= cols, x)
      assert(1 <= y and y <= row_next_gates, y)

      gates[x][y] = gate
      gate:attach(_ENV)
      observable_update(_ENV, gate)
    end,

    remove_gate = function(_ENV, x, y)
      put(_ENV, x, y, i_gate())
    end,

    fall_garbage = function(_ENV)
      local span = flr(rnd(4)) + 3
      local x = flr(rnd(cols - span + 1)) + 1

      for i = x, x + span - 1 do
        if not is_empty(_ENV, x, 1) then
          return
        end
      end

      local garbage = garbage_gate(span)
      put(_ENV, x, 1, garbage)
      garbage:fall()
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

    game_over = function(_ENV)
      local center_x, center_y = offset_x + width / 2, offset_y + height / 2

      draw_rounded_box(center_x - 22, center_y - 7,
        center_x + 20, center_y + 22,
        1, 7)
      print_centered("game over", center_x, center_y, 8)
      print_centered("push x\nto replay", center_x, center_y + 12, 0)
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

      if is_part_of_garbage(_ENV, x_left, y) or is_part_of_garbage(_ENV, x_right, y) then
        return false
      end

      if not (left_gate:is_idle() and right_gate:is_idle()) then
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

      left_gate:swap_with_right(x_right)
      right_gate:swap_with_left(x_left)

      return true
    end,

    -------------------------------------------------------------------------------
    -- update, render
    -------------------------------------------------------------------------------

    update = function(_ENV, game, player, other_board)
      if _gates_piled_up(_ENV) or win ~= nil then
        state = "over"
      end

      _update_bounce(_ENV)

      if state == "play" then
        _update_game(_ENV, game, player, other_board)
      elseif state == "over" then
        -- NOP
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

      -- draw gates
      for x = 1, cols do
        for y = 1, row_next_gates do
          local gate, scr_x, scr_y = gates[x][y], screen_x(_ENV, x), screen_y(_ENV, y)

          if gate.other_x and x < gate.other_x then
            local connection_y = scr_y + 3
            line(scr_x + 3, connection_y,
              screen_x(_ENV, gate.other_x) + 3, connection_y,
              10)
          end

          gate:render(scr_x, scr_y)

          -- マスクを描画
          if y == row_next_gates then
            spr(102, scr_x, scr_y)
          end
        end
      end

      if win then
        local center_x, center_y = offset_x + width / 2, offset_y + height / 2

        draw_rounded_box(center_x - 22, center_y - 7, center_x + 20, center_y + 7,
          1, 7)
        print_centered("win", center_x, center_y, 8)
      elseif win == false then
        local center_x, center_y = offset_x + width / 2, offset_y + height / 2

        draw_rounded_box(center_x - 22, center_y - 7, center_x + 20, center_y + 7,
          1, 7)
        print_centered("lose", center_x, center_y, 5)
      end
    end,

    -- 最上段にゲートが存在し、
    -- raised_dots == 7 の場合 true を返す
    _gates_piled_up = function(_ENV)
      if raised_dots == tile_size - 1 then
        for x = 1, cols do
          if gate_at(_ENV, x, 1):is_falling() then
            return false
          end
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
          gate:update(_ENV, x, y)
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

    is_single_gate = function(_ENV, x, y)
      return not (is_empty(_ENV, x, y) or
          is_part_of_garbage(_ENV, x, y) or
          is_part_of_cnot(_ENV, x, y) or
          is_part_of_swap(_ENV, x, y))
    end,

    -- x, y が空かどうかを返す
    -- おじゃまユニタリと SWAP, CNOT ゲートも考慮する
    is_empty = function(_ENV, x, y)
      return memoize(_ENV, _is_empty_nocache, is_empty_cache, x, y)
    end,

    _is_empty_nocache = function(_ENV, x, y)
      for tmp_x = 1, x - 1 do
        local gate = gates[tmp_x][y]

        if gate:is_garbage() and (not gate:is_empty()) and x <= tmp_x + gate.span - 1 then
          return false
        end
        if gate.other_x and (not gate:is_empty()) and x < gate.other_x then
          return false
        end
      end

      return gates[x][y]:is_empty()
    end,

    -- x, y がおじゃまゲートの一部であるかどうかを返す
    is_part_of_garbage = function(_ENV, x, y)
      for tmp_x = 1, x - 1 do
        local gate = gates[tmp_x][y]

        if gate:is_garbage() and x <= tmp_x + gate.span - 1 then
          return true
        end
      end

      return gates[x][y]:is_garbage()
    end,

    -- x, y が CNOT の一部であるかどうかを返す
    is_part_of_cnot = function(_ENV, x, y)
      for tmp_x = 1, x - 1 do
        local gate = gates[tmp_x][y]

        if (gate:is_cnot_x() or gate:is_control()) and x < gate.other_x then
          return true
        end
      end

      local gate = gates[x][y]
      return gate:is_cnot_x() or gate:is_control()
    end,

    -- x, y が SWAP ペアの一部であるかどうかを返す
    is_part_of_swap = function(_ENV, x, y)
      for tmp_x = 1, x - 1 do
        local gate = gates[tmp_x][y]

        if gate:is_swap() and x < gate.other_x then
          return true
        end
      end

      return gates[x][y]:is_swap()
    end,

    -------------------------------------------------------------------------------
    -- ゲートの状態
    -------------------------------------------------------------------------------

    -- ゲート x, y が x, y + 1 に落とせるかどうかを返す。
    is_gate_fallable = function(_ENV, x, y)
      return memoize(_ENV, _is_gate_fallable_nocache, is_gate_fallable_cache, x, y)
    end,

    -- ゲート x, y が x, y + 1 に落とせるかどうかを返す。
    _is_gate_fallable_nocache = function(_ENV, x, y)
      --#if assert
      assert(1 <= x and x <= cols)
      assert(1 <= y and y <= row_next_gates)
      --#endif

      if y >= rows then
        return false
      end

      local gate = gates[x][y]
      if not gate:is_fallable() then
        return false
      end

      local start_x, end_x

      if gate.other_x then
        start_x, end_x = min(x, gate.other_x), max(x, gate.other_x)
      else
        start_x, end_x = x, x + gate.span - 1
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
