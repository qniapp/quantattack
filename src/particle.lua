require("engine/render/color")

local particle = new_class()

local all_particles = {}

function particle.update()
  for _, each in pairs(all_particles) do
    if each._tick > each._max_tick then
      del(all_particles, each)
    end
    if each._tick > each._max_tick - 5 then
      each._color = each._color_fade
    end

    each._x = each._x + each._dx
    each._y = each._y + each._dy
    each._dx = each._dx + each._ddx
    each._dy = each._dy + each._ddy
    each._tick = each._tick + 1
  end
end

function particle.render()
  for _, each in pairs(all_particles) do
    circfill(each._x, each._y, each._radius, each._color)
  end
end

function particle:_init(x, y, radius, color, color_fade, max_tick, horizontal_direction)
  self._x = x
  self._y = y
  self._radius = radius
  self._color = colors[color] or colors.white
  self._color_fade = colors[color_fade] or colors.dark_gray
  self._tick = 0
  self._max_tick = (max_tick or 0) + rnd(10)
  self._dx = rnd(1.2) * .8
  self._dy = rnd(1.2) * .8
  self._ddx = -0.03
  self._ddy = -0.03

  -- 左方向のみに動かす場合
  if horizontal_direction == 'left' or flr(rnd(2)) == 0 then
    self._dx = self._dx * -1
    self._ddx = self._ddx * -1
  end

  -- 上方向のみに動く場合
  if flr(rnd(2)) == 0 then
    self._dy = self._dy * -1
    self._ddy = self._ddy * -1
  end

  add(all_particles, self)
end

-- x, y, に data で指定した particle のセットを作る
--
-- data のフォーマット:
-- "radius,color|radius,color|..."
function create_particle_set(x, y, data)
  for _, particle_data in pairs(split(data, "|")) do
    ---@diagnostic disable-next-line: deprecated
    particle(x, y, unpack(split(particle_data)))
  end
end

return particle
