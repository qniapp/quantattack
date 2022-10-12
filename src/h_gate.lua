require("engine/core/class")

local gate = require("gate")
local h_gate = derived_class(gate)

function h_gate:_init()
  gate._init(self, 'h')
  self.sprites = {
    idle = 0,
    swapping_with_left = 0,
    swapping_with_right = 0,
    dropping = 0,
    dropped = "16,16,16,16,48,48,32,32,32,16,16,16",
    match = { up = 9, middle = 25, down = 41 }
  }
end

return h_gate
