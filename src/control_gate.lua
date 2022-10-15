require("engine/core/class")

local gate = require("gate")
local control_gate = derived_class(gate)
local sprites_dropped = split("22,22,22,22,54,54,38,38,38,22,22,22")
local sprites_match = split("15,15,15,31,31,31,15,15,15,47,47,47,6,6,6,63")

function control_gate:_init(other_x)
  gate._init(self, 'control')
  self.other_x = other_x
  self.sprites = {
    default = 6,
    dropped = sprites_dropped,
    match = sprites_match
  }
end

return control_gate
