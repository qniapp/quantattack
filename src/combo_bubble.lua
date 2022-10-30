---@diagnostic disable: lowercase-global

combo_bubble, all_combo_bubbles = {}, {}

function combo_bubble.update()
  foreach(all_combo_bubbles, function(each)
    local _ENV = each

    if _tick > 40 then
      del(all_combo_bubbles, each)
    end
    if _tick < 30 then
      _y = _y - 0.2
    end

    _tick = _tick + 1
  end)
end

function combo_bubble.render()
  foreach(all_combo_bubbles, function(each)
    local _ENV = each
    local rbox_x, rbox_y = _x - 1, _y

    draw_rounded_box(rbox_x, rbox_y + 1, rbox_x + 8, rbox_y + 9, 5, 5)
    draw_rounded_box(rbox_x, rbox_y, rbox_x + 8, rbox_y + 8, 7, 8)

    cursor(rbox_x + 3, rbox_y + 2)
    color(10)
    print(_combo_count)
  end)
end

function combo_bubble.create(combo_count, x, y)
  local _ENV = setmetatable({}, { __index = _ENV })

  _combo_count, _x, _y, _tick = combo_count, x, y - tile_size, 0

  add(all_combo_bubbles, _ENV)
end
