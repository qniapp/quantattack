-- must require at main top, to be used in any required modules from here
require("engine/pico8/api")

local app_mission = require("app/mission")
local app = app_mission()

function _init()
  app.initial_gamestate = ':mission'
  app:start()
end

function _update60()
  app:update()
end

function _draw()
  app:draw()
end
