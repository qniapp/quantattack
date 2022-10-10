require("engine/core/class")

local quantum_gate = require("quantum_gate")
local s_gate = derived_class(quantum_gate)

function s_gate:_init()
  quantum_gate._init(self, 's')
  self.sprites = {
    idle = 4,
    swapping_with_left = 4,
    swapping_with_right = 4,
    dropping = 4,
    dropped = 4,
    match = { up = 12, middle = 28, down = 44 }
  }
end

return s_gate
