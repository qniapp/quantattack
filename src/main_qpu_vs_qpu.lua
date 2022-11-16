-- must require at main top, to be used in any required modules from here
require("engine/pico8/api")

local app_qpu_vs_qpu = require("app/qpu_vs_qpu")
local app = app_qpu_vs_qpu()

function _init()
  app.initial_gamestate = ':qpu_vs_qpu'
  app:start()
end

function _update60()
  app:update()
end

function _draw()
  app:draw()
end
