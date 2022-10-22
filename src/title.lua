require("engine/core/class")
require("engine/render/color")
require("helpers")

local gamestate = require("engine/application/gamestate")
local menu_item = require("menu_item")
local text_menu_class = require("text_menu")

-- main menu: gamestate for player navigating in main menu
local title = derived_class(gamestate)
title.type = ':title'

-- sequence of menu items to display, with their target states
title._items = {
  menu_item("solo", ':solo'),
  menu_item("vs qpu", ':vs')
}

local text_menu = text_menu_class(title._items)

function title:update()
  text_menu:update()
end

function title:render()
  -- ロゴを表示
  mfunc("cls,spr,128,29,20,9,2")

  text_menu:draw(48, 72) -- 40 + 4 * character_height
end

return title
