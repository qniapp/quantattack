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
local show_legends = false

function wait(wait_sec, callback)
  _main_state = ":wait"
  _time_wait_start = t()
  _wait_sec = wait_sec
  _wait_callback = callback
end

function mission_game.reduce_callback(_score, x, y, _player, pattern, dx)
  -- 消えてないブロックが残っていれば、コールバック本体を呼ばない
  for _y = 1, board.rows do
    for _x = 1, board.cols do
      local gate_xy = board.gates[_x][_y]
      if gate_xy:is_idle() and not (gate_xy.type == "i" or gate_xy.type == "placeholder") then
        return
      end
    end
  end

  wait(2, function()
    dtb_disp(({ "awesome!", "great!", "nice!" })[flr(rnd(3)) + 1])
    ion:shake()
    show_legends = false
    mission_game.move_cursor = false
    _main_state = _next_state_after_clear
  end)
end

_main_state = nil
dtb_init()

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

local board_data_xy = {
  { "i", "y", "i", "i", "i", "y" },
  { "placeholder", "placeholder", "x", "i", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "x", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" }
}

local board_data_s = {
  { "s", "s", "i", "i", "i", "s" },
  { "placeholder", "placeholder", "placeholder", "i", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "s", "placeholder", "placeholder" },
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
    ion:shake(function()
      dtb_disp("hi! my name is ion.", function()
        dtb_disp("let me introduce the rules of this game.", function()
          mission_game:raise_stack(board_data_h, function()
            _main_state = ":how_to_play"
            _next_state_after_clear = ":try_xy"
          end)
        end)
      end)
    end)
  end)
end

function _update60()
  if _main_state == ":how_to_play" then
    dtb_disp("your mission is to clear these blocks so they do not top out.")
    dtb_disp("first, let's clear the two red h blocks.")
    dtb_disp("line up these two h blocks vertically by swapping the blocks.", function()
      _main_state = ":try_h_h"
      show_legends = true
      mission_game.move_cursor = true
    end)
    _main_state = ":idle"
  elseif _main_state == ":wait" then
    if _wait_sec < t() - _time_wait_start then
      _wait_callback()
    end
  elseif _main_state == ":try_xy" then
    dtb_disp("how about this then?", function()
      show_legends = true
      mission_game.move_cursor = true
      mission_game:raise_stack(board_data_xy)
      _next_state_after_clear = ":try_s"
    end)
    _main_state = ":idle"
  elseif _main_state == ":try_s" then
    dtb_disp("some blocks change into other blocks!", function()
      show_legends = true
      mission_game.move_cursor = true
      mission_game:raise_stack(board_data_s)
      _next_state_after_clear = ":try_cnot"
    end)
    _main_state = ":idle"
  elseif _main_state == ":try_cnot" then
    dtb_disp("some of the blocks are a bit odd...", function()
      mission_game:raise_stack(board_data_cnot)
      _next_state_after_clear = ":fin"
    end)
    dtb_disp("this is two connected blocks, and they're not easy to clear.")
    dtb_disp("can you clear them?", function()
      show_legends = true
      mission_game.move_cursor = true
    end)
    _main_state = ":idle"
  elseif _main_state == ":fin" then
    dtb_disp("wow. you are catching on fast!")
    dtb_disp("i have given you all the basic rules.")
    dtb_disp("there are many secret rules hidden in the game, so discover them.")
    dtb_disp("well, see you then!", function()
      jump("quantattack_title")
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
