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
    match = { up = 10, middle = 26, down = 42 }
  }
end

return x_gate
