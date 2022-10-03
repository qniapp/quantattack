require("engine/core/class")

local board_class = require("board")
local player_cursor = require("player_cursor")

local game = new_class()

function game:_init()
  local board = board_class:new()
  self.button = {
    left = 0,
    right = 1,
    up = 2,
    down = 3,
    x = 4,
    o = 5,
  }
  self.board = board
  self.player_cursor = player_cursor(board.cols, board.rows)
end

function game:update()
  local cursor = self.player_cursor

  if btnp(self.button.left) then
    sfx(0)
    cursor:move_left()
  end
  if btnp(self.button.right) then
    sfx(0)
    cursor:move_right()
  end
  if btnp(self.button.up) then
    sfx(0)
    cursor:move_up()
  end
  if btnp(self.button.down) then
    sfx(0)
    cursor:move_down()
  end
  if btnp(self.button.x) then
    local swapped = self.board:swap(cursor.x, cursor.x + 1, cursor.y)
    -- if swapped == false then
    --   self.player_cursor.cannot_swap = true
    -- end

    if swapped then
      sfx(2)
    end
  end
  if btnp(self.button.o) then
    self.board:put_garbage()
  end

  self.board:update()
  cursor:update()
end

function game:draw()
  cls()
  self.board:draw()
  self.player_cursor:draw(self.board)
end

return game
