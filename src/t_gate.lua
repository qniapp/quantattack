require("engine/core/class")

local quantum_gate = require("quantum_gate")
local t_gate = derived_class(quantum_gate)

function t_gate:_init()
  quantum_gate._init(self, 't')
  self._sprites = {
    idle = 5,
    dropped = 21,
    jumping = 53,
    falling = 37,
    match_up = 13,
    match_middle = 29,
    match_down = 45,
  }
end

return t_gate
