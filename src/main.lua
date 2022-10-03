-- main entry file that uses the gameapp module for a quick bootstrap
-- the gameapp is also useful for integration tests

-- we must require engine/pico8/api at the top of our main.lua, so API bridges apply to all modules
require("engine/pico8/api")

local game_class = require("game")
local game

function _init()
  game = game_class()
  game.board:initialize_with_random_gates()
end

function _update60()
  game:update()
end

function _draw()
  game:draw()
end
