require("engine/core/class")

local gate = require("gate")
local cnot_x_gate = derived_class(gate)

function cnot_x_gate:_init(other_x)
  --#if assert
  assert(other_x)
  --#endif

  gate._init(self, 'cnot_x')
  self.other_x = other_x
  self.sprites = {
    idle = 1,
    swapping_with_left = 1,
    swapping_with_right = 1,
    dropping = 1,
    match = { up = 9, middle = 25, down = 41 }
  }
end

return cnot_x_gate
