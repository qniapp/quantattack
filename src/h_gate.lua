require("engine/core/class")

local gate = require("gate")
local h_gate = derived_class(gate)
local sprites_dropped = split("16,16,16,16,48,48,32,32,32,16,16,16")
local sprites_match = split("9,9,9,25,25,25,9,9,9,41,41,41,0,0,0,57")

function h_gate:_init()
  gate._init(self, 'h')
  self.sprites = {
    default = 0,
    dropped = sprites_dropped,
    match = sprites_match
  }
end

return h_gate
