local pending_garbage_blocks = pending_garbage_blocks_class()
local game = new_class()

local all_players_info, countdown

local chain_bonus = transform(split("0,50,80,150,300,400,500,700,900,1100,1300,1500,1800"), tonum)

function game.reduce_callback(score, player, board, contains_swap)
  local score_delta = score >> 16
  player.score = player.score + score_delta

  if contains_swap then
    board.freeze_timer = 120
  end
end

function game.combo_callback(combo_count, screen_x, screen_y, player, board, other_board)
  bubbles:create("combo", combo_count, screen_x, screen_y)
  local ion_target_x, ion_target_y = unpack(board.attack_ion_target)
  ions:create(
    screen_x,
    screen_y,
    ion_target_x,
    ion_target_y,
    function(target_x, target_y)
      sfx(21)
      particles:create(target_x, target_y,
        "5,5,9,7,,,-0.03,-0.03,20|5,5,9,7,,,-0.03,-0.03,20|4,4,9,7,,,-0.03,-0.03,20|4,4,2,5,,,-0.03,-0.03,20|4,4,6,7,,,-0.03,-0.03,20|2,2,9,7,,,-0.03,-0.03,20|2,2,9,7,,,-0.03,-0.03,20|2,2,6,5,,,-0.03,-0.03,20|2,2,6,5,,,-0.03,-0.03,20|0,0,2,5,,,-0.03,-0.03,20")

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

function game.block_offset_callback(chain_count, screen_x, screen_y, player, board, other_board)
  local offset_height = chain_count

  if offset_height > 2 then
    local ion_target_x, ion_target_y = unpack(board.block_offset_target)
    ions:create(
      screen_x,
      screen_y,
      ion_target_x,
      ion_target_y,
      function(target_x, target_y)
        sfx(21)
        particles:create(target_x, target_y,
          "5,5,9,7,,,-0.03,-0.03,20|5,5,9,7,,,-0.03,-0.03,20|4,4,9,7,,,-0.03,-0.03,20|4,4,2,5,,,-0.03,-0.03,20|4,4,6,7,,,-0.03,-0.03,20|2,2,9,7,,,-0.03,-0.03,20|2,2,9,7,,,-0.03,-0.03,20|2,2,6,5,,,-0.03,-0.03,20|2,2,6,5,,,-0.03,-0.03,20|0,0,2,5,,,-0.03,-0.03,20")

        local score = chain_bonus[chain_count] or 1800
        local score_delta = score >> 16
        player.score = player.score + score_delta

        if other_board then
          offset_height = pending_garbage_blocks:offset(offset_height)
        end
      end,
      9
    )
  end

  return offset_height
end

function game.chain_callback(chain_id, chain_count, screen_x, screen_y, player, board, other_board)
  if chain_count > 1 then
    bubbles:create("chain", chain_count, screen_x, screen_y)
    local ion_target_x, ion_target_y = unpack(board.attack_ion_target)
    ions:create(
      screen_x,
      screen_y,
      ion_target_x,
      ion_target_y,
      function(target_x, target_y)
        sfx(21)
        particles:create(target_x, target_y,
          "5,5,9,7,,,-0.03,-0.03,20|5,5,9,7,,,-0.03,-0.03,20|4,4,9,7,,,-0.03,-0.03,20|4,4,2,5,,,-0.03,-0.03,20|4,4,6,7,,,-0.03,-0.03,20|2,2,9,7,,,-0.03,-0.03,20|2,2,9,7,,,-0.03,-0.03,20|2,2,6,5,,,-0.03,-0.03,20|2,2,6,5,,,-0.03,-0.03,20|0,0,2,5,,,-0.03,-0.03,20")

        local score = chain_bonus[chain_count] or 1800
        local score_delta = score >> 16
        player.score = player.score + score_delta

        -- 対戦相手がいる時、おじゃまブロックを送る
        if other_board then
          other_board:send_garbage(chain_id, 6, chain_count - 1 < 6 and chain_count - 1 or 5)
        end
      end
    )
  else
    local score = chain_bonus[chain_count] or 1800
    local score_delta = score >> 16
    player.score = player.score + score_delta
  end
end

function game:is_game_over()
  return self.game_over_time ~= nil
end

function game:_init()
  self.auto_raise_frame_count = 10
end

function game:init()
  all_players_info = {}
  countdown = 240
  self.start_time = t()
  self.game_over_time = nil
  self.time_left = nil

  music(-1) -- stop the music
end

function game:add_player(player, board, other_board)
  add(all_players_info, {
    player = player,
    board = board,
    other_board = other_board,
    tick = 0
  })
end

function game:update()
  ripple:update()

  if countdown then
    countdown = countdown - 1
    local countdown_number = flr(countdown / 60 + 1)

    if countdown > 0 then
      self.start_time = t()

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

  -- もしどちらかの board でおじゃまブロックを分解中だった場合 "slow" にする
  ripple.slow = false

  for index, each in pairs(all_players_info) do
    local player = each.player
    local board = each.board
    local cursor = board.cursor
    local other_board = each.other_board

    if self:is_game_over() then
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
        self:_raise(each)
      end

      board:update(self, player, other_board)
      cursor:update()

      if not countdown then
        self:_auto_raise(each)
      end

      if board.contains_garbage_match_block then
        ripple.slow = true
      end
    end
  end

  particles:update_all()
  bubbles:update_all()
  ions:update_all()

  if all_players_info[1].board:is_game_over() then
    if self.game_over_time == nil then
      self.game_over_time = t()
    end
  else
    -- ゲーム中だけ time_left を更新
    game.time_left = 120 - (t() - self.start_time)
  end
end

function game:render() -- override
  ripple:render()

  for _, each in pairs(all_players_info) do
    local board = each.board

    board:render()

    -- カウントダウンの数字はカーソルの上に表示
    if board.countdown then
      local countdown_sprite_x = { 32, 16, 0 }
      sspr(countdown_sprite_x[board.countdown], 80,
        16, 16,
        board.offset_x + 16, 43)
    end
  end

  particles:render_all()
  bubbles:render_all()
  ions:render_all()
end

-- ブロックをせりあげる
function game:_raise(player_info, force)
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
function game:_auto_raise(player_info)
  if player_info.board.freeze_timer > 0 or player_info.board:is_busy() then
    return
  end

  player_info.tick = player_info.tick + 1

  if player_info.tick > self.auto_raise_frame_count then
    self:_raise(player_info, true)
    player_info.tick = 0
  end
end

-- 残り時間を文字列で返す (e.g., "01:23")
function game:time_left_string()
  return length2_number_string_0filled(flr(self.time_left / 60)) ..
      ":" ..
      length2_number_string_0filled(ceil(self.time_left) % 60)
end

function length2_number_string_0filled(num)
  return (num < 10) and "0" .. num or num
end

return game
