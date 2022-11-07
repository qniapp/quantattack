require("board")
require("player")
require("player_cursor")
require("qpu")

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
  if board:is_game_over() and board.win == false then
    board.lose = true
    qpu_board.win = true
  elseif qpu_board:is_game_over() and qpu_board.win == false then
    board.win = true
    qpu_board.lose = true
  end

  if board:is_game_over() or qpu_board:is_game_over() then
    if not game_over_time then
      game_over_time = time()
    else
      if time() - game_over_time > 2 then
        board.push_any_key = true
        if btn(4) or btn(5) then -- x または z でタイトルへ戻る
          load('qitaev_title')
        end
      end
    end
  end

  game:update()
end

function vs_qpu:render() -- override
  game:render()
end

return vs_qpu
