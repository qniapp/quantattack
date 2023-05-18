---@diagnostic disable: lowercase-global

--- 背景の波紋を描画するクラス
local ripple_class = new_class()

function ripple_class._init(_ENV)
  t1, t2, tick = 0, 0, 0
end

--- 波紋の状態を更新
function ripple_class.update(_ENV)
  tick, t1, t2 =
      tick + 1,
      t1 - 1 / ((slow or freeze) and 3000 or 1500),
      t2 - 1 / ((slow or freeze) and 300 or 150)
end

--- 波紋を描画
function ripple_class.render(_ENV)
  for i = -5, 5 do
    for j = -5, 5 do
      local ang, d = atan2(i, j), sqrt(i * i + j * j)
      local r = 2 + 2 * sin(d / 4 + t2)
      circfill(
        64 + 12 * d * cos(ang + t1),
        64 + 12 * d * sin(ang + t1) - 3 * r,
        r,
        ((slow or freeze) and r > 3 and tick % 2 == 0) and (slow and 13 or 12) or 1
      )
    end
  end
end

-- singleton
ripple = ripple_class()
