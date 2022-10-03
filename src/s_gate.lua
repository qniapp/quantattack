require("engine/core/class")

local quantum_gate = require("quantum_gate")
local s_gate = derived_class(quantum_gate)

function s_gate:_init()
  quantum_gate._init(self, 's')
  self._sprites = {
    idle = 4,
    dropped = 20,
    jumping = 52,
    falling = 36,
    match_up = 12,
    match_middle = 28,
    match_down = 44,
  }
end

return s_gate
