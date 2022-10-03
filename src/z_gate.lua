require("engine/core/class")

local quantum_gate = require("quantum_gate")
local z_gate = derived_class(quantum_gate)

function z_gate:_init()
  quantum_gate._init(self, 'z')
  self._sprites = {
    idle = 3,
    dropped = 19,
    jumping = 51,
    falling = 35,
    match_up = 11,
    match_middle = 27,
    match_down = 43,
  }
end

return z_gate
