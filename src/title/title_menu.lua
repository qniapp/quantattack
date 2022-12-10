require("lib/board")
require("title/plasma")

local gamestate = require("lib/gamestate")
local menu_item = require("title/menu_item")
local menu_class = require("title/menu")

-- main menu: gamestate for player navigating in main menu
local title_menu = derived_class(gamestate)
title_menu.type = ':title_menu'

-- ハイスコア
local high_score = require("lib/high_score")

-- sequence of menu items to display, with their target states
title_menu._items = {
  menu_item("mission", 'clear 9 waves', 32, 'qitaev_mission'),
  menu_item("time attack", 'play for 2 minutes', 48, 'qitaev_time_attack', high_score(0):get() * 10),
  menu_item("endless", 'play as long as you can', 64, 'qitaev_endless', high_score(1):get() * 10),
  menu_item("vs qpu", 'defeat the qpu', 80, 'qitaev_vs_qpu'),
  menu_item("qpu vs qpu", 'watch qpu vs qpu', 96, 'qitaev_qpu_vs_qpu')
}

local menu = menu_class(title_menu._items)

function title_menu:on_enter()
  -- NOP
end

function title_menu:update()
  menu:update()
end

function title_menu:render()
  render_plasma()

  demo_game:render()

  -- ロゴを表示
  sspr(0, 64, 128, 16, 0, 24)

  -- メニューのウィンドウを表示
  draw_rounded_box(7, 46, 118, 105, 0, 0) -- ふちどり
  draw_rounded_box(8, 47, 117, 104, 12, 12) -- 枠線
  draw_rounded_box(10, 49, 115, 102, 1, 1) -- 本体

  -- メニューを表示
  menu:draw(15, 72)
end

return title_menu
