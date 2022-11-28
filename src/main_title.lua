require("app/title")

local app = app_title()

function _init()
  app.initial_gamestate = ':title_demo'
  app:start()
end

function _update60()
  app:update()
end

function _draw()
  app:draw()
end
