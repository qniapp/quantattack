require("engine/application/constants")
require("engine/core/class")

local gameapp = require("engine/application/gameapp")
local game = derived_class(gameapp)

local title = require("title")
local solo = require("solo")

function game:_init()
  gameapp._init(self, fps60)
end

function game.instantiate_gamestates()
  return { title(), solo() }
end

return game
