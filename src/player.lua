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

function player:left()
  return btnp(button_ids.left)
end

function player:right()
  return btnp(button_ids.right)
end

function player:up()
  return btnp(button_ids.up)
end

function player:down()
  return btnp(button_ids.down)
end

function player:x()
  return btnp(button_ids.x)
end

function player:o()
  return btn(button_ids.o)
end

return player
