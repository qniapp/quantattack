local flow = require("lib/flow")
local rush = require("rush/rush")

function _init()
  flow:add_gamestate(rush())
  flow:query_gamestate_type(":rush")
end

function _update60()
  flow:update()
end

function _draw()
  cls()
  flow:render()
end
