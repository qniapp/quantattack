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

-- function render_matching_pattern(pattern, x, y)
--   local random_color = ceil_rnd(15)

--   for i, row in pairs(pattern[1]) do
--     local gate1_type, gate2_type = unpack(row)
--     local row_x, row_y = x, y + (i - 1) * 8

--     if gate1_type ~= "?" then
--       draw_rounded_box(row_x - 1, row_y - 1, row_x + 7, row_y + 7, random_color)
--     end

--     if gate2_type then
--       draw_rounded_box(row_x + (match_dx * 8) - 1, row_y - 1, row_x + (match_dx + 1) * 8 - 1, row_y + 7, random_color)
--     end
--   end
-- end

-- local function shuffle(t)
--   -- do a fisher-yates shuffle
--   for i = #t, 1, -1 do
--     local j = ceil_rnd(i)
--     t[i], t[j] = t[j], t[i]
--   end
--   return t
-- end

-- waves
-- local wave_number = 1
-- local waves = {
--   -- wave 1
--   "h,1|x,1|y,1|z,1",
--   -- wave 2
--   "s,1|t,1",
--   -- wave 3
--   "x,2|z,2",
--   -- wave 4
--   "cnot_x,1",
--   -- wave 5
--   "cnot_x,2",
--   -- wave 6
--   "h,5|x,5|y,2|z,5",
--   -- wave 7
--   "s,3|t,3",
--   -- wave 8
--   "h,2|h,3|s,2|t,2",
--   -- wave 9
--   "swap,1"
-- }

state = ":play"
-- match_pattern = nil
-- match_screen_x = nil
-- match_screen_y = nil
-- match_dx = nil

function mission_game.reduce_callback(_score, x, y, _player, pattern, dx)
  -- for _, each in pairs(task_balloon.all) do
  --   if each.rule[5] == pattern then
  --     state = ":matching"
  --     match_dx = dx

  --     local attack_cube_callback = function(target_x, target_y)
  --       task_balloon:delete(each)
  --       state = ":play"
  --       sfx(23)
  --       particle:create_chunk(target_x, target_y,
  --         "10,10,9,7,random,random,-0.03,-0.03,20|10,10,9,7,random,random,-0.03,-0.03,20|9,9,9,7,random,random,-0.03,-0.03,20|9,9,2,5,random,random,-0.03,-0.03,20|9,9,6,7,random,random,-0.03,-0.03,20|7,7,9,7,random,random,-0.03,-0.03,20|7,7,9,7,random,random,-0.03,-0.03,20|7,7,6,5,random,random,-0.03,-0.03,20|7,7,6,5,random,random,-0.03,-0.03,20|5,5,2,5,random,random,-0.03,-0.03,20")
  --     end

  --     attack_bubble.slow = true
  --     sfx(22)
  --     match_pattern = each.rule
  --     match_screen_x = board:screen_x(x)
  --     match_screen_y = board:screen_y(y)
  --     attack_bubble:create(
  --       board:screen_x(x),
  --       board:screen_y(y),
  --       attack_cube_callback,
  --       12,
  --       each.x,
  --       each.y
  --     )
  --   end
  -- end
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

  -- if mission_game:is_game_over() then
  --   if t() - mission_game.game_over_time > 2 then
  --     board.show_gameover_menu = true

  --     if btnp(5) then -- x でリプレイ
  --       _init()
  --     elseif btnp(4) then -- c でタイトルへ戻る
  --       jump('quantattack_title')
  --     end
  --   end
  -- end

  if mission_game.countdown == nil then
    -- if #task_balloon.all == 0 then
    --   wave_number = wave_number + 1
    --   local current_wave = waves[wave_number]
    --   if current_wave then
    --     for i, each in pairs(shuffle(split(current_wave, "|"))) do
    --       local gate_type, rule_number = unpack(split(each))
    --       task_balloon:create(reduction_rules[gate_type][rule_number], board.offset_x + board.width, i % 3 * 15,
    --         (i % 2) * 36)
    --     end
    --     task_balloon:enter_all()
    --     sfx(24)
    --     sash:create("wave #" .. wave_number, 13, 7, function() sfx(-2, -1) end)
    --   else
    --     board.win = true
    --   end
    -- end
    board.win = true
  end

  -- task_balloon:update()
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
