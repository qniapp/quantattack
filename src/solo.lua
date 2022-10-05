local gamestate = require("engine/application/gamestate")
require("engine/core/class")
-- require("engine/render/color")
-- local ui = require("engine/ui/ui")

-- local menu_item = require("menu/menu_item")
-- local text_menu = require("menu/text_menu")

-- main menu: gamestate for player navigating in main menu
local solo = derived_class(gamestate)

solo.type = ':solo'

-- sequence of menu items to display, with their target states
-- solo._items = transform({
--     {"debug demo", ':debug_demo'},
--     {"input demo", ':input_demo'},
--     {"render demo", ':render_demo'}
--   }, unpacking(menu_item))

-- text_menu: text_menu    component handling menu display and selection
function solo:_init()
  -- self.text_menu = text_menu(solo._items)
end

function solo:on_enter()
  -- do not reset previous selection to retain last user choice
end

function solo:on_exit()
end

function solo:update()
  -- self.text_menu:update()
end

function solo:render()
  -- cls()

  -- local title_y = 48
  -- ui.print_centered("main menu", 64, title_y, colors.white)

  -- -- skip 4 lines and draw menu content
  -- self.text_menu:draw(title_y + 4 * character_height)
end

return solo
