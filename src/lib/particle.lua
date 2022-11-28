---@diagnostic disable: lowercase-global

all_particles = {}

function update_particles()
  for _, each in pairs(all_particles) do
    local _ENV = each

    if _tick > _max_tick then
      del(all_particles, each)
    end
    if _tick > _max_tick * 0.5 then
      _color = _color_fade
      _radius = _end_radius
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

function create_particle(x, y, radius, end_radius, __color, __color_fade, dx, dy, ddx, ddy, max_tick)
  local _ENV = setmetatable({}, { __index = _ENV })

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

  add(all_particles, _ENV)
end

function create_particle_set(x, y, data)
  for _, each in pairs(split(data, "|")) do
    create_particle(x, y, unpack(split(each)))
  end
end
