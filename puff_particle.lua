puff_particle = {
  _all = {},

  create = function(self, x, y, size, color)
    local p = {}

    p.x = x
    p.y = y
    p.color = color
    p.width = size
    p.tick = 0
    p.max_tick = 20 + rnd(10)
    p.dx = rnd(1.2) * .8
    p.dy = rnd(1.2) * .8

    p.ddx = -0.03
    p.ddy = -0.03

    local up = flr(rnd(2)) == 0
    local left = flr(rnd(2)) == 0

    if (up) then
      p.dy *= -1
      p.ddy *= -1
    end
    if (left) then
      p.dx *= -1
      p.ddx *= -1
    end

    add(puff_particle._all, p)

    return p
  end,

  update = function(self)
    foreach(puff_particle._all, function(each)
      if (each.tick > each.max_tick) then
        del(puff_particle._all, each)
      end
      if (each.tick > each.max_tick - 5) then
        each.color = colors.dark_grey
      end

      each.x += each.dx
      each.y += each.dy
      each.dx += each.ddx
      each.dy += each.ddy
      each.tick += 1
    end)
  end,

  draw = function(self)
    foreach(puff_particle._all, function(each)
      circfill(each.x, each.y, each.width, each.color)
    end)
  end  
}
