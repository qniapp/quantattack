require("engine/core/class")
require("engine/render/color")

local particle = new_class()
local all_particles = {}

particle.update = function()
  foreach(all_particles, function(each)
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
  end)
end

particle.render = function()
  foreach(all_particles, function(each)
    circfill(each._x, each._y, each._radius, each._color)
  end)
end

-- TODO: particle に名前を変更
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

  -- 左: -1, 右: 1
  if horizontal_direction == 'left' or flr(rnd(2)) == 0 then
    self._dx = self._dx * -1
    self._ddx = self._ddx * -1
  end

  -- 上方向に動く場合
  if flr(rnd(2)) == 0 then
    self._dy = self._dy * -1
    self._ddy = self._ddy * -1
  end

  add(all_particles, self)
end

return particle
