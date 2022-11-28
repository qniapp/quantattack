require("app/qpu_vs_qpu")

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
