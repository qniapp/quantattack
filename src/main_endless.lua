require("lib/helpers")
require("lib/player")

local sash = require("lib/sash")

-- ハイスコア関係
local high_score_class = require("lib/high_score")
local high_score = high_score_class(1)
local current_high_score

local cursor_class = require("lib/cursor")
local cursor = cursor_class()

local board_class = require("lib/board")
local board = board_class(cursor)
board.attack_cube_target = { 85, 30 }

local player = player_class()

local game_class = require("lib/game")
local game = game_class()

local gamestate = require("lib/gamestate")
local endless = derived_class(gamestate)

endless.type = ':endless'

local last_steps = 0

function _init()
  current_high_score = high_score:get()

  player:init()
  board:init()
  board:put_random_blocks()
  cursor:init()

  game:init()
  game:add_player(player, board)
end

function _update60()
  game:update()

  if board.steps > last_steps then
    -- 10 ステップごとに
    --   * おじゃまブロックを降らせる (最大 10 段)
    --   * ブロックをせり上げるスピードを上げる
    if board.steps > 0 and board.steps % 10 == 0 then
      if game.auto_raise_frame_count > 10 then
        game.auto_raise_frame_count = game.auto_raise_frame_count - 1
      end
      board:send_garbage(nil, 6, board.steps / 10 < 11 and board.steps / 10 or 10)
    end
    last_steps = board.steps
  end

  if game:is_game_over() then
    if t() - game.game_over_time > 2 then
      if not board.show_gameover_menu then
        if high_score:put(player.score) then
          sfx(22)
          sash:create("high score!", 9, 8)
        end
      end

      board.show_gameover_menu = true
      if btnp(5) then -- x でリプレイ
        _init()
      elseif btnp(4) then -- c でタイトルへ戻る
        jump('quantattack_title')
      end
    end
  end

  sash:update()
end

function _draw()
  cls()

  game:render()

  local base_x = board.offset_x * 2 + board.width

  -- スコア表示
  print_outlined("score " .. score_string(player.score), base_x, 16, 7, 0)
  print_outlined("hi-score " .. score_string(current_high_score), base_x, 24, 7, 0)
  print_outlined(board.steps .. " steps", base_x, 38, 7, 0)

  if not game:is_game_over() then
    spr(99, base_x, 109)
    print_outlined("swap blocks", 81, 110, 7, 0)
    spr(112, base_x, 119)
    print_outlined("raise blocks", 81, 120, 7, 0)
  end

  sash:render()
end
