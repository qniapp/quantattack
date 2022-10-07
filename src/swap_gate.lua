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
    swap_finished = 7,
    dropping = 7,
    dropped = 7,
    match = { up = 15, middle = 31, down = 47 }
  }
end

-- function swap_gate:before_update()
--   if self.tick_connection == nil then
--     self.tick_connection = 0
--     if self.connection == nil then
--       self.connection = flr(rnd(2)) == 0
--     end
--     if self.connection then
--       self.connection_duration = flr(rnd(5)) * 30
--     else
--       self.connection_duration = flr(rnd(5)) + 5
--     end
--   elseif self.tick_connection == self.connection_duration then
--     self.tick_connection = nil
--     self.connection = not self.connection
--   else
--     self.tick_connection = self.tick_connection + 1
--   end
-- end

return swap_gate
