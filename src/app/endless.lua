local gameapp = require("app/gameapp")
local endless = require("endless/endless")

function app_endless()
  local _app = {}
  _app.__index = _app

  setmetatable(_app, {
    __index = gameapp,
  })

  function _app:_init()
    gameapp:_init()
  end

  function _app:instantiate_gamestates()
    return { endless() }
  end

  _app:_init()

  return _app
end
