local gameapp = require("app/gameapp")
local title_demo = require("title/title_demo")
local title_menu = require("title/title_menu")

require("title/game")
demo_game = game()

function app_title()
  local _app = {}
  _app.__index = _app

  setmetatable(_app, {
    __index = gameapp,
  })

  function _app:_init()
    local qpu_board = create_board(0, 16)
    local qpu_cursor = create_player_cursor(qpu_board)
    local qpu = create_qpu(qpu_cursor, qpu_board)

    gameapp:_init()

    qpu:init()
    qpu_board:put_random_gates()
    qpu_cursor:init()

    qpu_board.show_wires = false
    qpu_board.show_top_line = false

    demo_game:init()
    demo_game:add_player(qpu, qpu_cursor, qpu_board)
  end

  function _app:instantiate_gamestates()
    return { title_demo(), title_menu() }
  end

  _app:_init()

  return _app
end
