---@diagnostic disable: lowercase-global

require("lib/cursor")
require("lib/block")
require("lib/reduction_rules")
require("lib/pending_garbage_blocks")

--- ボードのクラス
board_class = new_class()

function board_class._init(_ENV, _cursor, __offset_x, _cols)
  cursor, _offset_x, show_top_line =
      _cursor or cursor_class(), __offset_x, true
  init(_ENV, _cols)
end

-- ボードの初期化
function board_class.init(_ENV, _cols)
  -- サイズ関係
  cols, rows = _cols or 6, 17

  -- 画面上のサイズと位置
  width, height, offset_x, raised_dots =
      cols * 8, (rows - 1) * 8, _offset_x or 11, 0

  -- board の状態
  state, win, lose, timeup, top_block_y, _changed, show_gameover_menu, done_over_fx =
      "play", false, false, false, 0, false, false, false

  -- ゲームオーバーの線 etc.
  top_line_start_x, freeze_timer = 0, 0

  _chain_count, _topped_out_frame_count, _topped_out_delay_frame_count, _bounce_speed,
  _bounce_screen_dy =
      {}, 0, 600, 0, 0

  -- 各種ブロックの取得
  blocks, reducible_blocks, _garbage_blocks, contains_q_block = {}, {}, {}, false

  tick, steps, pending_garbage_blocks, _flash_col_timer, _flash_col_colors, _check_hover_flag, cache_reduce,
  cache_is_block_fallable, cache_is_empty =
      0, 0, pending_garbage_blocks_class(), {}, split("1,1,1,1,1,1,5,5,5,5,5,13,13,7"), {}, {}, {}, {}

  for y = 0, rows do
    reducible_blocks[y], _check_hover_flag[y] = {}, {}
  end

  cursor:init()
end

function board_class.block_at(_ENV, x, y)
  if blocks[y] == nil or blocks[y][x] == nil then
    put(_ENV, x, y, block_class("i"))
  end

  return blocks[y][x]
end

function board_class.put_random_blocks(_ENV)
  for y = 0, 8 do
    for x = 1, cols do
      -- y = 0 (次のブロック) と、y = 1 .. 4 (下から 4 行) はブロックで埋める
      -- y >= 5 の行は確率的にブロックを置く
      if y < 5 or
          (rnd(1) > 0.2 and (not is_empty(_ENV, x, y - 1))) then
        repeat
          put(_ENV, x, y, _random_single_block(_ENV))
        until #reduce(_ENV, x, y, true).to == 0
      end
    end
  end
end

function board_class.reduce_blocks(_ENV, game, player, other_board)
  local chain_xy, combo_count = {}

  for y = #reducible_blocks, 1, -1 do
    for x, _ in pairs(reducible_blocks[y] or {}) do
      local reduction = reduce(_ENV, x, y)

      if player then
        game.reduce_callback(
          reduction.score,
          player,
          _ENV,
          reduction.contains_swap
        )
      end

      if #reduction.to > 0 then
        local chain_id = reduction.chain_id

        -- 新しい chain_id の場合 _chain_count を 1 に初期化する
        if _chain_count[chain_id] == nil then
          _chain_count[chain_id] = 1
        else
          _chain_count[chain_id] = _chain_count[chain_id] + 1
          chain_xy[chain_id] = { x = x, y = y }
        end

        if combo_count and game.combo_callback then
          -- 同時消し
          combo_count = combo_count + #reduction.to
          game.combo_callback(
            combo_count,
            { screen_x(_ENV, x), screen_y(_ENV, y) },
            player,
            _ENV,
            other_board
          )
        else
          combo_count = #reduction.to
        end

        for index, r in pairs(reduction.to) do
          sfx(35)

          local dx, dy, new_block = r.dx and reduction.dx or 0, r.dy or 0, block_class(r.block_type)

          if new_block.type == "swap" or new_block.type == "cnot_x" or new_block.type == "control" then
            new_block.other_x = x + (r.dx and 0 or reduction.dx)
          end

          if blocks[y + dy] == nil then
            put(_ENV, y + dy, x + dx, block_class("i"))
          end
          blocks[y + dy][x + dx]:replace_with(new_block, index, chain_id)
          _flash_col_timer[x + dx] = #_flash_col_colors + 1

          -- ブロックが消える、または変化するとき、その上にあるブロックすべてに chain_id をセット
          for chainable_y = y + dy + 1, #blocks do
            local block_to_fall = blocks[chainable_y][x + dx]
            if block_to_fall.type ~= "i" then
              if block_to_fall.state == "match" then
                goto next_reduction
              end

              if block_to_fall.chain_id == nil or
                _chain_count[block_to_fall.chain_id] == nil or
                (_chain_count[chain_id] and _chain_count[chain_id] > _chain_count[block_to_fall.chain_id]) then
                block_to_fall.chain_id = chain_id
              end
            end
          end

          ::next_reduction::
        end
      end
    end
  end

  -- おじゃまブロックのマッチ
  repeat
    local matched_garbage_block_count = 0

    for _, each in pairs(_garbage_blocks) do
      if each.state == "idle" then
        local x, y, garbage_span, garbage_height = each.x, each.y, each.span, each.height

        -- 隣接ブロック adj_x, adj_y がマッチ中であるかを返す。
        local match_with = function(adj_x, adj_y)
          if adj_y < 1 or adj_x < 1 or cols < adj_x then
            return false
          end

          local adjacent_block = blocks[adj_y][adj_x]

          if adjacent_block.state ~= "match" then
            return false
          end

          if adjacent_block.type == "?" then
            if each.body_color == adjacent_block.body_color then
              each.chain_id = adjacent_block.chain_id
              return true
            end
          else
            each.chain_id = adjacent_block.chain_id
            return true
          end

          return false
        end

        --          ██ ██ ██ ██  y+garbage_height
        --         ┌───────────┐
        --         │           │
        --         │           │
        -- x,y ──▶ │ g         │
        --         └───────────┘
        --          ██ ██ ██ ██  y-1
        --
        -- おじゃまブロックの下と上にマッチ中のブロックがあるかどうか調べる
        --
        for gx = x, x + garbage_span - 1 do
          if match_with(gx, y + garbage_height) or
              match_with(gx, y - 1) then
            matched_garbage_block_count = matched_garbage_block_count + 1
            goto matched
          end
        end

        --    ┌───────────┐
        --  ██│           │██
        --  ██│           │██
        --  ██│ g         │██
        --    └─▲─────────┘
        -- x-1  │          x+garbage_span
        --     x,y
        --
        -- おじゃまブロックの左と右にマッチ中のブロックがあるかどうか調べる
        for dy = 0, garbage_height - 1 do
          if match_with(x - 1, y + dy) or
              match_with(x + garbage_span, y + dy) then
            matched_garbage_block_count = matched_garbage_block_count + 1
            goto matched
          end
        end

        goto next_garbage_block

        ::matched::
        for dx = 0, garbage_span - 1 do
          for dy = 0, garbage_height - 1 do
            -- 1. おじゃまブロック全体に ? ブロックをしきつめる
            q_block = block_class("?")
            q_block.body_color = each.body_color
            put(_ENV, x + dx, y + dy, q_block)

            -- 2. 以下のようにブロックを入れ換える
            --
            --                    ┌─────────────┐
            --                    │ i  i  i  i  │
            -- new garbage head ──┼>g  i  i  i  │
            --       (x=0,dy=1)   │ ██ ██ ██ ██ │ random block (dy=0)
            --                    └─────────────┘
            blocks[y + dy][x + dx]:replace_with(
              dy == 0 and _random_single_block(_ENV) or
              ((dy == 1 and dx == 0) and
                garbage_block(garbage_span, garbage_height - 1, each.body_color) or
                block_class("i")),
              dx + dy * garbage_span,
              (dy == 0 or (dy == 1 and dx == 0)) and each.chain_id or nil,
              garbage_span,
              garbage_height
            )
          end
        end
      end

      ::next_garbage_block::
    end
  until matched_garbage_block_count == 0

  -- 連鎖
  for chain_id, xy in pairs(chain_xy) do
    local coord = { screen_x(_ENV, xy.x), screen_y(_ENV, xy.y) }

    if game and game.chain_callback then
      if #pending_garbage_blocks.all > 1 then
        local offset_height_left =
            game.block_offset_callback(
              _chain_count[chain_id],
              coord,
              player,
              _ENV,
              other_board
            )

        -- 相殺しても残っていれば、相手に攻撃
        if offset_height_left > 0 then
          game.chain_callback(
            chain_id,
            _chain_count[chain_id],
            coord,
            player,
            _ENV,
            other_board
          )
        end
      else
        game.chain_callback(
          chain_id,
          _chain_count[chain_id],
          coord,
          player,
          _ENV,
          other_board
        )
      end
    end
  end
end

function board_class.reduce(_ENV, x, y, include_next_blocks)
  if include_next_blocks then
    return _reduce_nocache(_ENV, x, y, true)
  else
    return _memoize(_ENV, _reduce_nocache, cache_reduce, x, y)
  end
end

function board_class._reduce_nocache(_ENV, x, y, include_next_blocks)
  local reduction, block = { to = {}, score = 0 }, blocks[y][x]
  local rules = reduction_rules[block.type] or {}

  for _, rule in pairs(rules) do
    -- other_x と dx を決める
    local block_pattern_rows, other_x, dx = rule[1]

    if (include_next_blocks and y - #block_pattern_rows < -1) or
        (not include_next_blocks and y - #block_pattern_rows < 0) then
      return reduction
    end

    for i, block_types in pairs(block_pattern_rows) do
      if y - i + 1 < 0 then
        goto next_rule
      end

      -- other_x と dx を決める際に、パターンにマッチしないブロックがあれば
      -- 先にここではじいておく
      if block_types[1] ~= "?" then
        if reducible_block_at(_ENV, x, y - i + 1).type ~= block_types[1] then
          goto next_rule
        end
      end

      if block_types[2] then
        local current_block = reducible_block_at(_ENV, x, y - i + 1)

        if current_block.other_x then
          if current_block.type == block_types[1] then
            other_x = current_block.other_x
            dx = other_x - x
            goto check_match
          else
            goto next_rule
          end
        end
      end
    end

    ::check_match::
    -- chainable フラグがついたブロックがマッチしたブロックの中に 1 個でも含まれていたら連鎖
    local chain_id, contains_swap = x .. "," .. y, false

    -- マッチするかチェック
    for i, block_types in pairs(block_pattern_rows) do
      local current_y = y - i + 1

      if current_y < 0 then
        goto next_rule
      end

      if block_types[1] ~= "?" then
        local block1 = reducible_block_at(_ENV, x, current_y)

        if block1.type ~= block_types[1] or
            (block1.other_x and block1.other_x ~= other_x) then
          goto next_rule
        end

        -- SWAP を含むパターンの点数かどうかをチェック
        if rule[3] == 50 or rule[3] == 60 or rule[3] == 70 or rule[3] == 200 or rule[3] == 300 then
          contains_swap = true
        end

        if block1.chain_id then
          chain_id = block1.chain_id
        end
      end

      if block_types[2] then
        local block2 = reducible_block_at(_ENV, other_x, current_y)
        if block2.type ~= block_types[2] or
            (block2.other_x and block2.other_x ~= x) then
          goto next_rule
        end

        if block2.chain_id then
          chain_id = block2.chain_id
        end
      end
    end

    reduction = {
      to = rule[2],
      dx = dx,
      score = rule[3],
      chain_id = chain_id,
      contains_swap = contains_swap
    }
    goto matched

    ::next_rule::
  end

  ::matched::
  return reduction
end

-- ボード上の X 座標を画面上の X 座標に変換
function board_class.screen_x(_ENV, x)
  return offset_x + (x - 1) * 8
end

-- ボード上の Y 座標を画面上の Y 座標に変換
-- 一行目は表示しないことに注意
function board_class.screen_y(_ENV, y)
  return 128 - y * 8 - raised_dots + _bounce_screen_dy
end

function board_class._random_single_block(_ENV)
  return block_class(rnd(split('h,x,y,z,s,t')))
end

-------------------------------------------------------------------------------
-- board の状態
-------------------------------------------------------------------------------

function board_class.is_busy(_ENV)
  for x = 1, cols do
    for y = 1, #blocks do
      local block = blocks[y][x]
      if not (block.state == "idle" or block.state == "swap") then
        return true
      end
    end
  end

  return false
end

function board_class.is_game_over(_ENV)
  return state == "over"
end

-------------------------------------------------------------------------------
-- board の操作
-------------------------------------------------------------------------------

function board_class.reducible_block_at(_ENV, x, y)
  --#if assert
  assert(1 <= x and x <= cols, "x = " .. x)
  assert(0 <= y, "y = " .. y)
  --#endif

  return reducible_blocks[y][x] or block_class("i")
end

-- x, y に block を配置し、block.x と block.y をセットする
function board_class.put(_ENV, x, y, block)
  --#if assert
  assert(1 <= x and x <= cols, "invalid x value: x = " .. x)
  assert(0 <= y, "invalid x value: y = " .. y)
  assert(block ~= nil, "block should not be nil")
  --#endif

  block.x, block.y = x, y

  -- もし blocks[y] == nil の場合、I で初期化する
  for tmp_y = 0, y + block.height do
    -- 新しい行 y を追加
    -- TODO: 後で別関数に切り出す
    if blocks[tmp_y] == nil then
      blocks[tmp_y] = {}
      for tmp_x = 1, cols do
        local i_block = block_class("i")
        blocks[tmp_y][tmp_x] = i_block
        i_block.x, i_block.y = tmp_x, tmp_y
        i_block:attach(_ENV)
      end
    end

    if _check_hover_flag[tmp_y] == nil then
      _check_hover_flag[tmp_y] = {}
    end
  end

  -- おじゃまブロックを分解する時 (= garbage_match ブロックと置き換える時)、
  -- おじゃまブロックキャッシュから消す
  if blocks[y][x] and blocks[y][x].type == "g" then
    del(_garbage_blocks, blocks[y][x])
  end

  -- 新たにおじゃまブロックを置く場合
  -- おじゃまブロックキャッシュに追加する
  if block.type == "g" then
    add(_garbage_blocks, block)
  end

  blocks[y][x] = block
  block:attach(_ENV)
  observable_update(_ENV, block)

  _check_hover_flag[y][x] = true
end

function board_class.remove_block(_ENV, x, y)
  put(_ENV, x, y, block_class("i"))
end

function board_class.send_garbage(_ENV, chain_id, span, _height)
  pending_garbage_blocks:add_garbage(span, _height, chain_id)
end

function board_class.insert_blocks_at_bottom(_ENV)
  shift_all_blocks_up(_ENV)

  -- min_cnot_probability = 0.3
  -- max_cnot_probability = 0.7
  if rnd(1) < min(0.3 + flr(steps / 5) * 0.1, 0.7) then
    local control_x, cnot_x_x

    repeat
      control_x, cnot_x_x = ceil_rnd(cols), ceil_rnd(cols)
    until control_x ~= cnot_x_x

    local control_block = block_class("control")
    control_block.other_x = cnot_x_x

    local cnot_x_block = block_class("cnot_x")
    cnot_x_block.other_x = control_x

    put(_ENV, control_x, 0, control_block)
    put(_ENV, cnot_x_x, 0, cnot_x_block)
  end

  -- 最下段の空いている部分に新しいブロックを置く
  for x = 1, cols do
    if is_empty(_ENV, x, 0) then
      repeat
        put(_ENV, x, 0, _random_single_block(_ENV))
      until #reduce(_ENV, x, 1, true).to == 0
    end
  end

  steps = steps + 1
end

function board_class.shift_all_blocks_up(_ENV)
  for y = #blocks, 0, -1 do
    for x = 1, cols do
      if not is_empty(_ENV, x, y) then
        put(_ENV, x, y + 1, blocks[y][x])
        remove_block(_ENV, x, y)
      end
    end
  end
end

--- x_left, y と x_left + 1, y のブロックを入れ替える
-- 入れ替えできる場合は true を、そうでない場合は false を返す
function board_class.swap(_ENV, x_left, y)
  local x_right = x_left + 1
  local left_block, right_block = block_at(_ENV, x_left, y), block_at(_ENV, x_right, y)

  -- 入れ替えできない場合
  --  1. 左または右の状態が idle や fall でない
  --  2. 左または右が # ブロック
  --  3. 左または右がおじゃまブロックの一部
  --  4. CNOT または SWAP の一部と単一ブロックを入れ替えようとしている場合
  if not (left_block:is_swappable_state() and right_block:is_swappable_state()) or
      (left_block.type == "#" or right_block.type == "#") or
      (_garbage_head_block(_ENV, x_left, y) ~= nil or _garbage_head_block(_ENV, x_right, y) ~= nil) or
      (left_block.other_x and left_block.other_x < x_left and not is_empty(_ENV, x_right, y)) or
      (not is_empty(_ENV, x_left, y) and right_block.other_x and x_right < right_block.other_x) then
    return false
  end

  left_block:swap_with("right")
  right_block:swap_with("left")
  return true
end

function board_class.update(_ENV, game, player, other_board)
  pending_garbage_blocks:update(_ENV)
  _update_bounce(_ENV)
  freeze_timer = max(freeze_timer - 1, 0)
  if freeze_timer == 0 then
    top_line_start_x = (top_line_start_x + 4) % 96
  end

  if state == "play" then
    if win or lose then
      state, tick_over = "over", 0
      sfx(17)
    elseif timeup then
      state, tick_over = "over", 0
    else
      _update_game(_ENV, game, player, other_board)
    end
  elseif state == "over" then
    if lose then
      if tick_over == 20 and not done_over_fx then
        sfx(18)
      end

      for x = 1, cols do
        for y = 0, #blocks do
          if tick_over == 0 then
            blocks[y][x].state = "over"
          elseif tick_over == 20 and not done_over_fx then
            blocks[y][x] = block_class("i")
            particles:create(
              { screen_x(_ENV, x), screen_y(_ENV, y) },
              "5,5,9,7,,,-0.03,-0.03,40|5,5,9,7,,,-0.03,-0.03,40|4,4,9,7,,,-0.03,-0.03,40|4,4,2,5,,,-0.03,-0.03,40|4,4,6,7,,,-0.03,-0.03,40|2,2,9,7,,,-0.03,-0.03,40|2,2,9,7,,,-0.03,-0.03,40|2,2,6,5,,,-0.03,-0.03,40|2,2,6,5,,,-0.03,-0.03,40|0,0,2,5,,,-0.03,-0.03,40"
            )
          end
        end
      end
    end

    tick_over = tick_over + 1

    if tick_over > 20 then
      done_over_fx = true
    end
  end

  -- 列フラッシュのタイマーをそれぞれ -1 する
  _flash_col_timer = transform(_flash_col_timer, function(each)
    return each and max(each - 1, 0) or 0
  end)

  tick = tick + 1
end

function board_class.render(_ENV)
  -- 列フラッシュを描画
  for x = 1, cols do
    local col_start_x, flash_color = screen_x(_ENV, x), _flash_col_colors[_flash_col_timer[x]]

    if flash_color then
      rectfill(
        col_start_x,
        0,
        col_start_x + 6,
        height,
        flash_color
      )
    end
  end

  -- ブロックの描画
  for x = 1, cols do
    for y = 0, rows do
      local scr_x, scr_y, block = screen_x(_ENV, x), screen_y(_ENV, y), block_at(_ENV, x, y)

      block:render(scr_x, scr_y, block.other_x and screen_x(_ENV, block.other_x))

      -- 一番下のマスクを描画
      if y == 0 and not is_game_over(_ENV) then
        spr(97, scr_x, scr_y)
      end
    end
  end

  -- 残り時間ゲージの描画
  if is_topped_out(_ENV) then
    local time_left_height, gauge_x =
        (_topped_out_delay_frame_count - _topped_out_frame_count) / _topped_out_delay_frame_count * 128,
        offset_x < 64 and offset_x + 50 or offset_x - 4

    if time_left_height > 0 then
      rectfill(
        gauge_x,
        128 - time_left_height,
        gauge_x + 1,
        127,
        freeze_timer > 0 and 12 or 8
      )
    end
  end

  -- 待機中のおじゃまブロックを描画
  pending_garbage_blocks:render(_ENV)

  -- ブロック上限の線を描画
  if not is_game_over(_ENV) then
    if show_top_line then
      if top_line_start_x < 73 then
        line(
          max(offset_x - 1, offset_x + top_line_start_x - 25),
          40,
          min(offset_x + 48, offset_x + top_line_start_x + 5),
          40,
          freeze_timer > 0 and 12 or (is_topped_out(_ENV) and 8 or 1)
        )
      end
    end

    -- カーソルを描画
    cursor:render(screen_x(_ENV, cursor.x), screen_y(_ENV, cursor.y))
  elseif (win or lose) and tick_over > 20 and #particles.all == 0 then
    -- WIN! または LOSE を描画
    sspr(
      win and 0 or 48,
      96,
      48,
      24,
      win and offset_x or offset_x + 3 * sin(tick % 60 / 60),
      win and 40 + 3 * sin(tick % 60 / 60) or 43
    )
  end

  -- try again, title を描画
  if show_gameover_menu then
    spr(99, offset_x, 97)
    print_outlined("try again", offset_x + 11, 98, 1, 7)

    spr(112, offset_x, 110)
    print_outlined("title", offset_x + 11, 111, 1, 7)
  end
end

function board_class.is_topped_out(_ENV)
  return screen_y(_ENV, top_block_y) - _bounce_screen_dy <= 40
end

function board_class._update_game(_ENV, game, player, other_board)
  if is_topped_out(_ENV) then
    if not is_busy(_ENV) and freeze_timer == 0 then
      _topped_out_frame_count = _topped_out_frame_count + 1

      if _topped_out_frame_count >= _topped_out_delay_frame_count then
        lose = true
      end
    end
  else
    _topped_out_frame_count = 0
  end

  if _changed then
    reduce_blocks(_ENV, game, player, other_board)
    _changed = false
  end

  -- 落下と更新処理をすべてのブロックに対して行う。
  -- あわせて top_block_y も更新
  --
  -- swap などのペアとなるブロックを正しく落とすために、
  -- 一番下の行から上に向かって順に処理
  top_block_y, contains_q_block = 0, false

  for y = 1, #blocks do
    for x = 1, cols do
      local block = blocks[y][x]

      block:update()

      if block.type ~= "i" then
        if block.type == "?" then
          contains_q_block = true
        end

        -- 落下できるブロックをホバー状態にする
        if block.state ~= "fall" and
            block.state ~= "hover" and
            _is_block_fallable(_ENV, x, y) then
          if not block.other_x then -- 単体ブロックとおじゃまゲート
            block:hover()
            if y > 1 and blocks[y - 1][x].state == "hover" then
              block.timer = blocks[y - 1][x].timer
            end
          else -- CNOT または SWAP
            if x < block.other_x and _is_block_fallable(_ENV, block.other_x, y) then
              block:hover()
              blocks[y][block.other_x]:hover(block.timer + 1)
            end
          end
        end

        -- ホバー中のブロックに乗ったブロックをホバー状態にする
        if _check_hover_flag[y][x] then
          _check_hover_flag[y][x] = false

          if block.state ~= "hover" then
            local hover_timer = propagatable_hover_timer(_ENV, x, y)
            if hover_timer then
              if not block.other_x then
                -- 単体ブロックとおじゃまゲート
                block:hover(hover_timer)
              elseif x < block.other_x then
                -- CNOT または SWAP
                block:hover(hover_timer)
                blocks[y][block.other_x]:hover(hover_timer + 1)
              end
            end
          end
        end

        -- top_block_y を更新
        if block.type == "g" then
          if not block.first_drop and top_block_y < y + block.height - 1 then
            top_block_y = y + block.height - 1
          end
        elseif top_block_y < y then
          top_block_y = y
        end

        -- 着地したブロックの chain_id を消す
        if block.state == "idle" and block._timer_landing ~= 0 and blocks[y - 1][x].chain_id == nil then
          block.chain_id = nil
        end

        if block.state == "fall" then
          if not _is_block_fallable(_ENV, x, y) then
            if block.type == "g" then
              bounce(_ENV)
              sfx(9)
              block.first_drop = false
            end

            block:change_state("idle")

            if block.other_x and x < block.other_x then
              local other_block = blocks[y][block.other_x]
              other_block:change_state("idle")
            end
          else
            if is_empty(_ENV, x, y - 1) then
              -- 落下中のブロックをひとつ下に移動
              if not block.other_x then
                remove_block(_ENV, x, y)
                put(_ENV, x, y - 1, block)
              elseif x < block.other_x then
                remove_block(_ENV, x, y)
                put(_ENV, x, y - 1, block)

                local other_block = blocks[y][block.other_x]
                other_block.state = "fall"
                remove_block(_ENV, block.other_x, y)
                put(_ENV, block.other_x, y - 1, other_block)
              end
            end
          end
        end
      end
    end
  end

  for chain_id, _ in pairs(_chain_count) do
    -- 連鎖可能フラグ (chain_id) の立ったブロックが 1 つもなかった場合、
    -- _chain_count をリセット
    for x = 1, cols do
      for y = 1, #blocks do
        if blocks[y][x].chain_id == chain_id then
          goto next_chain_id
        end
      end
    end
    _chain_count[chain_id] = nil

    ::next_chain_id::
  end
end

--- bounce エフェクトを開始
function board_class.bounce(_ENV)
  _bounce_screen_dy, _bounce_speed = 0, -4
end

function board_class._update_bounce(_ENV)
  if _bounce_speed ~= 0 then
    _bounce_speed = _bounce_speed + 0.9
    _bounce_screen_dy = _bounce_screen_dy + _bounce_speed

    if _bounce_screen_dy > 0 then
      _bounce_screen_dy, _bounce_speed = 0, -_bounce_speed
    end
  end
end

--- (x, y) が空かどうかを返す
-- おじゃまユニタリと SWAP, CNOT ブロックも考慮する
--
-- NOTE: (x, y) がおじゃまユニタリや SWAP, CNOT の一部かどうかを判定する処理が重いため、
-- メモ化していることに注意。
function board_class.is_empty(_ENV, x, y)
  --#if assert
  assert(0 < x and x <= cols, "x = " .. x)
  assert(0 <= y, "y = " .. y)
  --#endif

  return _memoize(_ENV, _is_empty_nocache, cache_is_empty, x, y)
end

function board_class._is_empty_nocache(_ENV, x, y)
  local block = block_at(_ENV, x, y)

  -- 次の 1 〜 4 をすべて満たすならば、(x, y) は空
  --
  -- 1. ブロックのない場所 (I) であり、入れ替え中でない
  -- 2. CNOT や SWAP の一部でない
  -- 3. おじゃまブロックの上でない
  return block.type == "i" and block.state ~= "swap" and -- 1
      _cnot_or_swap_head_block(_ENV, x, y) == nil and    -- 2
      _garbage_head_block(_ENV, x, y) == nil             -- 3
end

-- (x, y) が CNOT または SWAP の一部であった場合、
-- 左端のブロック (control または cnot_x または swap) を返す
-- 一部でない場合は nil を返す
function board_class._cnot_or_swap_head_block(_ENV, x, y)
  for tmp_x = 1, x - 1 do
    local block = blocks[y][tmp_x]

    if (block.type == "cnot_x" or block.type == "control" or block.type == "swap") and
      (tmp_x == x or x < block.other_x) then
      return block
    end
  end
end

--- (x, y) がおじゃまブロックの一部であった場合、おじゃまブロック先頭のブロックを返す
-- そうでない場合は nil を返す
function board_class._garbage_head_block(_ENV, x, y)
  for _, each in pairs(_garbage_blocks) do
    -- NOTE: 以下のように each.x, each.y に一時変数を割り当てるよりも、
    -- 直接書いたほうが 3 トークン小さい
    --
    --   local garbage_x, garbage_y = each.x, each.y
    --
    if each.x <= x and x <= each.x + each.span - 1 and     -- 幅に x が含まれる
        each.y <= y and y <= each.y + each.height - 1 then -- 高さに y が含まれる
      return each
    end
  end
end

function board_class._block_or_its_head_block(_ENV, x, y)
  return _cnot_or_swap_head_block(_ENV, x, y) or
    _garbage_head_block(_ENV, x, y) or
    blocks[y][x]
end

--- ブロック x, y の直下のブロックでホバー状態にあるもののうち、
-- timer の最大値を取得する。
-- 直下のブロックが一つもなかった場合は nil を返す。
--
-- x, y で指定するブロックは X などの単一ブロックだけでなく、
-- CNOT, SWAP, おじゃまゲートもある。
-- このため、直下のブロックは複数の場合もある。
function board_class.propagatable_hover_timer(_ENV, x, y)
  local block, hover_timer = blocks[y][x], 0

  -- y が最下段、または next block の場合、
  -- またはブロックが落下可能でない状態の場合、
  -- nil を返す
  if y < 2 or block:is_not_fallable() then
    return nil
  end

  for_all_nonempty_blocks_below(_ENV, x, y, function(each)
    if each.state == "hover" and hover_timer < each.timer then
      hover_timer = each.timer
    end
  end)

  return hover_timer > 0 and hover_timer or nil
end

-- ブロック x, y が x, y - 1 に落とせるかどうかを返す
--
-- TODO: プライベートメソッドなので、名前を _is_block_fallable に変更
function board_class._is_block_fallable(_ENV, x, y)
  return _memoize(_ENV, _is_block_fallable_nocache, cache_is_block_fallable, x, y)
end

function board_class._is_block_fallable_nocache(_ENV, x, y)
  local block, fallable = blocks[y][x], true

  if y < 2 or block:is_not_fallable() then
    return false
  end

  for_all_nonempty_blocks_below(_ENV, x, y, function(each)
    if each.state ~= "fall" then
      fallable = false
    end
  end)

  return fallable
end

-- x, y で指定するブロックの直下にあるすべてのブロックに対して、f を適用する
function board_class.for_all_nonempty_blocks_below(_ENV, x, y, f)
  local block = blocks[y][x]

  -- ブロックの幅 (x 座標の start と end) を得る
  local start_x, end_x = x, x + block.span - 1
  if block.other_x then
    start_x, end_x = min(x, block.other_x), max(x, block.other_x)
  end

  for i = start_x, end_x do
    if is_empty(_ENV, i, y - 1) then
      goto next_block
    end

    f(_block_or_its_head_block(_ENV, i, y - 1))

    ::next_block::
  end
end

-- ボード内にあるいずれかのブロックが更新された場合に呼ばれる。
-- _changed フラグを立て各種キャッシュも更新・クリアする。
function board_class.observable_update(_ENV, block, old_state)
  local x, y = block.x, block.y

  cache_is_empty = {}

  if old_state == "swap" and block.swap_direction == "right" and block.state == "idle" then
    local new_x = x + 1
    local right_block = blocks[y][new_x]

    --#if assert
    assert(right_block.state == "swap" and right_block.swap_direction == "left", right_block.state)
    --#endif

    if right_block.type ~= "i" then
      particles:create(
        { screen_x(_ENV, x) - 2, screen_y(_ENV, y) + 3 },
        "1,1,10,10,-1,-0.8,0.05,0.05,3|1,1,10,10,-1,0,0.05,0,5|1,1,10,10,-1,0.8,0.05,-0.05,3"
      )
    end
    if block.type ~= "i" then
      particles:create(
        { screen_x(_ENV, new_x) + 10, screen_y(_ENV, y) + 3 },
        "1,1,10,10,1,-0.8,-0.05,0.05,3|1,1,10,10,1,0,-0.05,0,5|1,1,10,10,1,0.8,-0.05,-0.05,3"
      )
    end

    local right_block_other_x = right_block.other_x

    if block.other_x then
      blocks[y][block.other_x].other_x = new_x
    end

    if right_block_other_x then
      blocks[y][right_block_other_x].other_x = x
    end

    put(_ENV, new_x, y, block)
    put(_ENV, x, y, right_block)

    right_block:change_state("idle")

    return
  end

  -- 状態が hover から idle になった時、もし
  --   1. 下のブロックが空、または
  --   2. fall 状態の場合
  -- なら、ブロックを落とす
  --
  --  (1)        (2)
  -- ┌───┐      ┌───┐
  -- │ H │      │ H │
  -- └───┘  or  ├───┤
  --            │ ↓ │
  --            └───┘
  --
  if old_state == "hover" and _is_block_fallable(_ENV, x, y) then
    --#if assert
    assert(block.state == "idle", "ブロックの状態遷移がおかしい")
    --#endif

    block:fall()
  end

  if old_state == "match" and block.state == "idle" then
    sfx(11, -1, (block._match_index % 6 - 1) * 4, 4)
    put(_ENV, x, y, block.new_block)
    particles:create(
      { screen_x(_ENV, x) + 3, screen_y(_ENV, y) + 3 },
      "2,1,7,7,-1,-1,0.05,0.05,16|2,1,7,7,1,-1,-0.05,0.05,16|2,1,7,7,-1,1,0.05,-0.05,16|2,1,7,7,1,1,-0.05,-0.05,16"
    )
    return
  end

  if block.state == "hover" then
    for each_y = y + 1, #blocks do
      for each_x = 1, cols do
        if _check_hover_flag[each_y] == nil then
          _check_hover_flag[each_y] = {}
        end
        _check_hover_flag[each_y][each_x] = true
      end
    end
  end

  if reducible_blocks[y] == nil then
    reducible_blocks[y] = {}
  end
  if block:is_reducible() then
    reducible_blocks[y][x] = block
  else
    reducible_blocks[y][x] = nil
  end

  _changed = true

  if block:is_reducible() then
    cache_reduce = {}
  end

  if not (block.state == "swap" or block.state == "match") then
    for i = y, #blocks do
      cache_is_block_fallable[i] = {}
    end
  end
end

function board_class._memoize(_ENV, f, cache, x, y)
  if cache[y] == nil then
    cache[y] = {}
  end

  local result = cache[y][x]

  if result == nil then
    result = f(_ENV, x, y)
    cache[y][x] = result
  end

  return result
end

--#if debug
function board_class._tostring(_ENV)
  local str = ''

  for y = #blocks, 1, -1 do
    for x = 1, cols do
      local block = block_at(_ENV, x, y)

      if block.type == "i" and
          _garbage_head_block(_ENV, x, y) ~= nil then
        str = str .. "g " .. " "
      else
        str = str .. block:_tostring() .. " "
      end
    end
    str = str .. "\n"
  end

  return str
end

--#endif
