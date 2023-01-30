---
-- 攻撃または相殺の時に表示するイオン球エフェクト。
-- チュートリアルに登場するキャラクター「イオン君」の表示にも使われる。

require("lib/effect_set")

ions = derived_class(effect_set)()

--- イオン球エフェクトを作る
-- @usage ions:create(64, 64, ions_callback, 12, 10, 10) -- 64, 64 から 10, 10 に向かって青色のイオン球を飛ばす
-- @param x x 座標
-- @param y y 座標
-- @param callback コールバック
-- @param ion_color イオン球の色
-- @param target_x 目標 x 座標
-- @param target_y 目標 y 座標
function ions:create(x, y, callback, ion_color, target_x, target_y)
  self:_add(function(_ENV)
    _from_x, _from_y, _target_x, _target_y, _callback, _tick, _color =
    x, y, target_x, target_y, callback, 0, ion_color
    sfx(20)
  end)
end

--- イオン球のプロパティを更新。
-- effect_set の update から呼ばれるので、このメソッドを明示的に呼ぶ必要はないことに注意。
-- @param _ENV イオン球オブジェクト
-- @param all すべてのイオン球オブジェクト
function ions._update(_ENV, all)
  local _quadratic_bezier = function(from, mid, to)
    local t = _tick / 60
    return (1 - t) * (1 - t) * from + 2 * (1 - t) * t * mid + t * t * to
  end

  if _tick == 60 then
    _callback(_target_x, _target_y)
    del(all, _ENV)
  end

  _tick = _tick + 1

  _x, _y =
  _quadratic_bezier(_from_x, _from_x > 64 and _from_x + 60 or _from_x - 60, _target_x),
      _quadratic_bezier(_from_y, _from_y + 40, _target_y)
end

--- イオン球を描画。
-- effect_set の render から呼ばれるので、このメソッドを明示的に呼ぶ必要はないことに注意。
-- @param _ENV イオン球オブジェクト
function ions._render(_ENV)
  fillp(23130.5)
  circfill(_x, _y, 6 + 2 * sin(t()), _color)
  fillp()
  circfill(_x, _y, 4 + 2 * sin(1.5 * t()), _color)
  circfill(_x, _y, 3 + sin(2.5 * t()), 7)
end
