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
    idle = 7,
    swapping_with_left = 7,
    swapping_with_right = 7,
    dropping = 7,
    dropped = "23,23,23,23,55,55,39,39,39,23,23,23",
    match = { up = 10, middle = 26, down = 42 }
  }
end

return cnot_x_gate
