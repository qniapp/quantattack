---@diagnostic disable: discard-returns, lowercase-global

local high_score_class = require("lib/high_score")

--- @class menu_item
--- @field target_cart string
--- @field sx integer
--- @field sy integer
--- @field width integer
--- @field height integer
--- @field load_param string
--- @field label string
--- @field description string
--- @field high_score integer
local menu_item = new_class()

--- @param _target_cart string
--- @param _sx integer
--- @param _sy integer
--- @param _width integer
--- @param _height integer
--- @param _load_param string
--- @param _label string
--- @param _description string
--- @param _high_score_slot integer
function menu_item:_init(_target_cart, _target_state, _sx, _sy, _width, _height, _load_param, _label, _description,
                         _high_score_slot)
  local _ENV = self

  target_cart, target_state, sx, sy, width, height, load_param, label, description, high_score =
  _target_cart, _target_state ~= "" and _target_state or nil, _sx, _sy, _width, _height, _load_param, _label, _description,
      _high_score_slot and high_score_class(_high_score_slot):get() * 10
end

local menu = new_class()

function menu:_init(items_string, previous_state)
  self._items = {}
  for index, each in pairs(split(items_string, "|")) do
    self._items[index] = menu_item(unpack_split(each))
  end
  self._active_item_index = 1
  self._previous_state = previous_state
end

-- TODO: self を省略 (_ENV)
function menu:update()
  if self.cart_to_load then
    if stat(16) == -1 then
      jump(self.cart_to_load, nil, self.load_param)
    end
  else
    if btnp(0) then -- left
      sfx(8)

      self._active_item_index = max(self._active_item_index - 1, 1)
    elseif btnp(1) then -- right
      sfx(8)

      self._active_item_index = min(self._active_item_index + 1, #self._items)
    elseif btnp(5) then -- x
      sfx(15)

      local selected_menu_item = self._items[self._active_item_index]
      if selected_menu_item.target_state then
        self.stale = true
        title_state = selected_menu_item.target_state
      else
        self.cart_to_load = selected_menu_item.target_cart
        self.load_param = selected_menu_item.load_param
      end
    elseif btnp(4) then -- c
      sfx(8)

      title_state = self._previous_state
    end
  end
end

function menu:draw(left, top)
  local sx = left

  for i, each in pairs(self._items) do
    if i == self._active_item_index then
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
