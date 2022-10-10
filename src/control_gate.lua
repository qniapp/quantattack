require("engine/core/class")

local quantum_gate = require("quantum_gate")
local control_gate = derived_class(quantum_gate)

function control_gate:_init(other_x)
  --#if assert
  assert(other_x)
  --#endif

  quantum_gate._init(self, 'control')
  self.other_x = other_x
  self._sprites = {
    idle = 6,
    jumping = 54,
    falling = 38,
    match_up = 14,
    match_middle = 30,
    match_down = 46
  }
end

return control_gate
