require("engine/core/class")

local gate = require("gate")
local garbage_match_gate = derived_class(gate)
local sprites_dropped = split("85,85,85,85,85,85,85,85,85,85,85,85")

function garbage_match_gate:_init()
  gate._init(self, '!')
  self.sprites = {
    default = 85,
    dropped = sprites_dropped,
    match = "85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85"
  }
end

return garbage_match_gate
