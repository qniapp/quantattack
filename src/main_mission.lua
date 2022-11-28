local flow = require("lib/flow")
local mission = require("mission/mission")

function _init()
  flow:add_gamestate(mission())
  flow:query_gamestate_type(":mission")
end

function _update60()
  flow:update()
end

function _draw()
  cls()
  flow:render()
end
