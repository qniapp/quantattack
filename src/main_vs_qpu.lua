local vs_qpu = require("vs_qpu/vs_qpu")
local state = vs_qpu()

function _init()
  state:init()
end

function _update60()
  state:update()
end

function _draw()
  cls()
  state:render()
end
