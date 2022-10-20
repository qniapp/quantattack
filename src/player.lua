require("engine/input/input")

local player = new_class()

function player:_init()
  self:init()
end

function player:init()
  self.steps, self.score = 0, 0
end

function player:update()
  self.left, self.right, self.up, self.down, self.x, self.o = btnp(button_ids.left), btnp(button_ids.right),
      btnp(button_ids.up), btnp(button_ids.down), btn(button_ids.x), btnp(button_ids.o)
end

return player
