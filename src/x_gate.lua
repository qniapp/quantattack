require("engine/core/class")

local quantum_gate = require("quantum_gate")
local x_gate = derived_class(quantum_gate)

function x_gate:_init()
  quantum_gate._init(self, 'x')
  self.sprites = {
    idle = 1,
    swapping_with_left = 1,
    swapping_with_right = 1,
    swap_finished = 1,
    dropping = 1,
    dropped = 1,
    match = { up = 9, middle = 25, down = 41 }
  }
end

--#if debug
function x_gate:_tostring()
  if self:is_idle() then
    return "X"
  else
    return "X" .. " (" .. self._state .. ")"
  end
end

--#endif

return x_gate
