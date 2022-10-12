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
    default = 6,
    dropped = "22,22,22,22,54,54,38,38,38,22,22,22",
    match = "15,15,15,31,31,31,15,15,15,47,47,47,6,6,6,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63"
  }
end

return control_gate
