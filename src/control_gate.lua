require("engine/core/class")

local gate = require("gate")
local control_gate = derived_class(gate)

function control_gate:_init(other_x)
  --#if assert
  assert(other_x)
  --#endif

  gate._init(self, 'control')
  self.other_x = other_x
  self.sprites = {
    idle = 6,
    swapping_with_left = 6,
    swapping_with_right = 6,
    dropping = 6,
    dropped = "22,22,22,22,54,54,38,38,38,22,22,22",
    match = { up = 15, middle = 31, down = 47 }
  }
end

return control_gate
