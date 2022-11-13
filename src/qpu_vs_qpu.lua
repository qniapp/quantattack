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
  game_start_time = t()

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
  if qpu1_board:is_game_over() or qpu2_board:is_game_over() then
    if qpu1_board.lose then
      qpu2_board.win = true
    end
    if qpu2_board.lose then
      qpu1_board.win = true
    end

    if not game_over_time then
      game_over_time = t()
    else
      if t() - game_over_time > 2 then
        qpu1_board.push_any_key = true
        qpu2_board.push_any_key = true
        if btn(4) or btn(5) then -- x または z でタイトルへ戻る
          load('qitaev_title')
        end
      end
    end
  end

  game:update()

  -- QPU vs QPU モード独自の update

  if not game_over_time then -- ゲームオーバー後は経過時間を更新しない
    elapsed_time = t() - game_start_time
  end
end

-- 画面の描画
function qpu_vs_qpu:render()
  game:render()

  -- QPU vs QPU モード独自の描画

  -- 経過時間の表示

  cursor(57, 106)
  print("time")

  cursor(55, 114)
  print(maybe_fill_zero_less_than_10(flr(elapsed_time / 60)) .. -- min
    ":" ..
    maybe_fill_zero_less_than_10(flr(elapsed_time) % 60)) -- sec
end

return qpu_vs_qpu
