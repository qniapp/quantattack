require("app/endless")

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
