drop_particle = {
  _all = {},

  create = function(self, x, y, size, color)
    local p = {}
    local left = flr(rnd(2)) == 0

    p.x = x
    p.y = y
    p.color = color
    p.width = size
    p.tick = 0
    p.max_tick = 20 + rnd(10)
    p.dx = rnd(.8) * .4
    p.dy = rnd(.05)
    p.ddy = .02

    if left then
      p.dx *= -1
    end

    add(drop_particle._all, p)

    return p
  end,

  update = function(self)
    foreach(drop_particle._all, function(each)
      if (each.tick > each.max_tick) then
        del(drop_particle._all, each)
      end
      if (each.tick > each.max_tick - 5) then
        each.color = colors.dark_grey
      end

      each.x += each.dx
      each.y += each.dy
      each.dy += each.ddy
      each.tick += 1
    end)
  end,

  draw = function(self)
    foreach(drop_particle._all, function(each)
      circfill(each.x, each.y, each.width, each.color)
    end)
  end
}