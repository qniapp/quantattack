require("board")
require("player")
require("player_cursor")
require("qpu")

local gamestate = require("engine/application/gamestate")
local vs_qpu = derived_class(gamestate)

local game_class = require("game")
local game = game_class()

local board, qpu_board = create_board(6), create_board(75)
board.attack_cube_target, qpu_board.attack_cube_target = { 78, 15 }, { 48, 15, "left" }
local player_cursor, qpu_cursor = create_player_cursor(board), create_player_cursor(qpu_board)
local player, qpu = create_player(), create_qpu(qpu_cursor)

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
  if board:is_game_over() or qpu_board:is_game_over() then
    if board.lose then
      qpu_board.win = true
    end
    if qpu_board.lose then
      board.win = true
    end

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
