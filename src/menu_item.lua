require("engine/core/class")

-- a single menu item leading to a gamestate on confirm
local menu_item = new_struct()

-- label: string           text displayed in the menu
-- target_state: string    type of the gamestate entered on confirm
function menu_item:_init(label, target_state)
  self.label = label
  self.target_state = target_state
end

return menu_item
