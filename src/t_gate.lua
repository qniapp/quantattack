require("engine/core/class")

local gate = require("gate")
local t_gate = derived_class(gate)

function t_gate:_init()
  gate._init(self, 't')
  self.sprites = {
    idle = 5,
    swapping_with_left = 5,
    swapping_with_right = 5,
    dropping = 5,
    dropped = "21,21,21,21,53,53,37,37,37,21,21,21",
    match = { up = 14, middle = 30, down = 46 }
  }
end

return t_gate
