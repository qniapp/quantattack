-- must require at main top, to be used in any required modules from here
require("engine/pico8/api")

local app_vs_qpu = require("app/vs_qpu")
local app = app_vs_qpu()

function _init()
  app.initial_gamestate = ':vs_qpu'
  app:start()
end

function _update60()
  app:update()
end

function _draw()
  app:draw()
end
