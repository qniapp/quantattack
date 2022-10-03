require("engine/core/class")

local quantum_gate = require("quantum_gate")
local cnot_x_gate = derived_class(quantum_gate)
local colors = require("colors")

function cnot_x_gate:_init(cnot_c_x)
  assert(cnot_c_x)

  quantum_gate._init(self, 'cnot_x')
  self.cnot_c_x = cnot_c_x
  self._sprites = {
    idle = 1,
    dropped = 17,
    jumping = 49,
    falling = 33,
    match_up = 9,
    match_middle = 25,
    match_down = 41,
  }
end

function cnot_x_gate:draw_setup()
  if (self:is_match()) then
    return
  end

  pal(colors.blue, colors.orange)
  pal(colors.light_grey, colors.brown)
end

function cnot_x_gate:draw_teardown()
  pal(colors.blue, colors.blue)
  pal(colors.light_grey, colors.light_grey)
end

return cnot_x_gate
