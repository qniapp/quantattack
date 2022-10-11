require("engine/core/class")

local player = new_class()

function player:_init()
  self.steps = 0
  self.score = 0
end

return player
