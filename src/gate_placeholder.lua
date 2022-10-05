require("engine/core/class")

local quantum_gate = require("quantum_gate")
local gate_placeholder = derived_class(quantum_gate)

function gate_placeholder:_init()
  quantum_gate._init(self, '?')
end

return gate_placeholder
