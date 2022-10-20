local particle, all_particles = new_class(), {}

function particle.update()
  for _, each in pairs(all_particles) do
    if each._tick > each._max_tick then
      del(all_particles, each)
    end
    if each._tick > each._max_tick - 5 then
      each._color = each._color_fade
    end

    each._x, each._y, each._dx, each._dy, each._tick = each._x + each._dx, each._y + each._dy, each._dx + each._ddx,
        each._dy + each._ddy, each._tick + 1
  end
end

function particle.render()
  for _, each in pairs(all_particles) do
    circfill(each._x, each._y, each._radius, each._color)
  end
end

function particle:_init(x, y, radius, color, color_fade, max_tick, horizontal_direction)
  self._x, self._y, self._radius, self._color, self._color_fade, self._tick, self._max_tick, self._dx, self._dy,
      self._ddx, self._ddy = x, y, radius, colors[color], colors[color_fade], 0, max_tick + rnd(10), rnd(1.2) * .8,
      rnd(1.2) * .8, -0.03, -0.03

  -- move to the left
  if horizontal_direction == 'left' or flr(rnd(2)) == 0 then
    self._dx, self._ddx = self._dx * -1, self._ddx * -1
  end

  -- move upward
  if flr(rnd(2)) == 0 then
    self._dy, self._ddy = self._dy * -1, self._ddy * -1
  end

  add(all_particles, self)
end

local function particle_set(x, y, data)
  for _, each in pairs(split(data, "|")) do
    ---@diagnostic disable-next-line: deprecated
    particle(x, y, unpack(split(each)))
  end
end

function particle_set_puff(x, y)
  particle_set(x, y,
    "3,white,dark_gray,20|3,white,dark_gray,20|2,white,dark_gray,20|2,dark_purple,dark_gray,20|2,light_gray,dark_gray,20|1,white,dark_gray,20|1,white,dark_gray,20|1,light_gray,dark_gray,20|1,light_gray,dark_gray,20|0,dark_purple,dark_gray,20")
end

function particle_set_swap_left(x, y)
  particle_set(x, y,
    "1,yellow,yellow,5,left|1,yellow,yellow,5,left|0,yellow,yellow,5,left|0,yellow,yellow,5,left")
end

function particle_set_swap_right(x, y)
  particle_set(x, y,
    "1,yellow,yellow,5,right|1,yellow,yellow,5,right|0,yellow,yellow,5,right|0,yellow,yellow,5,right")
end

function particle_set_chain_cube(x, y)
  particle_set(x, y,
    "5,green,dark_green,20|5,green,dark_green,20|4,green,dark_green,20|4,dark_purple,dark_gray,20|4,light_gray,dark_green,20|2,green,dark_green,20|2,green,dark_green,20|2,light_gray,dark_gray,20|2,light_gray,dark_gray,20|0,dark_purple,dark_gray,20")
end

return particle
