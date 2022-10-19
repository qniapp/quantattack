-- main entry file that uses the gameapp module for a quick bootstrap
-- the gameapp is also useful for integration tests

-- we must require engine/pico8/api at the top of our main.lua, so API bridges apply to all modules
require("engine/pico8/api")

local app_class = require("app")

--#if log
local logging = require("engine/debug/logging")
--#endif

local app = app_class()

function _init()
  --#if log
  -- start logging before app in case we need to read logs about app start itself
  logging.logger:register_stream(logging.console_log_stream)
  logging.logger:register_stream(logging.file_log_stream)
  logging.file_log_stream.file_prefix = "qitaev"

  -- clear log file on new game session (or to preserve the previous log,
  -- you could add a newline and some "[SESSION START]" tag instead)
  logging.file_log_stream:clear()
  --#endif

  app.initial_gamestate = ':title'
  app:start()
end

function _update60()
  app:update()
end

function _draw()
  app:draw()
end
