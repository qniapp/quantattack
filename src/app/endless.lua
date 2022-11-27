require("lib/class")

local gameapp = require("app/gameapp")
local app = derived_class(gameapp)
local endless = require("endless/endless")

function app:_init()
  gameapp._init(self)
end

function app.instantiate_gamestates()
  return { endless() }
end

return app
