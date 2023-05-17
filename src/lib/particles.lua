---
-- パーティクルを表示

particles = derived_class(effect_set)()

--- パーティクルの集合を作る
-- @param x x 座標
-- @param y y 座標
-- @param data 各パーティクルのデータ文字列
function particles:create(x, y, data)
  foreach(split(data, "|"), function(each)
    self:_create(x, y, unpack_split(each))
  end)
end

function particles:_create(x, y, radius, end_radius, particle_color, particle_color_fade, dx, dy, ddx, ddy, max_tick)
  self:_add(function(_ENV)
    _x, _y, _dx, _dy, _radius, _end_radius, _color, _color_fade, _tick, _max_tick, _ddx, _ddy =
        x, y, dx == "" and rnd(1) or dx, dy == "" and rnd(1) or dy, radius, end_radius, particle_color,
        particle_color_fade,
        0, max_tick + rnd(10), ddx, ddy

    if dx == "" then
      -- move to the left
      if ceil_rnd(2) == 1 then
        _dx, _ddx = _dx * -1, _ddx * -1
      end

      -- move upwards
      if ceil_rnd(2) == 1 then
        _dy, _ddy = _dy * -1, _ddy * -1
      end
    end
  end)
end

--- パーティクルのプロパティを更新。
-- effect_set の update から呼ばれるので、このメソッドを明示的に呼ぶ必要はないことに注意。
-- @param _ENV パーティクルオブジェクト
-- @param all すべてのパーティクルオブジェクト
function particles._update(_ENV, all)
  if _tick > _max_tick then
    del(all, _ENV)
  end
  if _tick > _max_tick * .5 then
    _color, _radius = _color_fade, _end_radius
  end

  _x, _y, _dx, _dy, _tick = _x + _dx, _y + _dy, _dx + _ddx, _dy + _ddy, _tick + 1
end

--- パーティクルを描画。
-- effect_set の render から呼ばれるので、このメソッドを明示的に呼ぶ必要はないことに注意。
-- @param _ENV パーティクルオブジェクト
function particles._render(_ENV)
  circfill(_x, _y, _radius, _color)
end
