require("engine/core/class")
require("engine/render/color")

local ui = require("engine/ui/ui")

local all_popups = {}
local chain_popup = new_class()

local dy = -0.2
local max_tick = 40

function chain_popup.update()
  for _, each in pairs(all_popups) do
    if each.tick > max_tick then
      del(all_popups, each)
    end
    if each.tick < 30 then
      each.y = each.y + dy
    end

    each.tick = each.tick + 1
  end
end

function chain_popup.render()
  for _, each in pairs(all_popups) do
    local rbox_x = each.x - 2
    local rbox_y = each.y
    local dx = each.count < 10 and 0 or -2

    ui.draw_rounded_box(rbox_x + dx, rbox_y + 1, rbox_x + 10 - dx, rbox_y + 9, 5, 5)
    ui.draw_rounded_box(rbox_x + dx, rbox_y, rbox_x + 10 - dx, rbox_y + 8, 7, 8)

    spr(69, rbox_x + 2 + dx, rbox_y - 1) -- x の部分

    cursor(rbox_x + 6 + dx, rbox_y + 2)
    color(7)
    print(each.count)
  end
end

-- - chain: チェイン数
-- - x: スクリーン上の x 座標
-- - y: スクリーン上の y 座標
function chain_popup:_init(count, x, y)
  self.count = count
  self.x = x
  self.y = y - tile_size
  self.tick = 0

  add(all_popups, self)
end

return chain_popup
