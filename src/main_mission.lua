require("mission/dtb")

local player_class = require("lib/player")
local cursor_class = require("lib/cursor")
local board_class = require("lib/board")
local game_class = require("mission/game")

local cursor = cursor_class()
local board, player = board_class(cursor), player_class()
local mission_game = game_class()

local gamestate = require("lib/gamestate")
local mission = derived_class(gamestate)
mission.type = ':mission'

local ripple = require("lib/ripple")
local sash = require("lib/sash")

local ion_class = require("mission/ion")
local ion = ion_class()

function mission_game.reduce_callback(_score, x, y, _player, pattern, dx)
end

_main_state = nil
dtb_init()

local show_legends = false

function _init()
  _main_state = ":ion_appear"

  player:_init()
  board:init()

  cursor:init()

  mission_game.player = player
  mission_game.cursor = cursor
  mission_game.board = board
  mission_game:_init()

  ion:appear(function()
    dtb_disp("boom!")
    dtb_disp("hi! my name is ion.", function()
      ion:shake(function()
        dtb_disp("let me introduce the rules of this game.", function()
          mission_game:raise_stack(function()
            _main_state = ":how_to_play"
          end)
        end)
      end)
    end)
  end)
end

function _update60()
  if _main_state == ":how_to_play" then
    dtb_disp("your mission is to clear these blocks so they do not top out.")
    dtb_disp("by swapping blocks with the cursor, two same blocks lined up vertically will be cleared.", function ()
      show_legends = true
    end)
    dtb_disp("so let's try it!", function ()
      _main_state = ":try_h_h"
    end)
    _main_state = ":idle"
  end

  mission_game:update()
  sash:update()
  dtb_update()
  ion:update()
end

function _draw()
  cls()

  ripple:render()
  mission_game:render()
  sash:render()
  dtb_draw()
  ion:draw()

  if show_legends then
    spr(99, 70, 119)
    print_outlined("swap blocks", 81, 120, 7, 0)
  end
end
