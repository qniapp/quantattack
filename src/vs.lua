require("engine/core/class")

local flow = require("engine/application/flow")

local gamestate = require("engine/application/gamestate")
local vs = derived_class(gamestate)

local game_class = require("game")
local game = game_class()

local player_class = require("player")
local qpu_class = require("qpu")
local board_class = require("board")
local player_cursor_class = require("player_cursor")

local board = board_class(3)
local qpu_board = board_class(78)

local player_cursor = player_cursor_class(board)
local qpu_cursor = player_cursor_class(qpu_board)

local player = player_class()
local qpu = qpu_class(qpu_cursor)

vs.type = ':vs'

function vs:on_enter()
  player:init()
  board:initialize_with_random_gates()
  player_cursor:init()

  qpu:init()
  qpu_board:initialize_with_random_gates()
  qpu_cursor:init()

  game:init()
  game:add_player(player, board, player_cursor)
  game:add_player(qpu, qpu_board, qpu_cursor)
end

function vs:update()
  if board:is_game_over() then
    board.win = false
    qpu_board.win = true
  elseif qpu_board:is_game_over() then
    board.win = true
    qpu_board.win = false
  end

  if board:is_game_over() or qpu_board:is_game_over() then
    if btnp(5) then
      flow:query_gamestate_type(':title')
    end
  end

  game:update()
end

function vs:render() -- override
  game:render()
end

return vs
