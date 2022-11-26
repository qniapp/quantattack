---@diagnostic disable: lowercase-global

local all_cubes, cube_data = {}, split("122413345657687815263748", 1)

function update_cubes()
  foreach(all_cubes, function(each)
    local _ENV = each

    if _tick > _max_tick then
      del(all_cubes, each)
    end

    _x, _y, _tick = _x + _dx, _y + _dy, _tick + 1
  end)
end

function render_cubes()
  foreach(all_cubes, function(each)
    local _ENV, size = each, (1 + each._tick / 20)

    for i = 1, 24 do
      if i % 2 > 0 then
        line()
      end
      local f = _apex[cube_data[i]]
      local x, y, z = f.x, f.y, f.z + f.x * .0125
      f.x, f.y, f.z = x - f.z * .0125, y - z * .0125, z + y * .0125
      line(f.x * size + _x, f.y * size + _y, 7)
    end
  end)
end

function create_cube(x, y)
  local _ENV = setmetatable({}, { __index = _ENV })

  _x, _y, _dx, _dy, _tick, _max_tick, _apex = x, y, rnd(4) - 2, rnd(4) - 2, 0, 60 + rnd(20), {}

  for ax = -4, 4, 8 do
    for ay = -4, 4, 8 do
      for az = -4, 4, 8 do
        add(_apex, { x = ax, y = ay, z = az })
      end
    end
  end

  add(all_cubes, _ENV)
end
