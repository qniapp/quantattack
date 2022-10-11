require("engine/core/class")

local gate = require("gate")
local i_gate = derived_class(gate)

function i_gate:_init()
  gate._init(self, 'i')
end

--#if debug
function i_gate:_tostring()
  return "_"
end

--#endif

return i_gate
