require("engine/core/class")

local gate = require("gate")
local s_gate = derived_class(gate)

function s_gate:_init()
  gate._init(self, 's')
  self.sprites = {
    idle = 4,
    swapping_with_left = 4,
    swapping_with_right = 4,
    dropping = 4,
    match = { up = 12, middle = 28, down = 44 }
  }
end

return s_gate
