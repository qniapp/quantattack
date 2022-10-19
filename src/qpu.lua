require("engine/core/class")

local qpu = derived_class(require("player"))

function qpu:_init(cursor, board)
  self.cursor = cursor
  self.board = board
  self:init()
  self.actions = {}
end

function qpu:update()
  self:reset_actions()

  local next_action = self.actions[1]
  if next_action then
    del(self.actions, next_action)
    if next_action ~= "sleep" then
      self[next_action] = true
    end
  else
    repeat
      self.new_x = flr(rnd(6)) + 1
      self.new_y = flr(rnd(12)) + 1
    until not self.board:gate_at(self.new_x, self.new_y):is_i()

    if self.new_x == self.cursor.x then
      -- NOP
    elseif self.new_x < self.cursor.x then
      self:move("left", self.cursor.x - self.new_x)
    elseif self.cursor.x < self.new_x then
      self:move("right", self.new_x - self.cursor.x)
    end

    if self.new_y == self.cursor.y then
      -- NOP
    elseif self.new_y < self.cursor.y then
      self:move("up", self.cursor.y - self.new_y)
    elseif self.cursor.y < self.new_y then
      self:move("down", self.new_y - self.cursor.y)
    end

    self:swap()
  end
end

function qpu:move(direction, times)
  for _a = 1, times do
    add(self.actions, direction)

    for _s = 1, 10 + flr(rnd(10)) do
      add(self.actions, "sleep")
    end
  end
end

function qpu:swap()
  add(self.actions, "x")

  for _s = 1, 30 + flr(rnd(10)) do
    add(self.actions, "sleep")
  end
end

function qpu:reset_actions()
  self.left = false
  self.right = false
  self.up = false
  self.down = false
  self.x = false
  self.o = false
end

return qpu
