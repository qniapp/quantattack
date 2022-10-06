require("engine/core/class")

local quantum_gate = require("quantum_gate")
local y_gate = derived_class(quantum_gate)

function y_gate:_init()
  quantum_gate._init(self, 'y')
  self.sprites = {
    idle = 2,
    swapping_with_left = 2,
    swapping_with_right = 2,
    swap_finished = 2,
    dropping = 2,
    dropped = 2,
    match = { up = 10, middle = 26, down = 42 }
  }
end

return y_gate
