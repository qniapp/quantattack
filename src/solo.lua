require("helpers")

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
  if board:is_game_over() then
    if btnp(5) then
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
    local center_x, center_y = board.offset_x + board.width / 2, board.offset_y + board.height / 2

    draw_rounded_box(center_x - 22, center_y - 7,
                     center_x + 20, center_y + 22,
                     colors.dark_blue, colors.white)
    print_centered("game over", center_x, center_y, colors.red)
    print_centered("push x\nto replay", center_x, center_y + character_height * 2, colors.black)
  end
end

return solo
