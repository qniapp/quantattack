require("engine/application/constants")
require("engine/core/class")

local gameapp = require("engine/application/gameapp")
local app = derived_class(gameapp)

local title = require("title")
local solo = require("solo")
local vs = require("vs")
local qpu_vs_qpu = require("qpu_vs_qpu")

function app:_init()
  gameapp._init(self, fps60)
end

function app.instantiate_gamestates()
  return { title(), solo(), vs(), qpu_vs_qpu() }
end

return app
