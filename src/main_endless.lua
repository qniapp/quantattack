-- must require at main top, to be used in any required modules from here
require("engine/pico8/api")

local app_endless = require("app/endless")
local app = app_endless()

function _init()
  app.initial_gamestate = ':endless'
  app:start()
end

function _update60()
  app:update()
end

function _draw()
  app:draw()
end
