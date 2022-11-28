require("app/vs_qpu")

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
