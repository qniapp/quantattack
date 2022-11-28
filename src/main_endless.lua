local flow = require("lib/flow")
local endless = require("endless/endless")

function _init()
  flow:add_gamestate(endless())
  flow:query_gamestate_type(":endless")
end

function _update60()
  flow:update()
end

function _draw()
  cls()
  flow:render()
end
