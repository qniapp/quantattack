require("engine/core/class")

local gameapp = require("engine/application/gameapp")
local app = derived_class(gameapp)
local solo = require("solo")

function app:_init()
  gameapp._init(self, 60)
end

function app.instantiate_gamestates()
  return { solo() }
end

return app
