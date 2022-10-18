require("engine/core/class")
require("engine/input/input")

local player = new_class()

function player:_init()
  self:init()
end

function player:init()
  self.steps = 0
  self.score = 0
end

function player:update()
  self.left = btnp(button_ids.left)
  self.right = btnp(button_ids.right)
  self.up = btnp(button_ids.up)
  self.down = btnp(button_ids.down)
  self.x = btnp(button_ids.x)
  self.o = btn(button_ids.o)
end

return player
