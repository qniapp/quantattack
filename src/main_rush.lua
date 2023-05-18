require("lib/helpers")
require("lib/board")
require("lib/player")
require("lib/high_score")

-- ハイスコア関係
local high_score = high_score_class(0)
local current_high_score

local cursor = cursor_class()

local board = board_class(cursor)
board.attack_ion_target = { 85, 30 }

local player = player_class()

local game_class = require("rush/game")
local game = game_class()
local last_steps = -1

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
    -- 5 ステップごとに
    --   * おじゃまブロックを降らせる
    --   * ブロックをせり上げるスピードを上げる
    if board.steps % 5 == 0 then
      if game.auto_raise_frame_count > 10 then
        game.auto_raise_frame_count = game.auto_raise_frame_count - 1
      end
      board:send_garbage(nil, 6, (board.steps + 5) / 5)
    end
    last_steps = board.steps
  end

  if game:is_game_over() then
    if t() - game.game_over_time > 2 then
      if high_score:put(player.score) then
        sfx(22)
        -- sash:create("high score!", 7, 8)
        sash:create("high score!,7,8")
      end

      board.show_gameover_menu = true
      if btnp(5) then -- x でリプレイ
        sfx(15)
        current_high_score = high_score:get()
        _init()
      elseif btnp(4) then -- z でタイトルへ戻る
        jump('quantattack_title')
      end
    end
  else
    if game.time_left <= 0 then
      board.timeup = true
      game.game_over_time = t()
      sfx(16)
      -- sash:create("time up!", 13, 7, function()
      sash:create("time up!,13,7", function()
        if high_score:put(player.score) then
          sfx(22)
          -- sash:create("high score!", 7, 8)
          sash:create("high score!,7,8")
        end
      end)
    end
  end

  sash:update_all()
end

function _draw()
  cls()

  game:render()

  local base_x = board.offset_x * 2 + board.width

  -- スコア表示
  print_outlined("score " .. tostr(player.score, 0x2), base_x, 16, 7, 0)
  print_outlined("hi-score " .. tostr(current_high_score, 0x2), base_x, 24, 7, 0)

  -- 残り時間表示
  print_outlined("time left", base_x, 44, 7, 0)
  print_outlined(game:time_left_string(), base_x, 52, 7, 0)

  if not game:is_game_over() then
    spr(99, base_x, 109)
    print_outlined("swap blocks", 81, 110, 7, 0)
    spr(112, base_x, 119)
    print_outlined("raise blocks", 81, 120, 7, 0)
  end

  sash:render_all()
end
