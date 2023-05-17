---@diagnostic disable: global-in-nil-env, lowercase-global

game_class = new_class()

local chain_bonus = transform(split("0,50,80,150,300,400,500,700,900,1100,1300,1500,1800"), tonum)

function game_class.reduce_callback(score, player, board, contains_swap)
  local score_delta = score >> 16
  player.score = player.score + score_delta

  if contains_swap then
    board.freeze_timer = 120
    sfx(49)
  end
end

function game_class.combo_callback(combo_count, coord, player, board, other_board)
  bubbles:create("combo", combo_count, coord)
  ions:create(
    coord,
    board.attack_ion_target,
    function(target)
      sfx(21)
      particles:create(
        target,
        "5,5,9,7,,,-0.03,-0.03,20|5,5,9,7,,,-0.03,-0.03,20|4,4,9,7,,,-0.03,-0.03,20|4,4,2,5,,,-0.03,-0.03,20|4,4,6,7,,,-0.03,-0.03,20|2,2,9,7,,,-0.03,-0.03,20|2,2,9,7,,,-0.03,-0.03,20|2,2,6,5,,,-0.03,-0.03,20|2,2,6,5,,,-0.03,-0.03,20|0,0,2,5,,,-0.03,-0.03,20"
      )

      local score = combo_count * 10
      local score_delta = score >> 16
      player.score = player.score + score_delta

      -- 対戦相手がいる時、おじゃまブロックを送る
      if other_board then
        other_board:send_garbage(nil, combo_count > 6 and 6 or combo_count - 1, 1)
      end
    end
  )
end

function game_class.block_offset_callback(chain_count, coord, player, board, other_board)
  local offset_height = chain_count

  if offset_height > 2 then
    ions:create(
      coord,
      board.block_offset_target,
      function(target)
        sfx(21)
        particles:create(
          target,
          "5,5,9,7,,,-0.03,-0.03,20|5,5,9,7,,,-0.03,-0.03,20|4,4,9,7,,,-0.03,-0.03,20|4,4,2,5,,,-0.03,-0.03,20|4,4,6,7,,,-0.03,-0.03,20|2,2,9,7,,,-0.03,-0.03,20|2,2,9,7,,,-0.03,-0.03,20|2,2,6,5,,,-0.03,-0.03,20|2,2,6,5,,,-0.03,-0.03,20|0,0,2,5,,,-0.03,-0.03,20"
        )

        local score = chain_bonus[chain_count] or 1800
        local score_delta = score >> 16
        player.score = player.score + score_delta

        if other_board then
          offset_height = board.pending_garbage_blocks:offset(offset_height)
        end
      end,
      9
    )
  end

  return offset_height
end

function game_class.chain_callback(chain_id, chain_count, coord, player, board, other_board)
  if chain_count > 1 then
    bubbles:create("chain", chain_count, coord)
    if chain_count > 2 then
      ions:create(
        coord,
        board.attack_ion_target,
        function(target)
          sfx(21)
          particles:create(
            target,
            "5,5,9,7,,,-0.03,-0.03,20|5,5,9,7,,,-0.03,-0.03,20|4,4,9,7,,,-0.03,-0.03,20|4,4,2,5,,,-0.03,-0.03,20|4,4,6,7,,,-0.03,-0.03,20|2,2,9,7,,,-0.03,-0.03,20|2,2,9,7,,,-0.03,-0.03,20|2,2,6,5,,,-0.03,-0.03,20|2,2,6,5,,,-0.03,-0.03,20|0,0,2,5,,,-0.03,-0.03,20"
          )

          local score = chain_bonus[chain_count] or 1800
          local score_delta = score >> 16
          player.score = player.score + score_delta

          -- 対戦相手がいる時、おじゃまブロックを送る
          if other_board then
            other_board:send_garbage(chain_id, 6, chain_count - 1 < 6 and chain_count - 1 or 5)
          end
        end
      )
    end
  else
    local score = chain_bonus[chain_count] or 1800
    local score_delta = score >> 16
    player.score = player.score + score_delta
  end
end

function game_class.is_game_over(_ENV)
  return game_over_time ~= nil
end

function game_class._init(_ENV)
  all_players_info, auto_raise_frame_count = {}, 30
end

function game_class.init(_ENV)
  countdown, start_time, game_over_time = 240, t()

  for _, each in pairs(all_players_info) do
    each.player:init()
    each.board:init()
    each.board:put_random_blocks()
  end

  music(-1) -- stop the music
end

function game_class.add_player(_ENV, player, board, other_board)
  add(
    all_players_info,
    {
      player = player,
      board = board,
      other_board = other_board,
      tick = 0
    }
  )
end

function game_class.update(_ENV)
  ripple:update()

  if countdown then
    countdown = countdown - 1
    local countdown_number = flr(countdown / 60 + 1)

    if countdown > 0 then
      start_time = t()

      if countdown_number < 4 then
        for _, each in pairs(all_players_info) do
          each.board.countdown = countdown_number
        end
      end

      if countdown % 60 == 0 then
        sfx(13)
      end
    elseif countdown == 0 then
      countdown = nil

      for _, each in pairs(all_players_info) do
        each.board.countdown = nil
      end

      sfx(14)
    end
  end

  if not countdown and    -- カウントダウン終了
      stat(46) == -1 and  -- カウントダウンの sfx が鳴り終わっている
      stat(54) == -1 then -- BGM がまだ始まっていない
    music(0)
  end

  local music_pattern_id = stat(54)
  if music_pattern_id then
    if all_players_info[1].board:is_topped_out() then
      if 0 <= music_pattern_id and music_pattern_id <= 7 then
        music(16)
      end
    else
      if 16 <= music_pattern_id and music_pattern_id <= 19 then
        music(0)
      end
    end
  end

  ripple.slow, ripple.freeze = false, false

  for _, each in pairs(all_players_info) do
    local player, board, other_board = each.player, each.board, each.other_board
    local cursor = board.cursor

    if board:is_game_over() then
      board:update()
      ripple.slow = false
    else
      player:update(board)

      if player.left then
        sfx(8)
        cursor:move_left()
      end
      if player.right then
        sfx(8)
        cursor:move_right(board.cols)
      end
      if player.up then
        sfx(8)
        cursor:move_up(board.rows)
      end
      if player.down then
        sfx(8)
        cursor:move_down()
      end
      if player.x and not countdown and board:swap(cursor.x, cursor.y) then
        sfx(10)
      end
      if player.o and not countdown and board.top_block_y > 2 then
        _raise(_ENV, each)
      end

      board:update(_ENV, player, other_board)
      cursor:update()

      if not countdown then
        _auto_raise(_ENV, each)
      end

      -- もしどちらかの board でおじゃまブロックを分解中だった場合 "slow" にする
      if board.contains_garbage_match_block then
        ripple.slow = true
      end

      -- もしフリーズ中だったら ripple も freeze にする
      ripple.freeze = board.freeze_timer > 0
    end
  end

  particles:update_all()
  bubbles:update_all()
  ions:update_all()

  if not game_over_time then
    -- ゲーム中だけ elapsed_time を更新
    elapsed_time = t() - start_time

    -- プレーヤーが 2 人であれば、勝ったほうの board に win = true をセット
    if #all_players_info == 1 then
      if all_players_info[1].board:is_game_over() then
        game_over_time = t()
      end
    else
      local board1, board2 = all_players_info[1].board, all_players_info[2].board

      if board1:is_game_over() or board2:is_game_over() then
        game_over_time = t()

        if board1.lose then
          board2.win = true
        end
        if board2.lose then
          board1.win = true
        end
      end
    end
  end
end

function game_class.render(_ENV) -- override
  ripple:render()

  for _, each in pairs(all_players_info) do
    local board = each.board

    board:render()

    -- カウントダウンの数字はカーソルの上に表示
    if board.countdown then
      local countdown_sprite_x = { 32, 16, 0 }
      sspr(
        countdown_sprite_x[board.countdown],
        80,
        16,
        16,
        board.offset_x + 16,
        43
      )
    end
  end

  particles:render_all()
  bubbles:render_all()
  ions:render_all()
end

-- ブロックをせりあげる
function game_class._raise(_ENV, player_info, force)
  local board = player_info.board

  if not board:is_topped_out() or force then
    board.raised_dots = board.raised_dots + 1

    if board.raised_dots == 8 then
      board.raised_dots = 0
      board:insert_blocks_at_bottom()
      board.cursor:move_up(board.rows)
    end
  end
end

-- 可能な場合ブロックを自動的にせりあげる
function game_class._auto_raise(_ENV, player_info)
  if player_info.board.freeze_timer > 0 or player_info.board:is_busy() then
    return
  end

  player_info.tick = player_info.tick + 1

  if player_info.tick > auto_raise_frame_count then
    _raise(_ENV, player_info, true)
    player_info.tick = 0
  end
end

-- ゲーム経過時間を文字列で返す (e.g., "01:23")
function game_class.elapsed_time_string(_ENV)
  local length2_number_string_0filled = function(num)
    return (num < 10) and "0" .. num or num
  end

  return length2_number_string_0filled(flr(elapsed_time / 60)) ..
      ":" ..
      length2_number_string_0filled(flr(elapsed_time) % 60)
end
