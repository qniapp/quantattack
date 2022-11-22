require("board")
require("player_cursor")
require("qpu")

local flow = require("engine/application/flow")
local gamestate = require("gamestate")

local game_class = require("title/game")
local game = game_class()

-- local qpu_board = create_board(3)
local qpu_board = create_board(0, 16)
-- qpu1_board.gate_offset_target, qpu2_board.gate_offset_target = { 3 + 24, 0 }, { 78 + 24, 0 }
-- qpu1_board.attack_cube_target, qpu2_board.attack_cube_target = { 78 + 24, 0 }, { 3 + 24, 0 }
local qpu_cursor = create_player_cursor(qpu_board)
local qpu = create_qpu(qpu_cursor, qpu_board)

-- main menu: gamestate for player navigating in main menu
local title_demo = derived_class(gamestate)
title_demo.type = ':title_demo'

local tick_start

function title_demo:on_enter()
  tick_start = 0

  qpu:init()
  qpu_board:put_random_gates()
  qpu_cursor:init()

  qpu_board.show_top_line = false

  game:init()
  game:add_player(qpu, qpu_cursor, qpu_board)
end

function title_demo:update()
  tick_start = (tick_start + 1) % 60

  game:update()

  if btnp(4) or btnp(5) then -- x または z でタイトルへ進む
    flow:query_gamestate_type(':title')
  end
end

function title_demo:render()
  game:render()

  -- Z/X start を表示
  -- TODO: 点滅させる
  if tick_start < 30 then
    print_outlined_bold("z/x start", 50, 100, 15)
  end

  -- ロゴを表示
  sspr(0, 64, 128, 16, 0, 24)
end

function print_outlined_bold(str, x, y, color)
  for _, dx in pairs({-2, -1, 0, 1, 2}) do
    for _, dy in pairs({-2, -1, 0, 1, 2}) do
      print(str, x + dx, y + dy, 1)
    end
  end
  print(str, x, y, color)
end

return title_demo
