require("board")
require("player_cursor")
require("qpu")

local gamestate = require("engine/application/gamestate")
local qpu_vs_qpu = derived_class(gamestate)

local game_class = require("game")
local game = game_class()

local qpu1_board = create_board(3)
qpu1_board.attack_cube_target = { 78 + 24, 0 }

local qpu2_board = create_board(78)
qpu2_board.attack_cube_target = { 3 + 24, 0, "left" }

local qpu1_cursor = create_player_cursor(qpu1_board)
local qpu2_cursor = create_player_cursor(qpu2_board)

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
  game:update()

  if game:is_game_over() then
    if t() - game.game_over_time > 2 then
      qpu1_board.push_any_key = true
      qpu2_board.push_any_key = true
      if btnp(4) or btnp(5) then -- x または z でタイトルへ戻る
        load('qitaev_title')
      end
    end
  end
end

-- 画面の描画
function qpu_vs_qpu:render()
  game:render()

  -- 経過時間の表示
  cursor(57, 106)
  print("time")

  cursor(55, 114)
  print(game:elapsed_time_string())
end

return qpu_vs_qpu
