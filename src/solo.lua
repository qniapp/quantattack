require("board")

local board = create_board()
board.attack_cube_target = { 85, 30 }

require("player")
local player = create_player()

require("player_cursor")
local player_cursor = create_player_cursor(board)

local game_class = require("game")
local game = game_class()

local gamestate = require("engine/application/gamestate")
local solo = derived_class(gamestate)

solo.type = ':solo'

function solo:on_enter()
  player:init()
  board:initialize_with_random_gates()
  player_cursor:init()

  game:init()
  game:add_player(player, player_cursor, board)
end

function solo:update()
  game:update()

  if board:is_game_over() then
    if player.x then
      load('qitaev_title')
    end
  end
end

function solo:render() -- override
  game:render()

  -- solo 独自の処理

  -- スコア表示
  color(7)
  cursor(board.offset_x * 2 + board.width, board.offset_y)
  print("score " .. player.score .. (player.score == 0 and "" or "0"))

  -- skip 2 lines and draw score
  cursor(board.offset_x * 2 + board.width, board.offset_y + 12)
  print(player.steps .. " steps")

  -- ゲームオーバー
  if board:is_game_over() then
    board:game_over()
  end
end

return solo
