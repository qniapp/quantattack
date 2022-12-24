require("lib/cursor")
require("lib/player")
require("lib/qpu")
require("lib/game")
require("lib/board")

local game = game_class()
local qpu_level = stat(6) -- 3: easy, 2: normal, 1: hard

local player_cursor, qpu_cursor = cursor_class(), cursor_class()
local board, qpu_board = board_class(player_cursor, 3), board_class(qpu_cursor, 78)
local player, qpu = player_class(), create_qpu(qpu_board, qpu_level)

board.block_offset_target, qpu_board.block_offset_target = { 3 + 24, 9 }, { 78 + 24, 9 }
board.attack_cube_target, qpu_board.attack_cube_target = { 78 + 24, 9 }, { 3 + 24, 9 }

function _init()
  player:init()
  board:init()
  board:put_random_blocks()
  player_cursor:init()

  qpu:init()
  qpu_board:init()
  qpu_board:put_random_blocks()
  qpu_cursor:init()

  game:init()
  game:add_player(player, board, qpu_board)
  game:add_player(qpu, qpu_board, board)
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
