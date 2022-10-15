require("engine/core/class")

local gate = require("gate")
local z_gate = derived_class(gate)
local sprites_dropped = split("19,19,19,19,51,51,35,35,35,19,19,19")

function z_gate:_init()
  gate._init(self, 'z')
  self.sprites = {
    default = 3,
    dropped = sprites_dropped,
    match = "12,12,12,28,28,28,12,12,12,44,44,44,3,3,3,60"
  }
end

return z_gate
