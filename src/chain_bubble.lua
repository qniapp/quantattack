require("engine/core/class")

local chain_bubble = new_class()

local all_bubbles = {}

local k = .0125
local q = {}
local data = split("122413345657687815263748", 1)

for x = -4, 4, 8 do
  for y = -4, 4, 8 do
    for z = -4, 4, 8 do
      add(q, { x = x, y = y, z = z })
    end
  end
end

function chain_bubble.update()
  for _, each in pairs(all_bubbles) do
    if abs(each.target_x - each.x) < 5 then
      del(all_bubbles, each)
    end

    if each.tick < 50 then
      each.dx, each.dy = -0.5, -0.2
      if each.left then
        each.dx = each.dx * -1
      end
    else
      each.dx, each.dy = (each.target_x - each.x) / 16, (each.target_y - each.y) / 16
    end

    each.x = each.x + each.dx
    each.y = each.y + each.dy

    each.tick = each.tick + 1
  end
end

function chain_bubble.render()
  local cube_color = flr(rnd(16)) + 1

  for _, each in pairs(all_bubbles) do
    for i = 1, 24 do
      if i % 2 > 0 then
        line()
      end
      local f = q[data[i]]
      local x, y = f.x, f.y
      local z = f.z + x * k
      f.x, f.y, f.z = f.x - f.z * k, f.y - z * k, z + y * k
      line(f.x + each.x, f.y + each.y, cube_color)
    end
  end
end

function chain_bubble:_init(x, y, target_x, target_y, left)
  self.x = x
  self.y = y
  self.target_x = target_x
  self.target_y = target_y
  self.tick = 0
  self.left = left ~= nil

  add(all_bubbles, self)
end

return chain_bubble
