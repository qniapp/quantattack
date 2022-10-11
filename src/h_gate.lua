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
    match = { up = 8, middle = 24, down = 40 }
  }
end

return h_gate
