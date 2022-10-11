require("engine/core/class")

local quantum_gate = require("quantum_gate")
local control_gate = derived_class(quantum_gate)

function control_gate:_init(other_x)
  --#if assert
  assert(other_x)
  --#endif

  quantum_gate._init(self, 'control')
  self.other_x = other_x
  self.sprites = {
    idle = 6,
    swapping_with_left = 6,
    swapping_with_right = 6,
    dropping = 6,
    match = { up = 14, middle = 30, down = 46 }
  }
end

return control_gate
