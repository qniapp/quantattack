local plasma_time = 0

function _plasma_draw()
  plasma_time = plasma_time + 0.05

  local t = plasma_time / 12
  local sint, cost = sin(t / 15) / 120, cos(t / 17) / 180

  for x = 0, 31 do
    local xsint = x * sint

    for y = 0, 31 do
      local v = sin((xsint + y * cost) * 8 + t)
      v = flr((v * cos(x / 53 + y / 57) + 1) * 2.5)

      local plasma_colors = { 0, 5, 1, 5, 1 }
      local _x, _y = x << 2, y << 2
      rect(_x, _y, _x + 1, _y + 1, plasma_colors[v + 1])
    end
  end
end
