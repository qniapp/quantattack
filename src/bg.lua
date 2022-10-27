local bgtime = 0

-- ???: https://pico-8.fandom.com/wiki/Memory#Screen_data
function _plasma_draw()
  bgtime = bgtime + 0.3

  local t = bgtime / 12
  local sint, cost = sin(t / 15) / 120, cos(t / 17) / 180

  for x = 0, 31 do
    local xsint = x * sint

    for y = 0, 31 do
      if x == 0 or x == 31 or (12 < x and x < 20) or y < 8 then
        local v = sin((xsint + y * cost) * 8 + t)
        v = v * cos(x / 53 + y / 57)
        v = flr((v + 1) * 2.5)

        local plasma_colors = { 0, 13, 1, 13, 1 }
        local _x, _y = x << 2, y << 2
        rectfill(_x, _y, _x + 1, _y + 1, plasma_colors[v + 1])
      end
    end
  end
end
