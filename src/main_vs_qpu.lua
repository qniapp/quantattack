require("lib/board")
require("lib/qpu")

local game_class = require("lib/game")
local game = game_class()
local qpu_level = stat(6) -- 3: easy, 2: normal, 1: hard

local player_class = require("lib/player")
local player_cursor_class = require("lib/player_cursor")

local board, qpu_board = create_board(3), create_board(78)
board.gate_offset_target, qpu_board.gate_offset_target = { 3 + 24, 0 }, { 78 + 24, 0 }
board.attack_cube_target, qpu_board.attack_cube_target = { 78 + 24, 0 }, { 3 + 24, 0 }
local player_cursor, qpu_cursor = player_cursor_class(board), player_cursor_class(qpu_board)
local player, qpu = player_class(), create_qpu(qpu_cursor, qpu_board, qpu_level)

function _init()
  player:_init()
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

function _update60()
  game:update()

  if game:is_game_over() then
    if t() - game.game_over_time > 2 then
      board.show_gameover_menu = true
      if btnp(5) then -- x でリプレイ
        _init()
      elseif btnp(4) then -- c でタイトルへ戻る
        jump('quantattack_title')
      end
    end
  end
end

function _draw()
  cls()

  game:render()

  print_outlined("time", 57, 106, 7, 0)
  print_outlined(game:elapsed_time_string(), 55, 114, 7, 0)
end
