require("engine/core/class")

local gate = require("gate")
local z_gate = derived_class(gate)

function z_gate:_init()
  gate._init(self, 'z')
  self.sprites = {
    default = 3,
    dropped = "19,19,19,19,51,51,35,35,35,19,19,19",
    match = "12,12,12,28,28,28,44,44,44,28,28,28"
  }
end

return z_gate
