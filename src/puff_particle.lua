require("engine/core/class")
require("engine/render/color")

local puff_particle = new_class()
local all_particles = {}

puff_particle.update = function()
  foreach(all_particles, function(each)
    if (each.tick > each.max_tick) then
      del(all_particles, each)
    end
    if (each.tick > each.max_tick - 5) then
      each.color = colors.dark_grey
    end

    each.x = each.x + each.dx
    each.y = each.y + each.dy
    each.dx = each.dx + each.ddx
    each.dy = each.dy + each.ddy
    each.tick = each.tick + 1
  end)
end

puff_particle.render = function()
  foreach(all_particles, function(each)
    circfill(each.x, each.y, each.radius, each.color)
  end)
end

function puff_particle:_init(x, y, radius, color)
  self.x = x
  self.y = y
  self.color = color or colors.white
  self.radius = radius
  self.tick = 0
  self.max_tick = 20 + rnd(10)
  self.dx = rnd(1.2) * .8
  self.dy = rnd(1.2) * .8
  self.ddx = -0.03
  self.ddy = -0.03

  local up = flr(rnd(2)) == 0
  local left = flr(rnd(2)) == 0

  if (up) then
    self.dy = self.dy * -1
    self.ddy = self.ddy * -1
  end
  if (left) then
    self.dx = self.dx * -1
    self.ddx = self.ddx * -1
  end

  add(all_particles, self)
end

return puff_particle
