require("board")
require("player_cursor")
require("qpu")
require("plasma")

local flow = require("engine/application/flow")
local gamestate = require("gamestate")

-- main menu: gamestate for player navigating in main menu
local title_demo = derived_class(gamestate)
title_demo.type = ':title_demo'

local tick_start

function title_demo:on_enter()
  tick_start = 0
end

function title_demo:update()
  tick_start = (tick_start + 1) % 60

  demo_game:update()
  update_title_logo_bounce()

  if btnp(4) or btnp(5) then -- x または z でタイトルへ進む
    sfx(7)
    flow:query_gamestate_type(':title_menu')
  end
end

function title_demo:render()
  render_plasma()

  -- ロゴを表示
  -- attack bubble をロゴの上に表示するので、最初に描画
  sspr(0, 64, 128, 16, 0, 24 + title_logo_bounce_screen_dy)

  demo_game:render()

  -- Z/X start を表示
  if tick_start < 30 then
    print_outlined_bold("z/x start", 50, 50, 1)
  end
end

function print_outlined_bold(str, x, y, color)
  for _, dx in pairs({ -2, -1, 0, 1, 2 }) do
    for _, dy in pairs({ -2, -1, 0, 1, 2 }) do
      print(str, x + dx, y + dy, 0)
    end
  end

  for _, dx in pairs({ -1, 0, 1 }) do
    for _, dy in pairs({ -1, 0, 1 }) do
      print(str, x + dx, y + dy, 12)
    end
  end

  print(str, x, y, color)
end

return title_demo
