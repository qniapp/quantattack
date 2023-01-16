---@diagnostic disable: discard-returns, lowercase-global, global-in-nil-env

local high_score_class = require("lib/high_score")

--- @class menu_item
--- @field target_cart string
--- @field sx integer
--- @field sy integer
--- @field width integer
--- @field height integer
--- @field cart_load_param string
--- @field label string
--- @field description string
--- @field high_score integer
local menu_item = new_class()

--- @param _target_cart string
--- @param _sx integer
--- @param _sy integer
--- @param _width integer
--- @param _height integer
--- @param _cart_load_param string
--- @param _label string
--- @param _description string
--- @param _high_score_slot integer
function menu_item._init(_ENV, _target_cart, _target_state, _sx, _sy, _width, _height, _cart_load_param, _label,
                         _description,
                         _high_score_slot)
  target_cart, target_state, sx, sy, width, height, cart_load_param, label, description, high_score =
  _target_cart, _target_state ~= "" and _target_state or nil, _sx, _sy, _width, _height, _cart_load_param, _label,
      _description,
      _high_score_slot and high_score_class(_high_score_slot):get()
end

local menu = new_class()

function menu._init(_ENV, items_string, previous_state)
  _items = {}
  for index, each in pairs(split(items_string, "|")) do
    _items[index] = menu_item(unpack_split(each))
  end
  _active_item_index = 1
  _previous_state = previous_state
end

function menu.update(_ENV)
  if cart_to_load then
    if cart_load_delay > 0 then
      cart_load_delay = cart_load_delay - 1
    else
      jump(cart_to_load, nil, cart_load_param)
    end
  else
    if btnp(0) then -- left
      sfx(8)

      _active_item_index = max(_active_item_index - 1, 1)
    elseif btnp(1) then -- right
      sfx(8)

      _active_item_index = min(_active_item_index + 1, #_items)
    elseif btnp(5) then -- x
      sfx(15)

      local selected_menu_item = _items[_active_item_index]
      if selected_menu_item.target_state then
        stale = true
        return selected_menu_item.target_state
      else
        cart_to_load = selected_menu_item.target_cart
        cart_load_param = selected_menu_item.cart_load_param
        cart_load_delay = 60
      end
    elseif btnp(4) then -- c
      sfx(8)

      return _previous_state
    end
  end
end

function menu.draw(_ENV, left, top)
  local sx = left

  for i, each in pairs(_items) do
    if i == _active_item_index then
      print_centered(each.label, 62, top - 16, 10)
      print_centered(each.description, 62, top - 8, 7)

      draw_rounded_box(sx - 2, top - 2, sx + each.width + 1, top + each.height + 1, stale and 6 or 12)
      print_centered(each.high_score and 'hi score: ' .. score_string(each.high_score), 62, top + 23, 7)

      if stale then
        pal(7, 6)
      end
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
