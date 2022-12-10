---@diagnostic disable: discard-returns

local flow = require("lib/flow")

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

  self.cart_to_load = nil
end

-- handle navigation input
function text_menu:update()
  if self.cart_to_load then
    if stat(16) == -1 then
      load(self.cart_to_load)
    end
  else
    if btnp(0) then
      self:select_previous()
    elseif btnp(1) then
      self:select_next()
    elseif btnp(4) then -- z
      sfx(15)
      self:confirm_selection()
    elseif btnp(5) then -- x
      -- FIXME: ベタ書きをやめる
      flow:query_gamestate_type(':title_demo')
    end
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
  -- flow:query_gamestate_type(self.items[self.selection_index].target_state)

  self.cart_to_load = self.items[self.selection_index].target_state
  -- load(self.items[self.selection_index].target_state)
end

function text_menu:draw(left, top)
  local sx = left

  for i, each in pairs(self.items) do
    if i == self.selection_index then
      print_centered(each.label, 62, top - 16, 10)
      print_centered(each.description, 62, top - 8, 7)

      draw_rounded_box(sx - 2, top - 2, sx + 17, top + 17, 12)

      print_centered(each.high_score and 'hi score: ' .. each.high_score or '', 62, top + 23, 7)
    else
      pal(7, 13)
    end

    sspr(each.sx, each.sy, 16, 16, sx, top)

    pal()

    sx = sx + 20
  end
end

function print_centered(text, center_x, center_y, col)
  print(text, center_x - #text * 2 + 1, center_y - 2, col)
end

return text_menu
