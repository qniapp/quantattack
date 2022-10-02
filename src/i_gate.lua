require("engine/core/class")

local quantum_gate = require("quantum_gate")
local i_gate = derived_class(quantum_gate)

function i_gate:_init()
  quantum_gate._init(self, 'i')
end

return i_gate
