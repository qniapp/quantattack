require("engine/core/class")

local chain_cube = new_class()

local all_cubes = {}

local q = {}
local data = split("122413345657687815263748", 1)

for x = -4, 4, 8 do
  for y = -4, 4, 8 do
    for z = -4, 4, 8 do
      add(q, { x = x, y = y, z = z })
    end
  end
end

function chain_cube.update()
  for _, each in pairs(all_cubes) do
    if abs(each.target_x - each.x) < 5 then
      del(all_cubes, each)
      particle_set_chain_cube(each.target_x, each.target_y)
    end

    if each.tick < 50 then
      each.dx, each.dy = each.left and 0.5 or -0.5, -0.2
    else
      each.dx, each.dy = (each.target_x - each.x) / 8, (each.target_y - each.y) / 8
    end

    each.x, each.y = each.x + each.dx, each.y + each.dy

    each.tick = each.tick + 1
  end
end

function chain_cube.render()
  local cube_color = flr(rnd(16)) + 1

  for _, each in pairs(all_cubes) do
    for i = 1, 24 do
      if i % 2 > 0 then
        line()
      end
      local size = each.chain_count / 2
      local f = q[data[i]]
      local x, y = f.x, f.y
      local z = f.z + x * .0125
      f.x, f.y, f.z = f.x - f.z * .0125, f.y - z * .0125, z + y * .0125
      line(f.x * size + each.x, f.y * size + each.y, cube_color)
    end
  end
end

function chain_cube:_init(chain_count, x, y, target_x, target_y, left)
  self.chain_count = chain_count
  self.x = x
  self.y = y
  self.target_x = target_x
  self.target_y = target_y
  self.tick = 0
  self.left = left ~= nil

  add(all_cubes, self)
end

return chain_cube
