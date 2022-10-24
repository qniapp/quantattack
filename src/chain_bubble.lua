local chain_bubble, all_bubbles = new_class(), {}

function chain_bubble.update()
  for _, each in pairs(all_bubbles) do
    if each.tick > 40 then
      del(all_bubbles, each)
    end
    if each.tick < 30 then
      each.y = each.y - 0.2
    end

    each.tick = each.tick + 1
  end
end

function chain_bubble.render()
  for _, each in pairs(all_bubbles) do
    local rbox_x, rbox_y, rbox_dx = each.x - 2, each.y, each.chain_count < 10 and 0 or -2

    draw_rounded_box(rbox_x + rbox_dx, rbox_y + 1, rbox_x + 10 - rbox_dx, rbox_y + 9, 5, 5)
    draw_rounded_box(rbox_x + rbox_dx, rbox_y, rbox_x + 10 - rbox_dx, rbox_y + 8, 7, 11)

    spr(69, rbox_x + 2 + rbox_dx, rbox_y - 1) -- the "x" part in "x5"

    cursor(rbox_x + 6 + rbox_dx, rbox_y + 2)
    color(10)
    print(each.chain_count)
  end
end

function chain_bubble:_init(chain_count, x, y)
  self.chain_count, self.x, self.y, self.tick = chain_count, x, y - tile_size, 0

  add(all_bubbles, self)
end

return chain_bubble
