local gameapp = require("app/gameapp")
local mission = require("mission/mission")

function app_mission()
  local _app = setmetatable({
    _init = function(_ENV)
      gameapp._init(_ENV)
    end,

    instantiate_gamestates = function()
      return { mission() }
    end
  }, { __index = gameapp })

  _app:_init()

  return _app
end
