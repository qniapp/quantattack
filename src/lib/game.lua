require("lib/helpers")

local game = new_class()
local attack_bubble = require("lib/attack_bubble")

require("lib/bubble")
require("lib/helpers")
require("lib/particle")
require("lib/ripple")

local all_players, countdown

function game.reduce_callback(score, _x, _y, player)
  player.score = player.score + score
end

function game.combo_callback(combo_count, x, y, player, board, other_board)
  local attack_cube_callback = function(target_x, target_y)
    sfx(12)
    create_particle_set(target_x, target_y,
      "5,5,9,7,random,random,-0.03,-0.03,20|5,5,9,7,random,random,-0.03,-0.03,20|4,4,9,7,random,random,-0.03,-0.03,20|4,4,2,5,random,random,-0.03,-0.03,20|4,4,6,7,random,random,-0.03,-0.03,20|2,2,9,7,random,random,-0.03,-0.03,20|2,2,9,7,random,random,-0.03,-0.03,20|2,2,6,5,random,random,-0.03,-0.03,20|2,2,6,5,random,random,-0.03,-0.03,20|0,0,2,5,random,random,-0.03,-0.03,20")

    player.score = player.score + combo_count

    -- 対戦相手がいる時、おじゃまゲートを送る
    if other_board then
      other_board:send_garbage(nil, combo_count > 6 and 6 or combo_count - 1, 1)
    end
  end

  create_bubble("combo", combo_count, board:screen_x(x), board:screen_y(y))
  attack_bubble:create(
    board:screen_x(x), board:screen_y(y),
    attack_cube_callback,
    unpack(board.attack_cube_target)
  )
end

local chain_bonus = { 0, 5, 8, 15, 30, 40, 50, 70, 90, 110, 130, 150, 180 }

function game.gate_offset_callback(chain_id, chain_count, x, y, player, board, other_board)
  local offset_height = chain_count

  if offset_height > 2 then
    local attack_cube_callback = function(target_x, target_y)
      sfx(12)
      create_particle_set(target_x, target_y,
        "5,5,9,7,random,random,-0.03,-0.03,20|5,5,9,7,random,random,-0.03,-0.03,20|4,4,9,7,random,random,-0.03,-0.03,20|4,4,2,5,random,random,-0.03,-0.03,20|4,4,6,7,random,random,-0.03,-0.03,20|2,2,9,7,random,random,-0.03,-0.03,20|2,2,9,7,random,random,-0.03,-0.03,20|2,2,6,5,random,random,-0.03,-0.03,20|2,2,6,5,random,random,-0.03,-0.03,20|0,0,2,5,random,random,-0.03,-0.03,20")

      player.score = player.score + (chain_bonus[chain_count] or 180)

      if other_board then
        offset_height = board.pending_garbage_gates:offset(offset_height)
      end
    end

    attack_bubble:create(
      board:screen_x(x), board:screen_y(y),
      attack_cube_callback,
      unpack(board.gate_offset_target)
    )
  end

  return offset_height
end

function game.chain_callback(chain_id, chain_count, x, y, player, board, other_board)
  if chain_count > 2 then
    local attack_cube_callback = function(target_x, target_y)
      sfx(12)
      create_particle_set(target_x, target_y,
        "5,5,9,7,random,random,-0.03,-0.03,20|5,5,9,7,random,random,-0.03,-0.03,20|4,4,9,7,random,random,-0.03,-0.03,20|4,4,2,5,random,random,-0.03,-0.03,20|4,4,6,7,random,random,-0.03,-0.03,20|2,2,9,7,random,random,-0.03,-0.03,20|2,2,9,7,random,random,-0.03,-0.03,20|2,2,6,5,random,random,-0.03,-0.03,20|2,2,6,5,random,random,-0.03,-0.03,20|0,0,2,5,random,random,-0.03,-0.03,20")

      player.score = player.score + (chain_bonus[chain_count] or 180)

      -- 対戦相手がいる時、おじゃまゲートを送る
      if other_board then
        other_board:send_garbage(chain_id, 6, chain_count - 1 < 6 and chain_count - 1 or 5)
      end
    end

    create_bubble("chain", chain_count, board:screen_x(x), board:screen_y(y))
    attack_bubble:create(
      board:screen_x(x), board:screen_y(y),
      attack_cube_callback,
      unpack(board.attack_cube_target)
    )
  else
    player.score = player.score + (chain_bonus[chain_count])
  end
end

function game:is_game_over()
  return self.game_over_time ~= nil
end

function game:_init()
  self.auto_raise_frame_count = 30
end

function game:init()
  all_players = {}
  countdown = 240
  self.start_time = t()
  self.game_over_time = nil
  init_ripple()
end

function game:add_player(player, player_cursor, board, other_board)
  player.player_cursor = player_cursor
  player.board = board
  player.other_board = other_board
  player.tick = 0

  add(all_players, player)
end

function game:update()
  update_ripple()

  if countdown then
    countdown = countdown - 1
    local countdown_number = flr(countdown / 60 + 1)

    if countdown > 0 then
      self.start_time = t()

      if countdown_number < 4 then
        for _, each in pairs(all_players) do
          each.board.countdown = countdown_number
        end
      end

      if countdown % 60 == 0 then
        sfx(5)
      end
    elseif countdown == 0 then
      countdown = nil

      for _, each in pairs(all_players) do
        each.board.countdown = nil
      end

      sfx(6)
    end
  end

  -- もしどちらかの board でおじゃまゲートを分解中だった場合 "slow" にする
  ripple_speed = "normal"

  for index, each in pairs(all_players) do
    local player_cursor = each.player_cursor
    local board = each.board
    local other_board = each.other_board

    if board:is_game_over() then
      board:update()
      ripple_speed = "normal"
    else
      each:update(board)

      if each.left then
        sfx(0)
        player_cursor:move_left()
      end
      if each.right then
        sfx(0)
        player_cursor:move_right()
      end
      if each.up then
        sfx(0)
        player_cursor:move_up()
      end
      if each.down then
        sfx(0)
        player_cursor:move_down()
      end
      if each.o and not countdown and board:swap(player_cursor.x, player_cursor.y) then
        sfx(2)
      end
      if each.x and not countdown and board.top_gate_y > 2 then
        self:_raise(each)
      end

      board:update(self, each, other_board)
      player_cursor:update()

      if not countdown then
        self:_auto_raise(each)
      end

      if board.contains_garbage_match_gate then
        ripple_speed = "slow"
      end
    end
  end

  update_particles()
  update_bubbles()
  attack_bubble:update()

  if not self:is_game_over() then
    -- ゲーム中だけ elapsed_time を更新
    game.elapsed_time = t() - self.start_time

    -- プレーヤーが 2 人であれば、勝ったほうの board に win = true をセット
    if #all_players == 1 then
      if all_players[1].board:is_game_over() then
        self.game_over_time = t()
      end
    else
      local board1, board2 = all_players[1].board, all_players[2].board

      if board1:is_game_over() or board2:is_game_over() then
        self.game_over_time = t()

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

function game:render() -- override
  render_ripple()

  for _, each in pairs(all_players) do
    local player_cursor = each.player_cursor
    local board = each.board

    board:render()

    if not board:is_game_over() then
      player_cursor:render()
    end

    -- カウントダウンの数字はカーソルの上に表示
    if board.countdown then
      local countdown_sprite_x = { 96, 80, 64 }
      sspr(countdown_sprite_x[board.countdown], 32,
        16, 16,
        board.offset_x + 16, board.offset_y + 43)
    end
  end

  render_particles()
  render_bubbles()
  attack_bubble:render()

  -- print_outlined(stat(1), 101, 112, 7)
  -- print_outlined(stat(7), 117, 120, 7)
end

-- ゲートをせりあげる
function game:_raise(player)
  local board, cursor = player.board, player.player_cursor

  board.raised_dots = board.raised_dots + 1

  if board.raised_dots == 8 then
    board.raised_dots = 0
    board:insert_gates_at_bottom(player.steps)
    cursor:move_up()
    player.steps = player.steps + 1
  end
end

-- 可能な場合ゲートを自動的にせりあげる
function game:_auto_raise(player)
  if player.board:is_busy() then
    return
  end

  player.tick = player.tick + 1

  if player.tick > self.auto_raise_frame_count then
    self:_raise(player)
    player.tick = 0
  end
end

-- ゲーム経過時間を文字列で返す (e.g., "01:23")
function game:elapsed_time_string()
  return length2_number_string_0filled(flr(self.elapsed_time / 60)) ..
      ":" ..
      length2_number_string_0filled(flr(self.elapsed_time) % 60)
end

function length2_number_string_0filled(num)
  return (num < 10) and "0" .. num or num
end

return game
