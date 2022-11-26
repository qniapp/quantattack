require("lib/board")

local board = create_board()
board.attack_cube_target = { 85, 30 }

require("lib/player")
local player = create_player()

require("lib/player_cursor")
local player_cursor = create_player_cursor(board)

local game_class = require("lib/game")
local game = game_class()

local gamestate = require("lib/gamestate")
local solo = derived_class(gamestate)

solo.type = ':solo'

local last_steps = 0

function solo:on_enter()
  player:init()
  board:put_random_gates()
  player_cursor:init()

  game:init()
  game:add_player(player, player_cursor, board)
end

function solo:update()
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
      board.push_any_key = true
      if btnp(4) or btnp(5) then -- x または z でタイトルへ戻る
        load('qitaev_title')
      end
    end
  end
end

function solo:render() -- override
  game:render()

  -- スコア表示
  color(7)
  cursor(board.offset_x * 2 + board.width, 16)
  print(player.steps .. " steps")

  -- skip 2 lines and draw score
  cursor(board.offset_x * 2 + board.width, 24)
  print("score " .. player.score .. (player.score == 0 and "" or "0"))
end

return solo
