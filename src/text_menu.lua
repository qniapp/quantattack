require("engine/application/constants")

local flow = require("engine/application/flow")
local input = require("engine/input/input")

-- text menu: class representing a menu with labels and arrow-based navigation
local text_menu = new_class()

-- parameters
-- items: {menu_item}      sequence of items to display
--
-- state
-- selection_index: int    index of the item currently selected
function text_menu:_init(items)
  -- parameters
  self.items = items

  -- state
  self.selection_index = 1
end

-- handle navigation input
function text_menu:update()
  if input:is_just_pressed(button_ids.up) then
    self:select_previous()
  elseif input:is_just_pressed(button_ids.down) then
    self:select_next()
  elseif input:is_just_pressed(button_ids.x) or input:is_just_pressed(button_ids.o) then
    self:confirm_selection()
  end
end

function text_menu:select_previous()
  -- clamp selection
  self.selection_index = max(self.selection_index - 1, 1)
end

function text_menu:select_next()
  -- clamp selection
  self.selection_index = min(self.selection_index + 1, #self.items)
end

function text_menu:confirm_selection()
  -- currently, text menu is only used to navigate to other gamestates,
  -- but later, it may support generic on_confirm callbacks
  flow:query_gamestate_type(self.items[self.selection_index].target_state)
end

function text_menu:draw(left, top)
  local y = top

  for i = 1, #self.items do
    local label = self.items[i].label
    if i == self.selection_index then
      label = "> " .. label
    else
      label = "  " .. label
    end
    api.print(label, left, y, 7)
    y = y + character_height
  end
end

return text_menu
