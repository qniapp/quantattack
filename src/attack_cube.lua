---@diagnostic disable: lowercase-global

local all_cubes, cube_data = {}, split("122413345657687815263748", 1)

function update_attack_cubes()
  foreach(all_cubes, function(each)
    local _ENV = each

    if abs(_target_x - _x) < 5 then
      del(all_cubes, each)
      create_particle_set(_target_x, _target_y,
        "5,green,dark_green,20|5,green,dark_green,20|4,green,dark_green,20|4,dark_purple,dark_gray,20|4,light_gray,dark_green,20|2,green,dark_green,20|2,green,dark_green,20|2,light_gray,dark_gray,20|2,light_gray,dark_gray,20|0,dark_purple,dark_gray,20")
      each._callback()
    end

    if _tick < 50 then
      _dx, _dy = _left and 0.5 or -0.5, -0.2
    else
      _dx, _dy = (_target_x - _x) / 8, (_target_y - _y) / 8
    end

    _x, _y, _tick = _x + _dx, _y + _dy, _tick + 1
  end)
end

function render_attack_cubes()
  foreach(all_cubes, function(each)
    local _ENV = each

    for i = 1, 24 do
      if i % 2 > 0 then
        line()
      end
      local f = _apex[cube_data[i]]
      local x, y, z = f.x, f.y, f.z + f.x * .0125
      f.x, f.y, f.z = x - f.z * .0125, y - z * .0125, z + y * .0125
      line(f.x + _x, f.y + _y, _color)
    end
  end)
end

function create_attack_cube(x, y, callback, target_x, target_y, left)
  local _ENV = setmetatable({}, { __index = _ENV })

  _x, _y, _callback, _target_x, _target_y, _tick, _left, _apex, _color = x, y, callback, target_x, target_y, 0, left ~= nil, {}, flr(rnd(16)) + 1

  for ax = -4, 4, 8 do
    for ay = -4, 4, 8 do
      for az = -4, 4, 8 do
        add(_apex, { x = ax, y = ay, z = az })
      end
    end
  end

  add(all_cubes, _ENV)
end
