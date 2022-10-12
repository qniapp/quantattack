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
    dropped = "20,20,20,20,52,52,36,36,36,20,20,20",
    match = { up = 13, middle = 29, down = 45 }
  }
end

return s_gate
