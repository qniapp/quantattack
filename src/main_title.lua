---@diagnostic disable: lowercase-global
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

-- state = ":demo"
state = ":logo_slidein"
local tick = 0

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
end

function _update60()
  if state == ":logo_slidein" then
    -- NOP
  elseif state == ":board_fadein" then
    demo_game:update()
  elseif state == ":demo" then
    demo_game:update()
    update_title_logo_bounce()

    if btnp(4) or btnp(5) then -- x または z でタイトルへ進む
      sfx(15)
      state = ":menu"
    end
  else
    menu:update()
  end

  tick = tick + 1
end

function _draw()
  cls()

  render_plasma()

  if state == ":logo_slidein" then
    sspr(0, 64, 128, 16, 0, tick)

    if tick > 24 then
      state = ":board_fadein"
    end
  elseif state == ":board_fadein" then
    sspr(0, 64, 128, 16, 0, 24)

    if tick <= 90 then
      fadein((tick - 26) / 3)
    end
    demo_game:render()
    pal()

    if tick > 90 then
      state = ":demo"
    end
  elseif state == ":demo" then
    sspr(0, 64, 128, 16, 0, 24 + title_logo_bounce_screen_dy)

    demo_game:render()

    -- Z/X start を表示
    if tick % 60 < 30 then
      print_outlined("z+x start", 50, 50, 1)
    end
  else
    sspr(0, 64, 128, 16, 0, 24 + title_logo_bounce_screen_dy)

    demo_game:render()

    -- メニューのウィンドウを表示
    draw_rounded_box(7, 46, 118, 105, 0, 0) -- ふちどり
    draw_rounded_box(8, 47, 117, 104, 12, 12) -- 枠線
    draw_rounded_box(10, 49, 115, 102, 1, 1) -- 本体

    -- メニューを表示
    menu:draw(15, 72)
  end
end

local fadetable = {
  "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
  "1,1,129,129,129,129,129,129,129,129,0,0,0,0,0",
  "2,2,2,130,130,130,130,130,128,128,128,128,128,0,0",
  "3,3,3,131,131,131,131,129,129,129,129,129,0,0,0",
  "4,4,132,132,132,132,132,132,130,128,128,128,128,0,0",
  "5,5,133,133,133,133,130,130,128,128,128,128,128,0,0",
  "6,6,134,13,13,13,141,5,5,5,133,130,128,128,0",
  "7,6,6,6,134,134,134,134,5,5,5,133,130,128,0",
  "8,8,136,136,136,136,132,132,132,130,128,128,128,128,0",
  "9,9,9,4,4,4,4,132,132,132,128,128,128,128,0",
  "10,10,138,138,138,4,4,4,132,132,133,128,128,128,0",
  "11,139,139,139,139,3,3,3,3,129,129,129,0,0,0",
  "12,12,12,140,140,140,140,131,131,131,1,129,129,129,0",
  "13,13,141,141,5,5,5,133,133,130,129,129,128,128,0",
  "14,14,14,134,134,141,141,2,2,133,130,130,128,128,0",
  "15,143,143,134,134,134,134,5,5,5,133,133,128,128,0"
}

function fadein(i)
  local index = flr(15 - i)
  printh("fadein " .. index)

  for c = 0, 15 do
    if index < 1 then
      pal(c, c)
    else
      pal(c, split(fadetable[c + 1])[index])
    end
  end
end
