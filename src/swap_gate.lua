require("engine/core/class")

local quantum_gate = require("quantum_gate")
local swap_gate = derived_class(quantum_gate)

function swap_gate:_init(other_x)
  --#if assert
  assert(other_x)
  --#endif

  quantum_gate._init(self, 'swap')
  self.other_x = other_x
  self.sprites = {
    idle = 7,
    swapping_with_left = 7,
    swapping_with_right = 7,
    dropping = 7,
    match = { up = 15, middle = 31, down = 47 }
  }
end

-------------------------------------------------------------------------------
-- debug
-------------------------------------------------------------------------------

--#if debug
function swap_gate:_tostring()
  if self:is_idle() then
    return 'S'
  else
    return 'S' .. " (" .. self._state .. ")"
  end
end

--#endif

return swap_gate
