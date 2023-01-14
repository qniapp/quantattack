---@diagnostic disable: lowercase-global, global-in-nil-env

require("lib/effect_set")

local attack_ion_class = derived_class(effect_set)

attack_ion = attack_ion_class()

function attack_ion:create(x, y, callback, clr, target_x, target_y)
  self:_add(function(_ENV)
    _from_x, _from_y, _target_x, _target_y, _mid_x, _mid_y, _callback, _tick, _max_tick, _color =
    x, y, target_x, target_y, x > 64 and x + 60 or x - 60, y + 40, callback, 0, 60, clr
    sfx(20)
  end)
end

-- TODO: self いらない
function attack_ion._update(_ENV, self)
  _tick = _tick + 1

  if _tick == _max_tick then
    _callback(_target_x, _target_y)
    del(self.all, _ENV)
  end

  _x, _y =
  self._quadratic_bezier(_ENV, _from_x, _mid_x, _target_x), self._quadratic_bezier(_ENV, _from_y, _mid_y, _target_y)
end

function attack_ion._quadratic_bezier(_ENV, from, mid, to)
  local t = _tick / _max_tick
  return (1 - t) * (1 - t) * from + 2 * (1 - t) * t * mid + t * t * to
end

function attack_ion._render(_ENV, self)
  local angle = t()

  fillp(23130.5)
  circfill(_x, _y, 6 + 2 * sin(angle), _color)
  fillp()
  circfill(_x, _y, 4 + 2 * sin(1.5 * angle), _color)
  circfill(_x, _y, 3 + sin(2.5 * angle), 7)
end
