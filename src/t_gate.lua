require("engine/core/class")

local gate = require("gate")
local t_gate = derived_class(gate)

function t_gate:_init()
  gate._init(self, 't')
  self.sprites = {
    default = 5,
    dropped = "21,21,21,21,53,53,37,37,37,21,21,21",
    match = "14,14,14,30,30,30,46,46,46,30,30,30"
  }
end

return t_gate
