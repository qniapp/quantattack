---@diagnostic disable: discard-returns

local menu = new_class()

function menu:_init(items, previous_state)
  self.items = items
  self.selection_index = 1
  self.cart_to_load = nil
  self.previous_state = previous_state
end

function menu:update()
  if self.cart_to_load then
    if stat(16) == -1 then
      load(self.cart_to_load)
    end
  else
    if btnp(0) then
      sfx(8)
      self:select_previous()
    elseif btnp(1) then
      sfx(8)
      self:select_next()
    elseif btnp(4) then -- z
      sfx(15)
      self:confirm_selection()
    elseif btnp(5) then -- x
      sfx(8)
      title_state = self.previous_state
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
  local target = self.items[self.selection_index].target_state
  if type(target) == "string" then
    self.cart_to_load = target
  else
    self.stale = true
    target()
  end
end

function menu:draw(left, top)
  local sx = left

  for i, each in pairs(self.items) do
    if i == self.selection_index then
      print_centered(each.label or "", 62, top - 16, 10)
      print_centered(each.description or "", 62, top - 8, 7)

      draw_rounded_box(sx - 2, top - 2, sx + each.width + 1, top + each.height + 1, self.stale and 6 or 12)
      if self.stale then
        pal(7, 6)
      end

      print_centered(each.high_score and 'hi score: ' .. each.high_score or '', 62, top + 23, 7)
    else
      pal(7, 13)
    end

    sspr(each.sx, each.sy, each.width, 16, sx, top)

    pal()

    sx = sx + each.width + 4
  end
end

function print_centered(text, center_x, center_y, col)
  print(text, center_x - #text * 2 + 1, center_y - 2, col)
end

return menu
