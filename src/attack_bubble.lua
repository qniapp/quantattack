---@diagnostic disable: lowercase-global

local all_bubbles = {}

function update_attack_bubbles()
  foreach(all_bubbles, function(each)
    local _ENV = each

    if abs(_target_x - _x) < 5 and abs(_target_y - _y) < 5 then
      del(all_bubbles, each)
      create_particle_set(_target_x, _target_y,
        "5,5,9,7,random,random,-0.03,-0.03,20|5,5,9,7,random,random,-0.03,-0.03,20|4,4,9,7,random,random,-0.03,-0.03,20|4,4,2,5,random,random,-0.03,-0.03,20|4,4,6,7,random,random,-0.03,-0.03,20|2,2,9,7,random,random,-0.03,-0.03,20|2,2,9,7,random,random,-0.03,-0.03,20|2,2,6,5,random,random,-0.03,-0.03,20|2,2,6,5,random,random,-0.03,-0.03,20|0,0,2,5,random,random,-0.03,-0.03,20")
      each._callback()
    end

    if _tick < 50 then
      _dx, _dy = _left and 0.5 or -0.5, -0.2
    else
      _dx, _dy = (_target_x - _x) / 6, (_target_y - _y) / 6
    end

    _x, _y, _tick, _angle = _x + _dx, _y + _dy, _tick + 1, _angle + 0.06
  end)
end

function render_attack_bubbles()
  foreach(all_bubbles, function(each)
    local _ENV = each

    fillp(23130.5)
    circfill(_x, _y, 6 + 2 * sin(1.5 * _angle), 0x0c)
    fillp()

    circfill(_x, _y, 4 + 2 * sin(2 * _angle), 12)
    circfill(_x, _y, 3 + sin(2.5 * _angle), 7)
  end)
end

function create_attack_bubble(x, y, callback, target_x, target_y)
  local _ENV = setmetatable({}, { __index = _ENV })

  _x, _y, _callback, _target_x, _target_y, _tick, _angle, _left = x, y, callback, target_x, target_y, 0, 0, x > 64

  add(all_bubbles, _ENV)
  sfx(11)
end
