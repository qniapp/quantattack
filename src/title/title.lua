require("board")

local gamestate = require("gamestate")
local menu_item = require("menu_item")
local text_menu_class = require("text_menu")

-- main menu: gamestate for player navigating in main menu
local title = derived_class(gamestate)
title.type = ':title'

-- sequence of menu items to display, with their target states
title._items = {
  menu_item("solo", 'qitaev_solo'),
  menu_item("vs qpu", 'qitaev_vs_qpu'),
  menu_item("qpu vs qpu", 'qitaev_qpu_vs_qpu')
}

local text_menu = text_menu_class(title._items)

function title:on_enter()
  -- NOP
end

function title:update()
  text_menu:update()
end

function title:render()
  demo_game:render()

  -- ロゴを表示
  sspr(0, 64, 128, 16, 0, 24)

  -- メニューのウィンドウを表示
  draw_rounded_box(32, 66, 95, 94, 7, 0)

  -- メニューを表示
  text_menu:draw(40, 72) -- 40 + 4 * character_height (= 6)
end

return title
