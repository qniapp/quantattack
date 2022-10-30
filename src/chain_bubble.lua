---@diagnostic disable: lowercase-global

chain_bubble, all_chain_bubbles = {}, {}

function chain_bubble.update()
  foreach(all_chain_bubbles, function(each)
    local _ENV = each

    if _tick > 40 then
      del(all_chain_bubbles, each)
    end
    if _tick < 30 then
      _y = _y - 0.2
    end

    _tick = _tick + 1
  end)
end

function chain_bubble.render()
  foreach(all_chain_bubbles, function(each)
    local _ENV = each
    local rbox_x, rbox_y, rbox_dx = _x - 2, _y, _chain_count < 10 and 0 or -2

    draw_rounded_box(rbox_x + rbox_dx, rbox_y + 1, rbox_x + 10 - rbox_dx, rbox_y + 9, 5, 5)
    draw_rounded_box(rbox_x + rbox_dx, rbox_y, rbox_x + 10 - rbox_dx, rbox_y + 8, 7, 11)

    spr(69, rbox_x + 2 + rbox_dx, rbox_y - 1) -- the "x" part in "x5"

    cursor(rbox_x + 6 + rbox_dx, rbox_y + 2)
    color(10)
    print(_chain_count)
  end)
end

function chain_bubble.create(chain_count, x, y)
  local _ENV = setmetatable({}, { __index = _ENV })

  _chain_count, _x, _y, _tick = chain_count, x, y - tile_size, 0

  add(all_chain_bubbles, _ENV)
end
