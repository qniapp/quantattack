local flow = require("lib/flow")
local title_demo = require("title/title_demo")
local title_menu = require("title/title_menu")

require("title/game")
demo_game = game()

function _init()
  local qpu_board = create_board(0, 16)
  local qpu_cursor = create_player_cursor(qpu_board)
  local qpu = create_qpu(qpu_cursor, qpu_board)

  qpu:init()
  qpu_board:put_random_gates()
  qpu_cursor:init()

  qpu_board.show_wires = false
  qpu_board.show_top_line = false

  demo_game:init()
  demo_game:add_player(qpu, qpu_cursor, qpu_board)

  flow:add_gamestate(title_demo())
  flow:add_gamestate(title_menu())
  flow:query_gamestate_type(":title_demo")
end

function _update60()
  flow:update()
end

function _draw()
  cls()
  flow:render()
end

-- require("app/title")

-- local app = app_title()

-- function _init()
--   app.initial_gamestate = ':title_demo'
--   app:start()
-- end

-- function _update60()
--   app:update()
-- end

-- function _draw()
--   app:draw()
-- end
