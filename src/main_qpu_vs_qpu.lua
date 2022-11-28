local flow = require("lib/flow")
local qpu_vs_qpu = require("qpu_vs_qpu/qpu_vs_qpu")

function _init()
  flow:add_gamestate(qpu_vs_qpu())
  flow:query_gamestate_type(":qpu_vs_qpu")
end

function _update60()
  flow:update()
end

function _draw()
  cls()
  flow:render()
end
