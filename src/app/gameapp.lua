local flow = require("engine/application/flow")
local input = require("engine/input/input")

-- main class for the game, taking care of the overall init, update, render
-- usage: derive from gameapp and override:
--   instantiate_gamestates, on_start, on_reset, on_update, on_render
-- in the main _init, set the initial_gamestate and call the app start()
-- in the main _update(60), call the app update()
-- in the main _draw, call the app render()
-- in integration tests, call the app reset() before starting a new itest
local gameapp = new_class()

-- components
--   managers           manager                  table of managers to update and render in the loop,
--                                                 indexed by manager type
-- parameters
--   fps                int                      target fps (fps30 or fps60). set them in derived app
--                                                 when calling base constructor
--   delta_time         float                    derived from fps, time per frame in seconds
--   initial_gamestate  string|nil               key of the initial first gamestate to enter (nil if unset)
--                                               set it manually before calling start(),
--                                                 and make sure you called register_gamestates with a matching state
function gameapp:_init(fps)
  self.managers = {}
  self.fps = fps
  self.delta_time = 1 / fps
  self.initial_gamestate = nil
end

-- Return a sequence of newly instantiated managers
-- You must override this in order to have your managers instantiated and registered on start
-- They may be managers provided by the engine or custom managers.
-- In this engine, we prefer injection to having a configuration with many flags
--   to enable/disable certain managers.
-- We can still override on_update/on_render on the game app directly for custom effects,
--   but prefer handling them in managers when possible. Note that update and render
--   order will follow the strict order in which the managers have been registered,
--   and that managers will always update before the gamestate, but render after the gamestate.
-- Call this in your derived gameapp with all the managers you need during the game.
-- You can then access the manager from any gamestate with self.app.managers[':type']
function gameapp:instantiate_managers()
  -- override ex:
  -- return {my_manager1(), my_manager2(), my_manager3()}
  return {}
end

-- Register the managers you want to update and render, providing backward ref to app
function gameapp:register_managers(managers)
  for manager in all(managers) do
    manager.app = self
    self.managers[manager.type] = manager
  end
end

function gameapp:instantiate_and_register_managers()
  self:register_managers(self:instantiate_managers())
end

-- Return a sequence of newly instantiated gamestates
-- This is preferred to passing gamestate references directly
--   to avoid two apps sharing the same gamestates
-- You must override this in order to have your gamestates instantiated and registered on start
function gameapp:instantiate_gamestates()
  -- override ex:
  -- return {my_gamestate1(), my_gamestate2(), my_gamestate3()}
  return {}
end

-- Register gamestats, adding them to flow, providing backward ref to app
function gameapp:register_gamestates(gamestates)
  for state in all(gamestates) do
    state.app = self
    flow:add_gamestate(state)
  end
end

function gameapp:instantiate_and_register_gamestates()
  self:register_gamestates(self:instantiate_gamestates())
end

-- NEXT todo: actually prefer register_managers pattern too as it's easier to recreate all the managers
-- than to implement reset on each of them. So itests are truly independent

-- unlike _init, init_modules is called later, after finishing the configuration
-- in pico-8, it must be called in the global _init function
function gameapp:start()
  self:on_pre_start()

  self:instantiate_and_register_managers()
  self:instantiate_and_register_gamestates()

  -- REFACTOR: consider making flow a very generic manager, that knows the initial gamestate
  -- and is only added if you want (but mind the start/update/render order)
  assert(self.initial_gamestate ~= nil, "gameapp:start: gameapp.initial_gamestate is not set")
  flow:query_gamestate_type(self.initial_gamestate)
  for _, manager in pairs(self.managers) do
    manager:start()
  end

  self:on_post_start()
end

-- override to initialize custom managers
function gameapp:on_pre_start() -- virtual
end

-- override to initialize custom managers
function gameapp:on_post_start() -- virtual
end

--#if itest
function gameapp:reset()
  -- clear input (important to avoid "sticky" keys if we switch to another itest just
  --   while some keys are simulated down)
  input:init()

  -- clear flow (this will remove any added gamestate, which can then be re-added in start > register_gamestates)
  flow:init()

  self:on_reset()
end

-- override to call :init on your custom managers, or to reset anything set up in
-- in gameapp:start/on_start, really
function gameapp:on_reset() -- virtual
end
--#endif

function gameapp:update()
  input:process_players_inputs()

  for _, manager in pairs(self.managers) do
    if manager.active then
      manager:update()
    end
  end

  flow:update()

  self:on_update()
end

-- override to add custom update behavior
function gameapp:on_update() -- virtual
end

function gameapp:draw()
  cls()

  flow:render()

  -- managers tend to draw stuff on top of the rest, so render after flow (i.e. gamestate)
  for _, manager in pairs(self.managers) do
    if manager.active then
      manager:render()
    end
  end

  -- we don't have a layered rendering system, so to support overlays
  -- on top of any manager drawing, we just add a render_post
  flow:render_post()

  self:on_render()
end

-- override to add custom render behavior
function gameapp:on_render() -- virtual
end
