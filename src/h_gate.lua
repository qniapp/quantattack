require("engine/core/class")

local quantum_gate = require("quantum_gate")
local h_gate = derived_class(quantum_gate)

function h_gate:_init()
  quantum_gate._init(self, 'h')
  self._sprites = {
    idle = 0,
    dropped = 16,
    jumping = 48,
    falling = 32,
    match_up = 8,
    match_middle = 24,
    match_down = 40
  }
end

--#if debug
function h_gate:_tostring()
  return "H"
end
--#endif

return h_gate
