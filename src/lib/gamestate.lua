--[[
Abstract base class for gamestates

Derive your class from it, define type and implement
  callbacks to make your own gamestate for the flow.

Static attributes
  type       string   type name used for transition queries

Instance external references
  app        gameapp  game app instance
                        It will be set in gameapp:register_gamestates.

Methods
  on_enter   ()       enter callback
  on_exit    ()       exit callback
  update     ()       update callback
  render     ()       render callback
--]]

local gamestate = new_class()

gamestate.type = ':undefined'

function gamestate:_init()
  self.app = nil
end

function gamestate:on_enter()
end

function gamestate:on_exit()
end

function gamestate:update()
end

function gamestate:render()
end

return gamestate
