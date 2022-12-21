local time, colors = 0, { 0, 5, 1, 5, 1 }

function render_plasma()
  local t = time / 12
  local sint, cost = sin(t / 15) / 120, cos(t / 17) / 180

  for x = 0, 31 do
    for y = 0, 31 do
      local x2, y2 = x << 2, y << 2

      if pget(x2, y2) == 0 then
        local v = sin(((x * sint) + y * cost) * 8 + t)
        v = flr((v * cos(x / 53 + y / 57) + 1) * 2.5)
        pset(x2, y2, colors[v + 1])
      end
    end
  end

  time = time + 0.05
end
