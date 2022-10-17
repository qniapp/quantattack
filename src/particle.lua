require("engine/render/color")

local all_particles = {}

function update_particles()
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

function render_particles()
  for _, each in pairs(all_particles) do
    circfill(each._x, each._y, each._radius, each._color)
  end
end

function create_particle(x, y, radius, color, color_fade, max_tick, horizontal_direction)
  local particle = {
    _x = x,
    _y = y,
    _radius = radius,
    _color = colors[color] or colors.white,
    _color_fade = colors[color_fade] or colors.dark_gray,
    _tick = 0,
    _max_tick = (max_tick or 0) + rnd(10),

    _dx = rnd(1.2) * .8,
    _dy = rnd(1.2) * .8,
    _ddx = -0.03,
    _ddy = -0.03
  }

  -- 左方向のみに動かす場合
  if horizontal_direction == 'left' or flr(rnd(2)) == 0 then
    particle._dx = particle._dx * -1
    particle._ddx = particle._ddx * -1
  end

  -- 上方向のみに動く場合
  if flr(rnd(2)) == 0 then
    particle._dy = particle._dy * -1
    particle._ddy = particle._ddy * -1
  end

  add(all_particles, particle)
end

-- x, y, に data で指定した particle のセットを作る
--
-- data のフォーマット:
-- "radius,color|radius,color|..."
function create_particle_set(x, y, data)
  for _, particle_data in pairs(split(data, "|")) do
    ---@diagnostic disable-next-line: deprecated
    create_particle(x, y, unpack(split(particle_data)))
  end
end
