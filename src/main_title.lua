-- we must require engine/pico8/api at the top of our main.lua, so API bridges apply to all modules
require("engine/pico8/api")

local app_class = require("app/title")
local app = app_class()

function _init()
  app.initial_gamestate = ':title'
  app:start()
end

function _update60()
  app:update()
end

function _draw()
  app:draw()
end
