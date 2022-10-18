local flow = require("engine/application/flow")
local ui = require("engine/ui/ui")

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
  board:initialize_with_random_gates()
  player:init()

  game:add_player(player, board, player_cursor)
end

function solo:update()
  if board:is_game_over() then
    if btnp(buttons.o) then
      flow:query_gamestate_type(':title')
    end
  else
    game:update()
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
    ui.draw_rounded_box(10, 55, 117, 78, colors.dark_gray, colors.white)
    ui.print_centered("game over", 64, 63, colors.red)
    ui.print_centered("push x to replay", 64, 71, colors.black)
  end
end

return solo
