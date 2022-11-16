---@diagnostic disable: lowercase-global

-- TODO: 色を番号にし、以下の require をなくす
require("engine/render/color")

all_particles = {}

function update_particles()
  for _, each in pairs(all_particles) do
    local _ENV = each

    if _tick > _max_tick then
      del(all_particles, each)
    end
    if _tick > _max_tick - 5 then
      _color = _color_fade
    end

    _x, _y, _dx, _dy, _tick = _x + _dx, _y + _dy, _dx + _ddx, _dy + _ddy, _tick + 1
  end
end

function render_particles()
  for _, each in pairs(all_particles) do
    local _ENV = each

    circfill(_x, _y, _radius, _color)
  end
end

function create_particle(x, y, radius, color, color_fade, max_tick, horizontal_direction)
  local _ENV = setmetatable({}, { __index = _ENV })

  _x, _y, _radius, _color, _color_fade, _tick, _max_tick, _dx, _dy, _ddx, _ddy = x, y, radius, colors[color],
      colors[color_fade], 0, max_tick + rnd(10), rnd(1.2) * .8, rnd(1.2) * .8, -0.03, -0.03

  -- move to the left
  if horizontal_direction == 'left' or flr(rnd(2)) == 0 then
    _dx, _ddx = _dx * -1, _ddx * -1
  end

  -- move upwards
  if flr(rnd(2)) == 0 then
    _dy, _ddy = _dy * -1, _ddy * -1
  end

  add(all_particles, _ENV)
end

function create_particle_set(x, y, data)
  for _, each in pairs(split(data, "|")) do
    create_particle(x, y, unpack(split(each)))
  end
end
