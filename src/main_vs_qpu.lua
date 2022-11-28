local vs_qpu = require("vs_qpu/vs_qpu")
local state = vs_qpu()

-- FIXME: vs_qpu の中身をこちらへ移動し、vs_qpu/vs_qpu を消す

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
