require("engine/core/class")

local gate = require("gate")
local cnot_x_gate = derived_class(gate)
local sprites_dropped = split("23,23,23,23,55,55,39,39,39,23,23,23")

function cnot_x_gate:_init(other_x)
  gate._init(self, 'cnot_x')
  self.other_x = other_x
  self.sprites = {
    default = 7,
    dropped = sprites_dropped,
    match = "64,64,64,80,80,80,64,64,64,96,96,96,7,7,7,112"
  }
end

return cnot_x_gate
