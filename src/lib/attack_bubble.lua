---@diagnostic disable: lowercase-global

slow_attack_bubbles = false

local all_bubbles = {}

function update_attack_bubbles()
  foreach(all_bubbles, function(each)
    local _ENV = each

    if abs(_target_x - _x) < 5 and abs(_target_y - _y) < 5 then
      del(all_bubbles, each)
      _callback(_target_x, _target_y)
    end

    if t() - _start_time < 0.8 then
      if slow_attack_bubbles and #all_bubbles > 0 then
        flip()
      end
      _dx, _dy = _left and 0.5 or -0.5, -0.2
    else
      _dx, _dy = (_target_x - _x) / 6, (_target_y - _y) / 6
    end

    _x, _y = _x + _dx, _y + _dy
  end)
end

function render_attack_bubbles()
  foreach(all_bubbles, function(each)
    local _ENV, _angle = each, t()

    fillp(23130.5)
    circfill(_x, _y, 6 + 2 * sin(1.5 * _angle), 0x0c)
    fillp()
    circfill(_x, _y, 4 + 2 * sin(2 * _angle), 12)
    circfill(_x, _y, 3 + sin(2.5 * _angle), 7)
  end)
end

function create_attack_bubble(x, y, callback, target_x, target_y)
  local _ENV = setmetatable({}, { __index = _ENV })

  _x, _y, _callback, _target_x, _target_y, _start_time, _left = x, y, callback, target_x, target_y, t(), x > 64
  add(all_bubbles, _ENV)
  sfx(11)
end
