require("lib/class")

local gameapp = require("app/gameapp")
local app = derived_class(gameapp)
local vs_qpu = require("vs_qpu/vs_qpu")

function app:_init()
  gameapp._init(self)
end

function app.instantiate_gamestates()
  return { vs_qpu() }
end

return app
