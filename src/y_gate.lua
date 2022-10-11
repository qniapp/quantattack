require("engine/core/class")

local gate = require("gate")
local y_gate = derived_class(gate)

function y_gate:_init()
  gate._init(self, 'y')
  self.sprites = {
    idle = 2,
    swapping_with_left = 2,
    swapping_with_right = 2,
    dropping = 2,
    match = { up = 10, middle = 26, down = 42 }
  }
end

return y_gate
