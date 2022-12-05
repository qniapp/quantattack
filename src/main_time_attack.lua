local flow = require("lib/flow")
local time_attack = require("time_attack/time_attack")

function _init()
  flow:add_gamestate(time_attack())
  flow:query_gamestate_type(":time_attack")
end

function _update60()
  flow:update()
end

function _draw()
  cls()
  flow:render()
end
