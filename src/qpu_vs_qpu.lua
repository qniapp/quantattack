require("board")

local flow = require("engine/application/flow")

local gamestate = require("engine/application/gamestate")
local qpu_vs_qpu = derived_class(gamestate)

local game_class = require("game")
local game = game_class()

local qpu1_board = create_board(3)
qpu1_board.attack_cube_target = { 78, 15 }

local qpu2_board = create_board(78)
qpu2_board.attack_cube_target = { 48, 15, "left" }

require("player_cursor")
local qpu1_cursor = create_player_cursor(qpu1_board)
local qpu2_cursor = create_player_cursor(qpu2_board)

require("qpu")
local qpu1 = create_qpu(qpu1_cursor)
local qpu2 = create_qpu(qpu2_cursor)

qpu_vs_qpu.type = ':qpu_vs_qpu'

function qpu_vs_qpu:on_enter()
  qpu1:init()
  qpu1_board:initialize_with_random_gates()
  qpu1_cursor:init()

  qpu2:init()
  qpu2_board:initialize_with_random_gates()
  qpu2_cursor:init()

  game:init()
  game:add_player(qpu1, qpu1_cursor, qpu1_board, qpu2_board)
  game:add_player(qpu2, qpu2_cursor, qpu2_board, qpu1_board)
end

function qpu_vs_qpu:update()
  if qpu1_board:is_game_over() and qpu1_board.win == nil then
    qpu1_board.win = false
    qpu2_board.win = true
  elseif qpu2_board:is_game_over() and qpu2_board.win == nil then
    qpu1_board.win = true
    qpu2_board.win = false
  end

  if qpu1_board:is_game_over() or qpu2_board:is_game_over() then
    if btnp(5) then
      flow:query_gamestate_type(':title')
    end
  end

  game:update()
end

function qpu_vs_qpu:render() -- override
  game:render()
end

return qpu_vs_qpu
