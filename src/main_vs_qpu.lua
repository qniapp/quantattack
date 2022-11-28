local flow = require("lib/flow")
local vs_qpu = require("vs_qpu/vs_qpu")

function _init()
  flow:add_gamestate(vs_qpu())
  flow:query_gamestate_type(":vs_qpu")
end

function _update60()
  flow:update()
end

function _draw()
  cls()
  flow:render()
end
