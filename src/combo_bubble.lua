local combo_bubble, all_bubbles = new_class(), {}

function combo_bubble.update()
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

function combo_bubble.render()
  for _, each in pairs(all_bubbles) do
    local rbox_x, rbox_y = each.x - 1, each.y

    draw_rounded_box(rbox_x, rbox_y + 1, rbox_x + 8, rbox_y + 9, 5, 5)
    draw_rounded_box(rbox_x, rbox_y, rbox_x + 8, rbox_y + 8, 7, 8)

    cursor(rbox_x + 3, rbox_y + 2)
    color(10)
    print(each.combo_count)
  end
end

function combo_bubble:_init(combo_count, x, y)
  self.combo_count, self.x, self.y, self.tick = combo_count, x, y - tile_size, 0

  add(all_bubbles, self)
end

return combo_bubble
