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

function game:draw()
  cls()
  self.board:draw()
  self.player_cursor:draw(self.board)
end

return game
