---@diagnostic disable: lowercase-global

local all_cubes, apex, data = {}, {}, split("122413345657687815263748", 1)

for x = -4, 4, 8 do
  for y = -4, 4, 8 do
    for z = -4, 4, 8 do
      add(apex, { x = x, y = y, z = z })
    end
  end
end

function update_chain_cube()
  foreach(all_cubes, function(each)
    local _ENV = each

    if abs(_target_x - _x) < 5 then
      del(all_cubes, each)
      create_particle_set(_target_x, _target_y,
        "5,green,dark_green,20|5,green,dark_green,20|4,green,dark_green,20|4,dark_purple,dark_gray,20|4,light_gray,dark_green,20|2,green,dark_green,20|2,green,dark_green,20|2,light_gray,dark_gray,20|2,light_gray,dark_gray,20|0,dark_purple,dark_gray,20")
    end

    if _tick < 50 then
      _dx, _dy = _left and 0.5 or -0.5, -0.2
    else
      _dx, _dy = (_target_x - _x) / 8, (_target_y - _y) / 8
    end

    _x, _y, _tick = _x + _dx, _y + _dy, _tick + 1
  end)
end

function render_chain_cube()
  local cube_color = flr(rnd(16)) + 1

  foreach(all_cubes, function(each)
    local _ENV = each

    for i = 1, 24 do
      if i % 2 > 0 then
        line()
      end
      local size = _chain_count / 2
      local f = apex[data[i]]
      local x, y = f.x, f.y
      local z = f.z + x * .0125
      f.x, f.y, f.z = f.x - f.z * .0125, f.y - z * .0125, z + y * .0125
      line(f.x * size + _x, f.y * size + _y, cube_color)
    end
  end)
end

function create_chain_cube(chain_count, x, y, target_x, target_y, left)
  local _ENV = setmetatable({}, { __index = _ENV })

  _chain_count, _x, _y, _target_x, _target_y, _tick, _left = chain_count, x, y, target_x, target_y, 0, left ~= nil

  add(all_cubes, _ENV)
end
