-- main entry file that uses the gameapp module for a quick bootstrap
-- the gameapp is also useful for integration tests

-- we must require engine/pico8/api at the top of our main.lua, so API bridges apply to all modules
require("engine/pico8/api")

local game_class = require("game")

function _init()
   game = game_class:new()
end

function _update60()
  local cursor = game.player_cursor

  if btnp(game.button.left) then
    sfx(0)
    cursor:move_left()
  end
  if btnp(game.button.right) then
    sfx(0)
    cursor:move_right()
  end
  if btnp(game.button.up) then
    sfx(0)
    cursor:move_up()
  end
  if btnp(game.button.down) then
    sfx(0)
    cursor:move_down()
  end
  if btnp(game.button.x) then
    local swapped = game.board:swap(cursor.x, cursor.x + 1, cursor.y)
    -- if swapped == false then
    --   self.player_cursor.cannot_swap = true
    -- end

    if swapped then
      sfx(2)
    end
  end
  if btnp(game.button.o) then
    game.board:put_garbage()
  end

  game.board:update()
  cursor:update()
end

function _draw()
  cls()
  game.board:draw()
  game.player_cursor:draw(game.board:screen_x(game.player_cursor.x),
                          game.board:screen_y(game.player_cursor.y),
                          game.board:dy())
end
