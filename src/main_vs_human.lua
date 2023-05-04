require("lib/helpers")
require("lib/board")
require("lib/player")
require("lib/game")

local game, board0, board1 =
game_class(), board_class(cursor_class(), 3), board_class(cursor_class(), 78)

board0.block_offset_target, board1.block_offset_target, board0.attack_ion_target, board1.attack_ion_target =
{ 27, 9 }, { 102, 9 }, { 102, 9 }, { 27, 9 }

game:add_player(player_class(0), board0, board1)
game:add_player(player_class(1), board1, board0)

function _init()
  game:init()
end

function _update60()
  game:update()

  if game:is_game_over() and t() - game.game_over_time > 2 then
    board0.show_gameover_menu = true
    board1.show_gameover_menu = true
    if btnp(5, 0) or btnp(5, 1) then -- x でリプレイ
      sfx(15)
      _init()
    elseif btnp(4, 0) or btnp(4, 1) then -- c でタイトルへ戻る
      jump('quantattack_title')
    end
  end
end

function _draw()
  cls()

  game:render()

  print_outlined(unpack_split("time,57,106,7,0"))
  print_outlined(game:elapsed_time_string(), unpack_split("55,114,7,0"))
end
