require("board")
require("player")
require("player_cursor")
require("qpu")

local flow = require("engine/application/flow")

local gamestate = require("engine/application/gamestate")
local vs_qpu = derived_class(gamestate)

local game_class = require("game")
local game = game_class()

local board = create_board(3)
board.attack_cube_target = { 78, 15 }

local qpu_board = create_board(78)
qpu_board.attack_cube_target = { 48, 15, "left" }

local player_cursor = create_player_cursor(board)
local qpu_cursor = create_player_cursor(qpu_board)

local player = create_player()
local qpu = create_qpu(qpu_cursor)

vs_qpu.type = ':vs_qpu'

function vs_qpu:on_enter()
  player:init()
  board:initialize_with_random_gates()
  player_cursor:init()

  qpu:init()
  qpu_board:initialize_with_random_gates()
  qpu_cursor:init()

  game:init()
  game:add_player(player, player_cursor, board, qpu_board)
  game:add_player(qpu, qpu_cursor, qpu_board, board)
end

function vs_qpu:update()
  if board:is_game_over() and board.win == nil then
    board.win = false
    qpu_board.win = true
  elseif qpu_board:is_game_over() and qpu_board.win == nil then
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

function vs_qpu:render() -- override
  game:render()
end

return vs_qpu
