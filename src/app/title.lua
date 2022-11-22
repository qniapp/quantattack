require("class")

local gameapp = require("app/gameapp")
local app = derived_class(gameapp)

local title_demo = require("title/title_demo")
local title = require("title/title")

function app:_init()
  gameapp._init(self, 60)
end

function app.instantiate_gamestates()
  return { title_demo(), title() }
end

return app
