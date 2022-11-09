require("engine/core/class")

local gameapp = require("app/gameapp")
local app = derived_class(gameapp)

local title = require("title")

function app:_init()
  gameapp._init(self, 60)
end

function app.instantiate_gamestates()
  return { title() }
end

return app
