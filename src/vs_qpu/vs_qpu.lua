require("lib/board")
require("lib/player")
require("lib/player_cursor")
require("lib/qpu")

local vs_qpu = new_class()
local game_class = require("lib/game")
local game = game_class()

local board, qpu_board = create_board(3), create_board(78)
board.gate_offset_target, qpu_board.gate_offset_target = { 3 + 24, 0 }, { 78 + 24, 0 }
board.attack_cube_target, qpu_board.attack_cube_target = { 78 + 24, 0 }, { 3 + 24, 0 }
local player_cursor, qpu_cursor = create_player_cursor(board), create_player_cursor(qpu_board)
local player, qpu = create_player(), create_qpu(qpu_cursor, qpu_board)

function vs_qpu:_init()
  -- NOP
end

function vs_qpu:init()
  player:init()
  board:init()
  board:put_random_gates()
  player_cursor:init()

  qpu:init()
  qpu_board:init()
  qpu_board:put_random_gates()
  qpu_cursor:init()

  game:init()
  game:add_player(player, player_cursor, board, qpu_board)
  game:add_player(qpu, qpu_cursor, qpu_board, board)
end

function vs_qpu:update()
  game:update()

  if game:is_game_over() then
    if t() - game.game_over_time > 2 then
      board.show_gameover_menu = true
      if btnp(4) then -- x でリプレイ
        vs_qpu:init()
      elseif btnp(5) then -- z でタイトルへ戻る
        load('qitaev_title')
      end
    end
  end
end

function vs_qpu:render() -- override
  game:render()

  print_outlined("time", 57, 106, 7, 0)
  print_outlined(game:elapsed_time_string(), 55, 114, 7, 0)
end

return vs_qpu
