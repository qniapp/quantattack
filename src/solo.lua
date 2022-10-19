local flow = require("engine/application/flow")

local board_class = require("board")
local board = board_class()

local player_class = require("player")
local player = player_class()

local player_cursor_class = require("player_cursor")
local player_cursor = player_cursor_class(board)

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
  game:add_player(player, board, player_cursor)
end

function solo:update()
  game:update()

  if board:is_game_over() then
    if player.x then
      flow:query_gamestate_type(':title')
    end
  end

  if not board:is_busy() and board.chain_count > 1 then
    board:drop_garbage()
    board.chain_count = 0
  end
end

function solo:render() -- override
  game:render()

  -- solo 独自の処理

  -- スコア表示
  color(colors.white)
  cursor(board.offset_x * 2 + board.width, board.offset_y)
  print(player.steps .. " steps")

  -- skip 2 lines and draw score
  cursor(board.offset_x * 2 + board.width, board.offset_y + 2 * character_height)
  print("score " .. player.score .. (player.score == 0 and "" or "0"))

  -- ゲームオーバー
  if board:is_game_over() then
    board:game_over()
  end
end

return solo
