---@diagnostic disable: lowercase-global

--- すべてのエフェクトのベースクラス
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


--- 各種エフェクト

---
-- bubbles: 同時消しまたは連鎖の数を表示
--

bubbles = derived_class(effect_set)()

--- バブルを作る
function bubbles:create(bubble_type, count, coord)
  self:_add(function(_ENV)
    _type, _count, _x, _y, _tick = bubble_type, count, coord[1], coord[2] - 8, 0
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
-- ions: 攻撃または相殺の時に表示するイオン球エフェクト

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

  _x, _y, _tick =
      _quadratic_bezier(_from_x, _from_x > 64 and _from_x + 60 or _from_x - 60, _target[1]),
      _quadratic_bezier(_from_y, _from_y + 40, _target[2]),
      _tick + 1

  -- しっぽを追加
  if ceil_rnd(10) > 7 then
    particles:create(
      { _x, _y },
      "3,2," .. _color .. "," .. _color .. ",0,0,0,0,20"
    )
  end
end

--- イオン球を描画
function ions._render(_ENV)
  fillp(23130.5)
  circfill(_x, _y, 8 + 2 * sin(t()), _color)
  fillp()
  circfill(_x, _y, 6 + 2 * sin(1.5 * t()), _color)
  circfill(_x, _y, 5 + sin(2.5 * t()), 7)
end


---
-- パーティクルを表示

particles = derived_class(effect_set)()

--- パーティクルの集合を作る
function particles:create(coord, data)
  foreach(split(data, "|"), function(each)
    radius, end_radius, particle_color, particle_color_fade, dx, dy, ddx, ddy, max_tick = unpack_split(each)

    self:_add(function(_ENV)
      _x, _y, _dx, _dy, _radius, _end_radius, _color, _color_fade, _tick, _max_tick, _ddx, _ddy =
          coord[1], coord[2], dx == "" and rnd(1) or dx, dy == "" and rnd(1) or dy, radius, end_radius, particle_color,
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
  end)
end

--- パーティクルの位置等を更新
function particles._update(_ENV, all)
  if _tick > _max_tick then
    del(all, _ENV)
  end
  if _tick > _max_tick * .5 then
    _color, _radius = _color_fade, _end_radius
  end

  _x, _y, _dx, _dy, _tick = _x + _dx, _y + _dy, _dx + _ddx, _dy + _ddy, _tick + 1
end

--- パーティクルを描画
function particles._render(_ENV)
  circfill(_x, _y, _radius, _color)
end


--#ifn title
--- 背景の波紋を描画するクラス
ripple = derived_class(effect_set)()

function ripple:create()
  self:_add(function(_ENV)
    t1, t2, tick = 0, 0, 0
  end)
end

--- 波紋の状態を更新
function ripple._update(_ENV)
  tick, t1, t2 =
      tick + 1,
      t1 - 1 / ((ripple.slow or ripple.freeze) and 3000 or 1500),
      t2 - 1 / ((ripple.slow or ripple.freeze) and 300 or 150)
end

--- 波紋を描画
function ripple._render(_ENV)
  for i = -5, 5 do
    for j = -5, 5 do
      local ang, d = atan2(i, j), sqrt(i * i + j * j)
      local r = 2 + 2 * sin(d / 4 + t2)
      circfill(
        64 + 12 * d * cos(ang + t1),
        64 + 12 * d * sin(ang + t1) - 3 * r,
        r,
        ((ripple.slow or ripple.freeze) and r > 3 and tick % 2 == 0) and (ripple.slow and 13 or 12) or 1
      )
    end
  end
end

ripple:create()
--#endif

--#if sash
-- sash:create("text,text_color,background_color", slideout_callback) 新しい sash を作る (シングルトン)
--   - text: 表示するテキスト
--   - text_color: テキストの色
--   - background_color: sash の背景色
--   - slideout_callback: sash が右端から消えた時に呼ぶコールバック

sash = derived_class(effect_set)()

function sash:create(properties, _slideout_callback)
  self.all = {}
  self:_add(function (_ENV)
      text, text_color, background_color = unpack_split(properties)
      background_height, dh, ddh, slideout_callback, text_x, text_dx, text_ddx, text_center_x, state =
        0, 0.1, 0.2, _slideout_callback, #text * -4, 5, -0.14, 64 - #text * 2, ":slidein"
  end)
end

function sash._update(_ENV)
  if state == ":slidein" then
    background_height, dh = background_height + dh, dh + ddh
    if background_height > 10 then
      background_height = 10
    end

    if text_x < text_center_x then
      text_x, text_dx = text_x + text_dx, text_dx + text_ddx
    end

    if text_x > text_center_x then
      text_x, time_stop, state = text_center_x, t(), ":stop"
    end
  end

  if state == ":stop" then
    if t() - time_stop > 1 then
      dh, ddh, text_dx, text_ddx, state =
          -0.1, -0.2, 3, 0.8, ":slideout"
    end
  end

  if state == ":slideout" then
    background_height, dh, text_x, text_dx =
        background_height + dh, dh + ddh, text_x + text_dx, text_dx + text_ddx

    if text_x > 127 then
      if slideout_callback then
        slideout_callback()
      end

      state = ":finished"
    end
  end
end

function sash._render(_ENV)
  if background_height > 0 then
    rectfill(0, 64 - background_height / 2, 127, 64 + background_height / 2, background_color)
    print(text, text_x, 64 - 2, text_color)
  end
end
--#endif
