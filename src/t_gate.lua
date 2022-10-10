require("engine/core/class")

local quantum_gate = require("quantum_gate")
local t_gate = derived_class(quantum_gate)

function t_gate:_init()
  quantum_gate._init(self, 't')
  self.sprites = {
    idle = 5,
    swapping_with_left = 5,
    swapping_with_right = 5,
    dropping = 5,
    dropped = 5,
    match = { up = 13, middle = 29, down = 45 }
  }
end

return t_gate
