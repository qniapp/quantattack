---@diagnostic disable: lowercase-global, global-in-nil-env

local effect_set = require("lib/effect_set")
local particle_class = derived_class(effect_set)

-- singleton
particle = particle_class()

function particle:create_chunk(x, y, data)
  for _, each in pairs(split(data, "|")) do
    self:_create(x, y, unpack(split(each)))
  end
end

function particle:_create(x, y, radius, end_radius, __color, __color_fade, dx, dy, ddx, ddy, max_tick)
  self:_add(function(_ENV)
    _x, _y, _radius, _end_radius, _color, _color_fade, _tick, _max_tick, _ddx, _ddy =
    x, y, radius, end_radius, __color, __color_fade, 0, max_tick + rnd(10), ddx, ddy

    _dx = dx == "random" and rnd(1.2) * .8 or dx
    _dy = dy == "random" and rnd(1.2) * .8 or dy

    if dx == "random" or dy == "random" then
      -- move to the left
      if ceil_rnd(2) == 1 then
        _dx, _ddx = _dx * -1, _ddx * -1
      end

      -- move upwards
      if ceil_rnd(2) == 1 then
        _dy, _ddy = _dy * -1, _ddy * -1
      end
    end
  end)
end

function particle._update(_ENV, self)
  if _tick > _max_tick then
    del(self.all, _ENV)
  end
  if _tick > _max_tick * 0.5 then
    _color = _color_fade
    _radius = _end_radius
  end

  _x, _y, _dx, _dy, _tick = _x + _dx, _y + _dy, _dx + _ddx, _dy + _ddy, _tick + 1
end

function particle._render(_ENV)
  circfill(_x, _y, _radius, _color)
end

function particle:post_render_all()
  if self.slow and #self.all > 0 then
    flip()
  end
end
