local gameapp = require("app/gameapp")
local qpu_vs_qpu = require("qpu_vs_qpu/qpu_vs_qpu")

function app_qpu_vs_qpu()
  local _app = {}
  _app.__index = _app

  setmetatable(_app, {
    __index = gameapp,
  })

  function _app:_init()
    gameapp:_init()
  end

  function _app:instantiate_gamestates()
    return { qpu_vs_qpu() }
  end

  _app:_init()

  return _app
end
