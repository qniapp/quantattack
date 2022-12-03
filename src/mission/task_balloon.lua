local gate = require("lib/gate")

local task_balloon = new_class()

function task_balloon:_init()
  self:init()
end

function task_balloon:init()
   self.all = {}
   self.state = ":idle"
end

function task_balloon:create(_rule, _x_base, _dx, _dy)
  local _ENV = setmetatable({}, { __index = _ENV })

  rule = _rule
  x_base = _x_base
  dx = _dx + rnd(5)
  dy = _dy + rnd(10)
  dt = rnd(10)
  y = 26 + dy - 128

  add(self.all, _ENV)
end

function task_balloon:enter_all()
   self.state = ":enter"
   self.enter_tick_left = 128
end

function task_balloon:delete(balloon)
   del(self.all, balloon)
end

function task_balloon:update()
  if self.state == ":enter" then
    self.enter_tick_left = self.enter_tick_left - 1
    if self.enter_tick_left == 0 then
      self.state = ":idle"
    end
  end

  foreach(self.all, function(each)
    local _ENV = each

    x = x_base + 10 + cos((t() + dt) / 2) * 2 + dx

    if self.state == ":enter" then
      y = y + 1
    else
      y = 26 + sin((t() + dt) / 2.5) * 4 + dy
    end
  end)
end

function task_balloon:render()
  foreach(self.all, function(each)
    local _ENV = each

    -- バルーン
    sspr(56, 32, 16, 12, x, y)

    -- ゲート
    for i, row in pairs(rule[1]) do
       local gate1_type, gate2_type = unpack(row)
       local row_x = x + 4
       local row_y = y + (i - 1) * 8 + 12

       if gate1_type ~= "?" then
          if gate1_type == "swap" or gate1_type == "control" or gate1_type == "cnot_x" then
             line(row_x + 3, row_y + 3, row_x + 11, row_y + 3, 10)
          end
          spr(gate(gate1_type).sprite_set.default, row_x, row_y)
       end

       if gate2_type then
          spr(gate(gate2_type).sprite_set.default, row_x + 8, row_y)
       end
    end
  end)
end

return task_balloon
