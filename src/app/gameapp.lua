local flow = require("engine/application/flow")

local gameapp = new_class()

function gameapp:_init(fps)
  self.initial_gamestate = nil
end

function gameapp:instantiate_gamestates()
  return {}
end

function gameapp:start()
  self:on_pre_start()

  -- register gamestates
  for state in all(self:instantiate_gamestates()) do
    state.app = self
    flow:add_gamestate(state)
  end
  --#if assert
  assert(self.initial_gamestate ~= nil, "gameapp:start: gameapp.initial_gamestate is not set")
  --#endif
  flow:query_gamestate_type(self.initial_gamestate)

  self:on_post_start()
end

function gameapp:update()
  -- input:process_players_inputs()
  flow:update()

  self:on_update()
end

function gameapp:draw()
  cls()
  flow:render()
  flow:render_post()

  self:on_render()
end

function gameapp:on_pre_start() -- virtual
end

function gameapp:on_post_start() -- virtual
end

function gameapp:on_update() -- virtual
end

function gameapp:on_render() -- virtual
end

return gameapp
