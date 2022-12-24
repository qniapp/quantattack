require("lib/cursor")
require("lib/qpu")
require("lib/game")

local game = game_class()
local board_class = require("lib/board")

local qpu1_cursor, qpu2_cursor = cursor_class(), cursor_class()
local qpu1_board, qpu2_board = board_class(qpu1_cursor, 3), board_class(qpu2_cursor, 78)
qpu1_board.block_offset_target, qpu2_board.block_offset_target = { 3 + 24, 9 }, { 78 + 24, 9 }
qpu1_board.attack_cube_target, qpu2_board.attack_cube_target = { 78 + 24, 9 }, { 3 + 24, 9 }
local qpu1, qpu2 = create_qpu(qpu1_board, 1), create_qpu(qpu2_board, 1)

function _init()
  qpu1:init()
  qpu1_board:init()
  qpu1_board:put_random_blocks()
  qpu1_cursor:init()

  qpu2:init()
  qpu2_board:init()
  qpu2_board:put_random_blocks()
  qpu2_cursor:init()

  game:init()
  game:add_player(qpu1, qpu1_board, qpu2_board)
  game:add_player(qpu2, qpu2_board, qpu1_board)
end

function _update60()
  game:update()

  if game:is_game_over() then
    if t() - game.game_over_time > 2 then
      qpu1_board.show_gameover_menu = true
      qpu2_board.show_gameover_menu = true

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
