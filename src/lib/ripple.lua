---@diagnostic disable: global-in-nil-env, lowercase-global

local ripple_class = new_class()

function ripple_class._init(_ENV)
  t1, t2, tick, slow = 0, 0, 0, false
end

function ripple_class.update(_ENV)
  tick, t1, t2 =
  tick + 1,
      t1 - 1 / (slow and 3000 or 1500),
      t2 - 1 / (slow and 300 or 150)
end

function ripple_class.render(_ENV)
  for i = -5, 5 do
    for j = -5, 5 do
      local ang, d = atan2(i, j), sqrt(i * i + j * j)
      local r = 2 + 2 * sin(d / 4 + t2)
      circfill(
        64 + 12 * d * cos(ang + t1),
        64 + 12 * d * sin(ang + t1) - 3 * r,
        r,
        (slow and r > 3 and tick % 2 == 0) and 13 or 1
      )
    end
  end
end

-- singleton
ripple = ripple_class()
