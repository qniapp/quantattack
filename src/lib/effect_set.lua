effect_set = new_class()

function effect_set:_init()
  self.all = {}
end

function effect_set:_add(f)
  local _ENV = setmetatable({}, { __index = _ENV })
  f(_ENV)
  add(self.all, _ENV)
end

function effect_set:update_all()
  foreach(self.all, function(each)
    self._update(each, self.all)
  end)
end

function effect_set:render_all()
  foreach(self.all, function(each)
    self._render(each)
  end)
end

---
-- 同時消しまたは連鎖の数を表示
--

bubbles = derived_class(effect_set)()

--- バブルを作る
-- @param bubble_type バブル
-- @param count 同時消しまたは連鎖の数
-- @param x x 座標
-- @param y y 座標
function bubbles:create(bubble_type, count, x, y)
  self:_add(function(_ENV)
    _type, _count, _x, _y, _tick = bubble_type, count, x, y - 8, 0
  end)
end

function bubbles._update(_ENV, all)
  if _tick > 40 then
    del(all, _ENV)
  end
  if _tick < 30 then
    _y = _y - 0.2
  end

  _tick = _tick + 1
end

function bubbles._render(_ENV)
  if _type == "combo" then
    draw_rounded_box(_x - 1, _y + 1, _x + 7, _y + 9, 5, 5)
    draw_rounded_box(_x - 1, _y, _x + 7, _y + 8, 7, 8)

    cursor(_x + 2, _y + 2)
  else
    local rbox_dx = _count < 10 and 0 or -2

    draw_rounded_box(_x + rbox_dx - 2, _y + 1, _x - rbox_dx + 8, _y + 9, 5, 5)
    draw_rounded_box(_x + rbox_dx - 2, _y, _x - rbox_dx + 8, _y + 8, 7, 3)

    spr(96, _x + rbox_dx, _y - 1) -- the "x" part in "x5"

    cursor(_x + rbox_dx + 4, _y + 2)
  end

  print(_count, 10)
end

---
-- 攻撃または相殺の時に表示するイオン球エフェクト。
-- チュートリアルに登場するキャラクター「イオン君」の表示にも使われる。

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
    x, y, dx == "" and rnd(1) or dx, dy == "" and rnd(1) or dy, radius, end_radius, particle_color, particle_color_fade,
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
