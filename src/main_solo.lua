-- must require at main top, to be used in any required modules from here
require("engine/pico8/api")

local app_solo = require("app/solo")
local app = app_solo()

function _init()
  app.initial_gamestate = ':solo'
  app:start()
end

function _update60()
  app:update()
end

function _draw()
  app:draw()
end
