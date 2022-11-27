require("lib/class")

local gameapp = require("app/gameapp")
local app, mission = derived_class(gameapp), require("mission/mission")

function app:_init()
  gameapp._init(self)
end

function app.instantiate_gamestates()
  return { mission() }
end

return app
