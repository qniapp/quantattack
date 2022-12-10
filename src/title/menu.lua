---@diagnostic disable: discard-returns

local flow = require("lib/flow")
local menu = new_class()

function menu:_init(items)
  self.items = items
  self.selection_index = 1
  self.cart_to_load = nil
end

function menu:update()
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
      -- TODO: flow を消す
      flow:query_gamestate_type(':title_demo')
    end
  end
end

function menu:select_previous()
  self.selection_index = max(self.selection_index - 1, 1)
end

function menu:select_next()
  self.selection_index = min(self.selection_index + 1, #self.items)
end

function menu:confirm_selection()
  self.cart_to_load = self.items[self.selection_index].target_state
end

function menu:draw(left, top)
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

return menu
