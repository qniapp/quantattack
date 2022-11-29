---@diagnostic disable: lowercase-global, global-in-nil-env

-- 7745
--
-- 7770
-- 7794
-- 7818
-- 7823

local effect_set = require("lib/effect_set")
local attack_bubble_class = derived_class(effect_set)
local attack_bubble = attack_bubble_class()

function attack_bubble:create(x, y, callback, target_x, target_y)
  self:_add(function(_ENV)
    _x, _y, _callback, _target_x, _target_y, _start_time, _left = x, y, callback, target_x, target_y, t(), x > 64
    sfx(11)
  end)
end

function attack_bubble._update(_ENV, self)
  if abs(_target_x - _x) < 5 and abs(_target_y - _y) < 5 then
    _callback(_target_x, _target_y)
    del(self.all, _ENV)
  end

  if t() - _start_time < 0.8 then
    if self.slow and #self.all > 0 then
      flip()
    end
    _dx, _dy = _left and 0.5 or -0.5, -0.2
  else
    _dx, _dy = (_target_x - _x) / 6, (_target_y - _y) / 6
  end

  _x, _y = _x + _dx, _y + _dy
end

function attack_bubble._render(_ENV)
  local angle = t()

  fillp(23130.5)
  circfill(_x, _y, 6 + 2 * sin(angle), 0x0c)
  fillp()
  circfill(_x, _y, 4 + 2 * sin(1.5 * angle), 12)
  circfill(_x, _y, 3 + sin(2.5 * angle), 7)
end

return attack_bubble
