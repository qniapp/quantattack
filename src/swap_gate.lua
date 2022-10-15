require("engine/core/class")

local gate = require("gate")
local swap_gate = derived_class(gate)
local sprites_dropped = split("24,24,24,24,56,56,40,40,40,24,24,24")
local sprites_match = split("65,65,65,81,81,81,65,65,65,97,97,97,8,8,8,113")

function swap_gate:_init(other_x)
  gate._init(self, 'swap')
  self.other_x = other_x
  self.sprites = {
    default = 8,
    dropped = sprites_dropped,
    match = sprites_match
  }
end

return swap_gate
