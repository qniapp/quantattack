require("lib/board")

local sash = require("lib/sash")
local flow = require("lib/flow")

-- ハイスコア関係
local high_score_class = require("lib/high_score")
local high_score = high_score_class(0)
local current_high_score

local board = create_board()
board.attack_cube_target = { 85, 30 }

require("lib/player")
local player = create_player()

require("lib/player_cursor")
local player_cursor = create_player_cursor(board)

local game_class = require("time_attack/game")
local game = game_class()

local gamestate = require("lib/gamestate")
local time_attack = derived_class(gamestate)

time_attack.type = ':time_attack'

local last_steps = 0

function time_attack:on_enter()
  current_high_score = high_score:get()

  player:init()
  board:init()
  board:put_random_gates()
  player_cursor:init()

  game:init()
  game:add_player(player, player_cursor, board)
end

function time_attack:update()
  game:update()

  if player.steps > last_steps then
    -- 10 ステップごとに
    --   * おじゃまゲートを降らせる (最大 10 段)
    --   * ゲートをせり上げるスピードを上げる
    if player.steps > 0 and player.steps % 10 == 0 then
      if game.auto_raise_frame_count > 10 then
        game.auto_raise_frame_count = game.auto_raise_frame_count - 1
      end
      board:send_garbage(nil, 6, player.steps / 10 < 11 and player.steps / 10 or 10)
    end
    last_steps = player.steps
  end

  if game:is_game_over() then
    if t() - game.game_over_time > 2 then
      board.show_gameover_menu = true
      if btnp(4) then -- x でリプレイ
        flow:query_gamestate_type(":time_attack")
      elseif btnp(5) then -- z でタイトルへ戻る
        load('qitaev_title')
      end
    end
  else
    if game.time_left <= 0 then
      board.timeup = true
      game.game_over_time = t()
      sfx(16)
      sash:create("time up!", 13, 7, function()
        if high_score:put(player.score) then
          sfx(22)
          sash:create("high score!", 9, 8)
        end
      end)
    end
  end

  sash:update()
end

function time_attack:render() -- override
  game:render()

  local base_x = board.offset_x * 2 + board.width

  -- スコア表示
  print_outlined("score " .. player.score .. (player.score == 0 and "" or "0"), base_x, 16, 7, 0)
  print_outlined("hi-score " .. current_high_score * 10, base_x, 24, 7, 0)

  -- 残り時間表示
  print_outlined("time left", base_x, 44, 7, 0)
  print_outlined(game:time_left_string(), base_x, 52, 7, 0)

  if not game:is_game_over() then
    spr(112, base_x, 109)
    print_outlined("swap gates", 81, 110, 7, 0)
    spr(99, base_x, 119)
    print_outlined("raise gates", 81, 120, 7, 0)
  end

  sash:render()
end

return time_attack
