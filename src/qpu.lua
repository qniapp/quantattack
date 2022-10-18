require("engine/core/class")

local qpu = derived_class(require("player"))

function qpu:update()
  self.left = false
  self.right = false
  self.up = false
  self.down = false
  self.x = false
  self.o = false
end

return qpu
