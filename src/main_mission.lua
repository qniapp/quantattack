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

local _wait_sec, _wait_callback

function wait(wait_sec, callback)
  _main_state = ":wait"
  _time_wait_start = t()
  _wait_sec = wait_sec
  _wait_callback = callback
end

function mission_game.reduce_callback(_score, x, y, _player, pattern, dx)
  wait(2, function()
    dtb_disp("awesome!")
    _main_state = _next_state_after_clear
  end)
end

_main_state = nil
dtb_init()

local show_legends = false

local board_data_h = {
  { "placeholder", "placeholder", "h", "i", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "h", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" }
}

local board_data_x = {
  { "x", "i", "i", "i", "i", "i" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "x", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" }
}

local board_data_cnot = {
  { "cnot_x,5", "i", "i", "i", "control,1", "i" },
  { "i", "control,3", "cnot_x,2", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" }
}

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
          mission_game:raise_stack(board_data_h, function()
            _main_state = ":how_to_play"
            _next_state_after_clear = ":try_xx"
          end)
        end)
      end)
    end)
  end)
end

function _update60()
  if _main_state == ":how_to_play" then
    dtb_disp("your mission is to clear these blocks so they do not top out.")
    dtb_disp("first, let's clear the two h blocks.")
    dtb_disp("try to line up these two h blocks vertically by swapping the blocks.", function()
      _main_state = ":try_h_h"
      show_legends = true
      mission_game.move_cursor = true
    end)
    _main_state = ":idle"
  elseif _main_state == ":wait" then
    if _wait_sec < t() - _time_wait_start then
      _wait_callback()
    end
  elseif _main_state == ":try_xx" then
    dtb_disp("how about this then?", function()
      mission_game:raise_stack(board_data_x)
      _next_state_after_clear = ":try_cnot_cnot"
    end)
    _main_state = ":idle"
  elseif _main_state == ":try_cnot_cnot" then
    dtb_disp("some of the blocks are a bit odd.")
    dtb_disp("this is two connected blocks, and they're not easy to clear.", function()
      mission_game:raise_stack(board_data_cnot)
      _next_state_after_clear = ":hoge"
    end)
    -- dtb_disp("how about this then?", function()
    --   mission_game:raise_stack(board_data_xx)
    --   _next_state_after_clear = ":hoge"
    -- end)
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
