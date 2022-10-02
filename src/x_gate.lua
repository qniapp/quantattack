require("engine/core/class")

local quantum_gate = require("quantum_gate")
local x_gate = derived_class(quantum_gate)

function x_gate:_init()
  quantum_gate._init(self, 'x')
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

return x_gate
