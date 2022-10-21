local player_cursor = new_class()

function player_cursor:move_left()
  if self.x > 1 then
    self.x = self.x - 1
  end
end

function player_cursor:move_right()
  if self.x < self._board.cols - 1 then
    self.x = self.x + 1
  end
end

function player_cursor:move_up()
  if self.y > 1 then
    self.y = self.y - 1
  end
end

function player_cursor:move_down()
  if self.y < self._board.rows then
    self.y = self.y + 1
  end
end

function player_cursor:update()
  self._tick = (self._tick + 1) % 28
end

function player_cursor:render()
  local x, y = self._board:screen_x(self.x), self._board:screen_y(self.y)

  if self._tick >= 14 then
    sspr(16, 32, 19, 11, x - 2, y - 2)
  else
    sspr(16, 48, 21, 13, x - 3, y - 3)
  end
end

function player_cursor:_init(board)
  self._board = board
  self:init()
end

function player_cursor:init()
  self.x, self.y, self._tick = 3, 6, 0
end

return player_cursor
