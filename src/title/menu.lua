---@diagnostic disable: discard-returns

local menu = new_class()

function menu:_init(items, previous_state)
  self.items = items
  self.selection_index = 1
  self.previous_state = previous_state
end

function menu:update()
  if self.cart_to_load then
    if stat(16) == -1 then
      jump(self.cart_to_load, nil, self.load_param)
    end
  else
    if btnp(0) then
      sfx(8)
      self:select_previous()
    elseif btnp(1) then
      sfx(8)
      self:select_next()
    elseif btnp(5) then -- x
      sfx(15)
      self:confirm_selection()
    elseif btnp(4) then -- c
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
  local selected_menu_item = self.items[self.selection_index]

  if sub(selected_menu_item.target_state, 1, 1) == ":" then
    self.stale = true
    title_state = selected_menu_item.target_state
  else
    self.cart_to_load = selected_menu_item.target_state
    self.load_param = selected_menu_item.load_param
  end
end

function menu:draw(left, top)
  local sx = left

  for i, each in pairs(self.items) do
    if i == self.selection_index then
      print_centered(each.label, 62, top - 16, 10)
      print_centered(each.description, 62, top - 8, 7)

      draw_rounded_box(sx - 2, top - 2, sx + each.width + 1, top + each.height + 1, self.stale and 6 or 12)
      if self.stale then
        pal(7, 6)
      end

      print_centered(each.high_score and 'hi score: ' .. each.high_score or nil, 62, top + 23, 7)
    else
      pal(7, 13)
    end

    sspr(each.sx, each.sy, each.width, 16, sx, top)

    pal()

    sx = sx + each.width + 4
  end
end

function print_centered(text, center_x, center_y, col)
  if text then
    print(text, center_x - #text * 2 + 1, center_y - 2, col)
  end
end

return menu
