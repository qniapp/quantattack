local board_class = require("board")
local player_cursor = require("player_cursor")

game = {
  new = function(_self)
    local board = board_class:new()
    return {
      button = {
        left = 0,
        right = 1,
        up = 2,
        down = 3,
        x = 4,
        o = 5,
      },
      board = board,
      player_cursor = player_cursor(board.cols, board.rows)
    }
  end,
}

return game
