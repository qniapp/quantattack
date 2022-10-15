require("engine/core/class")

local gate = require("gate")
local y_gate = derived_class(gate)
local sprites_dropped = split("18,18,18,18,50,50,34,34,34,18,18,18")

function y_gate:_init()
  gate._init(self, 'y')
  self.sprites = {
    default = 2,
    dropped = sprites_dropped,
    match = "11,11,11,27,27,27,11,11,11,43,43,43,2,2,2,59"
  }
end

return y_gate
