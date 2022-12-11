require("lib/board")
require("lib/player_cursor")
require("lib/qpu")
require("title/plasma")

-- local title_demo, title_menu =
-- require("title/title_demo"), require("title/title_menu")

require("title/game")
demo_game = game()

-- ハイスコア
local high_score = require("lib/high_score")

-- メニュー
local menu_item = require("title/menu_item")
local menu_class = require("title/menu")
local menu = menu_class({
  menu_item("mission", 'clear 9 waves', 32, 'qitaev_mission'),
  menu_item("time attack", 'play for 2 minutes', 48, 'qitaev_time_attack', high_score(0):get() * 10),
  menu_item("endless", 'play as long as you can', 64, 'qitaev_endless', high_score(1):get() * 10),
  menu_item("vs qpu", 'defeat the qpu', 80, 'qitaev_vs_qpu'),
  menu_item("qpu vs qpu", 'watch qpu vs qpu', 96, 'qitaev_qpu_vs_qpu')
})

state = ":demo"
local tick_start

function _init()
  local qpu_board = create_board(0, 16)
  local qpu_cursor = create_player_cursor(qpu_board)
  local qpu = create_qpu(qpu_cursor, qpu_board)

  qpu:init()
  qpu_board:put_random_gates()
  qpu_cursor:init()

  qpu_board.show_wires = false
  qpu_board.show_top_line = false

  demo_game:init()
  demo_game:add_player(qpu, qpu_cursor, qpu_board)

  tick_start = 0
end

function _update60()
  if state == ":demo" then
    tick_start = (tick_start + 1) % 60

    demo_game:update()
    update_title_logo_bounce()

    if btnp(4) or btnp(5) then -- x または z でタイトルへ進む
      sfx(15)
      state = ":menu"
    end
  else
    menu:update()
  end
end

function _draw()
  cls()

  render_plasma()

  -- ロゴを表示
  -- attack bubble をロゴの上に表示するので、最初に描画
  sspr(0, 64, 128, 16, 0, 24 + title_logo_bounce_screen_dy)

  demo_game:render()

  if state == ":demo" then
    -- Z/X start を表示
    if tick_start < 30 then
      print_outlined("z+x start", 50, 50, 1)
    end
  else
    -- メニューのウィンドウを表示
    draw_rounded_box(7, 46, 118, 105, 0, 0) -- ふちどり
    draw_rounded_box(8, 47, 117, 104, 12, 12) -- 枠線
    draw_rounded_box(10, 49, 115, 102, 1, 1) -- 本体

    -- メニューを表示
    menu:draw(15, 72)
  end
end
