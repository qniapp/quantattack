require("mission/dtb")

local player_class = require("lib/player")
local cursor_class = require("lib/cursor")
local board_class = require("lib/board")
local game_class = require("mission/game")
local ion_class = require("mission/ion")

local cursor = cursor_class()
local board, player = board_class(cursor), player_class()
local mission_game = game_class()

local gamestate = require("lib/gamestate")
local mission = derived_class(gamestate)
mission.type = ':mission'

local ripple = require("lib/ripple")
local sash = require("lib/sash")

state = ":play"

function mission_game.reduce_callback(_score, x, y, _player, pattern, dx)
end

local ion
dtb_init()

function _init()
  player:_init()
  board:init()

  cursor:init()

  mission_game.player = player
  mission_game.cursor = cursor
  mission_game.board = board
  mission_game:_init()
end

-- TODO: イオンに show メソッドを追加

-- TODO: イオン登場、ゆれる & sfx
dtb_disp("boom!", function ()
           ion = ion_class()
end)
dtb_disp("hi! my name is ion.")
dtb_disp("let me introduce the rules of this game.")

function _update60()
  mission_game:update()
  sash:update()
  dtb_update()
end

function _draw()
  cls()

  ripple:render()
  mission_game:render()
  sash:render()
  dtb_draw()
  if ion then
    ion:draw()
  end

  spr(99, 70, 119)
  print_outlined("swap blocks", 81, 120, 7, 0)
end
