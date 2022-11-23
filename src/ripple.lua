ripple_speed = nil

local t1, t2, tick

function init_ripple()
  t1, t2, tick, ripple_speed = 0, 0, 0, "normal"
end

function update_ripple()
  tick = tick + 1
  t1 = t1 - 1 / (ripple_speed == "normal" and 1500 or 3000)
  t2 = t2 - 1 / (ripple_speed == "normal" and 150 or 300)
end

function render_ripple()
  for i = -5, 5 do
    for j = -5, 5 do
      local ang = atan2(i, j)
      local d = sqrt(i * i + j * j)
      local r = 2 + 2 * sin(d / 4 + t2)
      local h = 3 * r
      local clr = (ripple_speed == "slow" and r > 3 and tick % 2 == 0) and 13 or 1
      circfill(64 + 12 * d * cos(ang + t1), 64 + 12 * d * sin(ang + t1) - h, r, clr)
    end
  end
end
