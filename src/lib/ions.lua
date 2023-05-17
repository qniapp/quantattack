---
-- 攻撃または相殺の時に表示するイオン球エフェクト

ions = derived_class(effect_set)()

--- イオン球エフェクトを作る
--
-- 例: (64, 64) から (10, 10) へ青色 (デフォルト) のイオン球を飛ばす
-- ions:create({ 64, 64 }, { 10, 10 }, ions_callback)
--
function ions:create(from, target, callback, ion_color)
  self:_add(function(_ENV)
    _from_x, _from_y, _target, _callback, _color, _tick =
      from[1], from[2], target, callback, ion_color or 12, 0
    sfx(20)
  end)
end

--- イオン球の位置等を更新
function ions._update(_ENV, all)
  local _quadratic_bezier = function(from, mid, to)
    local t = _tick / 60
    return (1 - t) * (1 - t) * from + 2 * (1 - t) * t * mid + t * t * to
  end

  if _tick == 60 then
    _callback(_target)
    del(all, _ENV)
  end

  _tick = _tick + 1

  _x, _y =
    _quadratic_bezier(_from_x, _from_x > 64 and _from_x + 60 or _from_x - 60, _target[1]),
      _quadratic_bezier(_from_y, _from_y + 40, _target[2])

  -- しっぽを追加
  if ceil_rnd(10) > 7 then
    particles:create(_x, _y, "3,2," .. _color .. "," .. _color .. ",0,0,0,0,20")
  end
end

--- イオン球を描画
function ions._render(_ENV)
  fillp(23130.5)
  circfill(_x, _y, 6 + 2 * sin(t()), _color)
  fillp()
  circfill(_x, _y, 4 + 2 * sin(1.5 * t()), _color)
  circfill(_x, _y, 3 + sin(2.5 * t()), 7)
end
