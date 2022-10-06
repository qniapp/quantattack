require("engine/application/constants")
require("engine/core/class")

local gameapp = require("engine/application/gameapp")
local board_class = require("board")
local player_cursor_class = require("player_cursor")
local puff_particle = require("puff_particle")
local colors = require("colors")

local game = derived_class(gameapp)
local board = board_class()
local player_cursor = player_cursor_class(board.cols, board.rows)
local solo = require("solo")

game.button = {
  left = 0,
  right = 1,
  up = 2,
  down = 3,
  x = 4,
  o = 5,
}

function game:_init()
  gameapp._init(self, fps60)
end

function game.instantiate_gamestates() -- override
  return { solo() }
end

function game.on_post_start() -- override
  board:initialize_with_random_gates()
end

function game:on_update() -- override
  if btnp(game.button.left) then
    sfx(0)
    player_cursor:move_left()
  end
  if btnp(game.button.right) then
    sfx(0)
    player_cursor:move_right()
  end
  if btnp(game.button.up) then
    sfx(0)
    player_cursor:move_up()
  end
  if btnp(game.button.down) then
    sfx(0)
    player_cursor:move_down()
  end
  if btnp(game.button.x) then
    local swapped = board:swap(player_cursor.x, player_cursor.x + 1, player_cursor.y)
    -- if swapped == false then
    --   player_cursor.cannot_swap = true
    -- end

    if swapped then
      sfx(2)
    end
  end
  if btnp(game.button.o) then
    board:put_garbage()
  end

  board:update()
  self:_create_gate_puff_particles()
  player_cursor:update()
  puff_particle:update()
end

function game:on_render() -- override
  cls()
  board:render()
  player_cursor:render(board)
  puff_particle:render()
end

function game:_create_gate_puff_particles()
  foreach(board:gates_to_puff(), function(each)
    local x = board:screen_x(each.x) + 3
    local y = board:screen_y(each.y) + 3

    puff_particle(x, y, 3)
    puff_particle(x, y, 3)
    puff_particle(x, y, 2)
    puff_particle(x, y, 2)
    puff_particle(x, y, 2)
    puff_particle(x, y, 2)
    puff_particle(x, y, 2)
    puff_particle(x, y, 2, colors.light_grey)
    puff_particle(x, y, 1)
    puff_particle(x, y, 1)
    puff_particle(x, y, 1, colors.light_grey)
    puff_particle(x, y, 1, colors.light_grey)
    puff_particle(x, y, 0, colors.dark_purple)

    -- sfx(self.sfx.puff)
  end)
end

return game
