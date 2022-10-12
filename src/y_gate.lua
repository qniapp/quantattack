require("engine/core/class")

local gate = require("gate")
local y_gate = derived_class(gate)

function y_gate:_init()
  gate._init(self, 'y')
  self.sprites = {
    default = 2,
    dropped = "18,18,18,18,50,50,34,34,34,18,18,18",
    match = "11,11,11,27,27,27,43,43,43,27,27,27"
  }
end

return y_gate
