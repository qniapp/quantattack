---@diagnostic disable: global-in-nil-env, lowercase-global
require("lib/helpers")

local ion = new_class()

function ion._init(_ENV)
  _x = 84
  _y = 46
  _dx = 0
  _dy = 0
end

function ion.update(_ENV)
  if _state == ":appear" then
    if _tick == _max_tick then
      _state = ":idle"
      _appear_callback()
      return
    end

    _dx, _dy = 0, 0
    _x, _y =
    _quadratic_bezier(_ENV, 64, 128, 84), _quadratic_bezier(_ENV, 128, 64, 46)
  elseif _state == ":shake" then
    if _tick == _max_tick then
      _state = ":idle"
      if _shake_callback then
        _shake_callback()
      end
    end

    _dx = 0
    _dy = cos(t() / 0.2) * 4
  else -- state == ":idle"
    _dx = cos(t() / 2) * 1.5
    _dy = sin(t() / 2.5) * 1.5
  end

  _tick = _tick + 1
end

function ion.draw(_ENV)
  local x = _x + _dx
  local y = _y + _dy
  local angle = t()

  fillp(23130.5)
  circfill(x, y, 8 + 2 * sin(angle), 12)
  fillp()
  circfill(x, y, 6 + 2 * sin(1.5 * angle), 12)
  circfill(x, y, 5 + sin(2.5 * angle), 7)
end

-- 画面外から定位置に登場
function ion.appear(_ENV, callback)
  _state = ":appear"
  _tick = 0
  _max_tick = 60
  _appear_callback = callback
  sfx(20)
end

-- 左右に素早くゆれる
function ion.shake(_ENV, callback)
  _state = ":shake"
  _tick = 0
  _max_tick = 30
  _shake_callback = callback
  sfx(20)
end

-- TODO: attack_ion と共通の関数にする
function ion._quadratic_bezier(_ENV, from, mid, to)
  local t = _tick / 60
  return (1 - t) * (1 - t) * from + 2 * (1 - t) * t * mid + t * t * to
end

return ion
