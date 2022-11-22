require("class")

local gameapp = require("app/gameapp")
local app = derived_class(gameapp)

local title_demo = require("title/title_demo")
local title = require("title/title")

local game_class = require("title/game")
demo_game = game_class()

local qpu_board = create_board(0, 16)
local qpu_cursor = create_player_cursor(qpu_board)
local qpu = create_qpu(qpu_cursor, qpu_board)

function app:_init()
  gameapp._init(self, 60)

  qpu:init()
  qpu_board:put_random_gates()
  qpu_cursor:init()

  qpu_board.show_top_line = false

  demo_game:init()
  demo_game:add_player(qpu, qpu_cursor, qpu_board)
end

function app.instantiate_gamestates()
  return { title_demo(), title() }
end

return app
