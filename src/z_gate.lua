require("engine/core/class")

local gate = require("gate")
local z_gate = derived_class(gate)

function z_gate:_init()
  gate._init(self, 'z')
  self.sprites = {
    idle = 3,
    swapping_with_left = 3,
    swapping_with_right = 3,
    dropping = 3,
    match = { up = 11, middle = 27, down = 43 }
  }
end

return z_gate
