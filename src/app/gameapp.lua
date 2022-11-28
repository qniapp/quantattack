require("lib/helpers")

local flow, gameapp = require("lib/flow"), new_class()

function gameapp:_init()
  self.initial_gamestate = nil
end

function gameapp:instantiate_gamestates()
  return {}
end

function gameapp:start()
  -- register gamestates
  for state in all(self:instantiate_gamestates()) do
    state.app = self
    flow:add_gamestate(state)
  end
  --#if assert
  assert(self.initial_gamestate ~= nil, "gameapp:start: gameapp.initial_gamestate is not set")
  --#endif
  flow:query_gamestate_type(self.initial_gamestate)
end

function gameapp:update()
  flow:update()

  self:on_update()
end

function gameapp:draw()
  cls()
  flow:render()

  self:on_render()
end

function gameapp:on_update() -- virtual
end

function gameapp:on_render() -- virtual
end

return gameapp
