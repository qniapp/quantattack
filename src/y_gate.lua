require("engine/core/class")

local quantum_gate = require("quantum_gate")
local y_gate = derived_class(quantum_gate)

function y_gate:_init()
  quantum_gate._init(self, 'y')
  self._sprites = {
    idle = 2,
    dropped = 18,
    jumping = 50,
    falling = 34,
    match_up = 10,
    match_middle = 26,
    match_down = 42,
  }
end

return y_gate
