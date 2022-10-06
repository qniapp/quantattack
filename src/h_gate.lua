require("engine/core/class")

local quantum_gate = require("quantum_gate")
local h_gate = derived_class(quantum_gate)

function h_gate:_init()
  quantum_gate._init(self, 'h')
  self.sprites = {
    idle = 0,
    swapping_with_left = 0,
    swapping_with_right = 0,
    swap_finished = 0,
    dropping = 0,
    dropped = 0,
    match = { up = 8, middle = 24, down = 40 }
  }
end

--#if debug
function h_gate:_tostring()
  if self:is_idle() then
    return "H"
  else
    return "H" .. " (" .. self._state .. ")"
  end
end

--#endif

return h_gate
