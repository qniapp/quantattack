require("engine/core/class")

local gate = require("gate")
local x_gate = derived_class(gate)
local sprites_dropped = split("17,17,17,17,49,49,33,33,33,17,17,17")
local sprites_match = split("10,10,10,26,26,26,10,10,10,42,42,42,1,1,1,58")

function x_gate:_init()
  gate._init(self, 'x')
  self.sprites = {
    default = 1,
    dropped = sprites_dropped,
    match = sprites_match
  }
end

return x_gate
