require("engine/core/class")

local gate = require("gate")
local swap_gate = derived_class(gate)

function swap_gate:_init(other_x)
  --#if assert
  assert(other_x)
  --#endif

  gate._init(self, 'swap')
  self.other_x = other_x
  self.sprites = {
    default = 8,
    dropped = "24,24,24,24,56,56,40,40,40,24,24,24",
    match = "65,65,65,81,81,81,65,65,65,97,97,97,8,8,8,113"
  }
end

return swap_gate
