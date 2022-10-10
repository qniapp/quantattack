require("engine/core/class")
require("engine/render/color")

local quantum_gate = require("quantum_gate")
local cnot_x_gate = derived_class(quantum_gate)

function cnot_x_gate:_init(other_x)
  --#if assert
  assert(other_x)
  --#endif

  quantum_gate._init(self, 'cnot_x')
  self.other_x = other_x
  self._sprites = {
    idle = 1,
    jumping = 49,
    falling = 33,
    match_up = 9,
    match_middle = 25,
    match_down = 41,
  }
end

return cnot_x_gate
