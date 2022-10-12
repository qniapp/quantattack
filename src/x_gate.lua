require("engine/core/class")

local gate = require("gate")
local x_gate = derived_class(gate)

function x_gate:_init()
  gate._init(self, 'x')
  self.sprites = {
    default = 1,
    dropped = "17,17,17,17,49,49,33,33,33,17,17,17",
    match = "10,10,10,26,26,26,42,42,42,26,26,26"
  }
end

return x_gate
