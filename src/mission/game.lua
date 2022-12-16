---@diagnostic disable: global-in-nil-env, lowercase-global

require("lib/helpers")

local particle = require("lib/particle")
local bubble = require("lib/bubble")
local ripple = require("lib/ripple")

local game = new_class()

function game._init(_ENV)
end

function game.update(_ENV)
  player:update(board)

  if player.left then
    sfx(8)
    cursor:move_left()
  end
  if player.right then
    sfx(8)
    cursor:move_right(board.cols)
  end
  if player.up then
    sfx(8)
    cursor:move_up()
  end
  if player.down then
    sfx(8)
    cursor:move_down(board.rows)
  end
  if player.x and board:swap(cursor.x, cursor.y) then
    sfx(10)
  end

  board:update(_ENV, player)
  cursor:update()

  ripple:update()
  particle:update_all()
  bubble:update_all()
end

function game.render(_ENV)
  board:render()
  particle:render_all()
  bubble:render_all()
end

return game
