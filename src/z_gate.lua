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
    dropped = "19,19,19,19,51,51,35,35,35,19,19,19",
    match = { up = 12, middle = 28, down = 44 }
  }
end

return z_gate
