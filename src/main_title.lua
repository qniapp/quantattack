---@diagnostic disable: lowercase-global
require("lib/qpu")
require("title/plasma")
require("title/game")

demo_game = game()

local cursor_class = require("lib/cursor")

-- ハイスコア
local high_score = require("lib/high_score")

-- メニュー
local menu_item = require("title/menu_item")
local menu_class = require("title/menu")

local main_menu = menu_class({
  menu_item("mission", 'clear 9 waves', 32, 48, 16, 16, 'quantattack_mission'),
  menu_item("time attack", 'play for 2 minutes', 48, 48, 16, 16, 'quantattack_time_attack', high_score(0):get() * 10),
  menu_item("endless", 'play as long as you can', 64, 48, 16, 16, 'quantattack_endless', high_score(1):get() * 10),
  menu_item("vs qpu", 'defeat the qpu', 80, 48, 16, 16, function() title_state = ":level_menu" end),
  menu_item("qpu vs qpu", 'watch qpu vs qpu', 96, 48, 16, 16, 'quantattack_qpu_vs_qpu')
}, ":demo")
local level_menu = menu_class({
  menu_item(nil, nil, 48, 80, 19, 7, 'quantattack_vs_qpu', nil, 3), -- easy
  menu_item(nil, nil, 72, 80, 27, 7, 'quantattack_vs_qpu', nil, 2), -- normal
  menu_item(nil, nil, 104, 80, 19, 7, 'quantattack_vs_qpu', nil, 1), -- hard
}, ":main_menu")

-- :logo_slidein QuantumAttack のロゴ slide-in アニメーション
-- :board_fadein ボードの fade-in アニメーション
-- :demo デモプレイ
-- :main_menu メニューを表示した状態
-- :level_menu QPU のレベル選択
title_state = ":logo_slidein"

local tick = 0

local board_class = require("lib/board")

function _init()
  local qpu_cursor = cursor_class()
  local qpu_board = board_class(qpu_cursor, 0, 16)
  local qpu = create_qpu(qpu_cursor, qpu_board, 2)

  qpu:init()
  qpu_board:put_random_gates()

  qpu_board.show_wires = false
  qpu_board.show_top_line = false

  demo_game:init()
  demo_game:add_player(qpu, qpu_board)
end

function _update60()
  if title_state == ":logo_slidein" then
    -- NOP
  elseif title_state == ":board_fadein" then
    demo_game:update()
  elseif title_state == ":demo" then
    demo_game:update()
    update_title_logo_bounce()

    if btnp(4) or btnp(5) then -- x または c でタイトルへ進む
      sfx(15)
      title_state = ":main_menu"
    end
  elseif title_state == ":main_menu" then
    main_menu.stale = false
    main_menu:update()
  elseif title_state == ":level_menu" then
    level_menu:update()
  end

  tick = tick + 1
end

function _draw()
  cls()

  render_plasma()

  if title_state == ":logo_slidein" then
    sspr(0, 64, 128, 16, 0, tick)

    if tick > 24 then
      title_state = ":board_fadein"
    end
  elseif title_state == ":board_fadein" then
    sspr(0, 64, 128, 16, 0, 24)

    if tick <= 90 then
      fadein((tick - 26) / 3)
    end
    demo_game:render()
    pal()

    if tick > 90 then
      title_state = ":demo"
    end
  else
    sspr(0, 64, 128, 16, 0, 24 + title_logo_bounce_screen_dy)

    demo_game:render()

    if title_state == ":demo" then
      -- Z+X start を表示
      if tick % 60 < 30 then
        print_outlined("x+c start", 50, 50, 1)
      end
    else -- ":main_menu" or ":level_menu"
      -- メニューのウィンドウを表示
      draw_rounded_box(7, 46, 118, 108, 0, 0) -- ふちどり
      draw_rounded_box(8, 47, 117, 107, 12, 12) -- 枠線
      draw_rounded_box(10, 49, 115, 105, 1, 1) -- 本体

      -- メニューを表示
      main_menu:draw(15, 72)

      if title_state == ":level_menu" then
        level_menu:draw(27, 93)
      end

      print_outlined("x select  c cancel", 27, 107, 1, 7)
    end
  end
end

local fadetable = "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0|1,1,129,129,129,129,129,129,129,129,0,0,0,0,0|2,2,2,130,130,130,130,130,128,128,128,128,128,0,0|3,3,3,131,131,131,131,129,129,129,129,129,0,0,0|4,4,132,132,132,132,132,132,130,128,128,128,128,0,0|5,5,133,133,133,133,130,130,128,128,128,128,128,0,0|6,6,134,13,13,13,141,5,5,5,133,130,128,128,0|7,6,6,6,134,134,134,134,5,5,5,133,130,128,0|8,8,136,136,136,136,132,132,132,130,128,128,128,128,0|9,9,9,4,4,4,4,132,132,132,128,128,128,128,0|10,10,138,138,138,4,4,4,132,132,133,128,128,128,0|11,139,139,139,139,3,3,3,3,129,129,129,0,0,0|12,12,12,140,140,140,140,131,131,131,1,129,129,129,0|13,13,141,141,5,5,5,133,133,130,129,129,128,128,0|14,14,14,134,134,141,141,2,2,133,130,130,128,128,0|15,143,143,134,134,134,134,5,5,5,133,133,128,128,0"

function fadein(i)
  local index = flr(15 - i)

  for c = 0, 15 do
    if index < 1 then
      pal(c, c)
    else
      pal(c, split(split(fadetable, "|")[c + 1])[index])
    end
  end
end
