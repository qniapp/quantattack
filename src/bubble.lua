---@diagnostic disable: lowercase-global

all_bubbles = {}

function update_bubbles()
  foreach(all_bubbles, function(each)
    local _ENV = each

    if _tick > 40 then
      del(all_bubbles, each)
    end
    if _tick < 30 then
      _y = _y - 0.2
    end

    _tick = _tick + 1
  end)
end

function render_bubbles()
  foreach(all_bubbles, function(each)
    local _ENV = each

    if _type == "combo" then
      draw_rounded_box(_x - 1, _y + 1, _x + 7, _y + 9, 5, 5)
      draw_rounded_box(_x - 1, _y, _x + 7, _y + 8, 7, 8)

      cursor(_x + 2, _y + 2)
    else
      local rbox_dx = _count < 10 and 0 or -2

      draw_rounded_box(_x + rbox_dx - 2, _y + 1, _x - rbox_dx + 8, _y + 9, 5, 5)
      draw_rounded_box(_x + rbox_dx - 2, _y, _x - rbox_dx + 8, _y + 8, 7, 11)

      spr(69, _x + rbox_dx, _y - 1) -- the "x" part in "x5"

      cursor(_x + rbox_dx + 4, _y + 2)
    end

    color(10)
    print(_count)
  end)
end

function create_bubble(bubble_type, count, x, y)
  local _ENV = setmetatable({}, { __index = _ENV })

  _type, _count, _x, _y, _tick = bubble_type, count, x, y - tile_size, 0

  add(all_bubbles, _ENV)
end
