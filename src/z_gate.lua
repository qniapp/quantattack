require("engine/core/class")

local quantum_gate = require("quantum_gate")
local z_gate = derived_class(quantum_gate)

function z_gate:_init()
  quantum_gate._init(self, 'z')
  self.sprites = {
    idle = 3,
    swapping_with_left = 3,
    swapping_with_right = 3,
    swap_finished = 3,
    dropping = 3,
    dropped = 3,
    match = { up = 11, middle = 27, down = 43 }
  }
end

return z_gate
