require("mission/dtb")
require("mission/game")

local player_class = require("lib/player")
local cursor_class = require("lib/cursor")
local board_class = require("lib/board")

local cursor = cursor_class()
local board, player = board_class(cursor), player_class()
local mission_game = game()

local gamestate = require("lib/gamestate")
local mission = derived_class(gamestate)
mission.type = ':mission'

local ripple = require("lib/ripple")
local sash = require("lib/sash")

state = ":play"

function mission_game.reduce_callback(_score, x, y, _player, pattern, dx)
end

dtb_init()

function _init()
  player:_init()
  board:init()
  board:put_random_gates()

  cursor:init()

  mission_game:init()
  mission_game:add_player(player, cursor, board)
end

dtb_disp("a dialogue can be queud with: dtb_disp(text,callback)")

dtb_disp("the prompted dialogue will not interfere with previousily running dialogue boxes.")

dtb_disp("dtb_prompt also has a callback which is called when the piece of dialogue is finished.", function()
  --whatever is in this function is called after this dialogue is done.
  sfx(17)
end)


function _update60()
  mission_game:update()

  sash:update()

  -- make sure to update dtb. no need for logic additional here, dtb takes care of everything.
  dtb_update()
end

function _draw()
  cls()

  -- ripple.slow = state == ":matching"
  ripple:render()

  -- task_balloon:render()
  mission_game:render()
  sash:render()

  -- as with the update function. just make sure dtb is being drawn.
  dtb_draw()

  -- if state == ":matching" then
  --   render_matching_pattern(match_pattern, match_screen_x, match_screen_y)
  -- end

  if not mission_game:is_game_over() then
    spr(112, 70, 109)
    print_outlined("swap blocks", 81, 120, 7, 0)
  end

  -- if not mission_game.countdown then
  --   if not mission_game:is_game_over() then
  --     if #task_balloon.all > 0 then
  --       if flr(t() * 2) % 2 == 0 then
  --         print_outlined("match", 84, 2, 1, 12)
  --         print_outlined("the pattern!", 70, 10, 1, 12)
  --       end
  --     end
  --   end
  -- end
end
