require("board")
require("player")
require("player_cursor")
require("qpu")

local gamestate = require("engine/application/gamestate")
local vs_qpu = derived_class(gamestate)

local game_class = require("game")
local game = game_class()

local board, qpu_board = create_board(3), create_board(78)
board.attack_cube_target, qpu_board.attack_cube_target = { 78 + 24, 0 }, { 3 + 24, 0, "left" }
local player_cursor, qpu_cursor = create_player_cursor(board), create_player_cursor(qpu_board)
local player, qpu = create_player(), create_qpu(qpu_cursor, qpu_board)

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
  game:update()

  if game:is_game_over() then
    if t() - game.game_over_time > 2 then
      board.push_any_key = true
      if btnp(4) or btnp(5) then -- x または z でタイトルへ戻る
        load('qitaev_title')
      end
    end
  end
end

function vs_qpu:render() -- override
  game:render()
end

return vs_qpu
