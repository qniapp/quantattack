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
    idle = 8,
    swapping_with_left = 8,
    swapping_with_right = 8,
    dropping = 8,
    dropped = "24,24,24,24,56,56,40,40,40,24,24,24",
    match = { up = 64, middle = 80, down = 96 }
  }
end

return swap_gate
