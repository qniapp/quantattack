require("engine/core/class")

local gate = require("gate")
local s_gate = derived_class(gate)

function s_gate:_init()
  gate._init(self, 's')
  self.sprites = {
    default = 4,
    dropped = "20,20,20,20,52,52,36,36,36,20,20,20",
    match = "13,13,13,29,29,29,45,45,45,29,29,29"
  }
end

return s_gate
