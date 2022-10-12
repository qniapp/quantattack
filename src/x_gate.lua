require("engine/core/class")

local gate = require("gate")
local x_gate = derived_class(gate)

function x_gate:_init()
  gate._init(self, 'x')
  self.sprites = {
    idle = 1,
    swapping_with_left = 1,
    swapping_with_right = 1,
    dropping = 1,
    dropped = "17,17,17,17,49,49,33,33,33,17,17,17",
    match = { up = 10, middle = 26, down = 42 }
  }
end

return x_gate
