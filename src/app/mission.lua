require("class")

local gameapp = require("app/gameapp")
local app = derived_class(gameapp)
local mission = require("mission")

function app:_init()
  gameapp._init(self, 60)
end

function app.instantiate_gamestates()
  return { mission() }
end

return app
