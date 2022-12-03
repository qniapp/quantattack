local flow = require("lib/flow")
local gate = require("lib/gate")

require("lib/board")

local board = create_board()
board.attack_cube_target = { 85, 30 }

require("lib/player")
local player = create_player()

require("lib/player_cursor")
local player_cursor = create_player_cursor(board)

require("mission/game")
local mission_game = game()

local gamestate = require("lib/gamestate")
local mission = derived_class(gamestate)

mission.type = ':mission'

local current_task = nil
local last_steps = 0

local reduction_rules = require("lib/reduction_rules")
local attack_bubble = require("lib/attack_bubble")
local particle = require("lib/particle")
local ripple = require("lib/ripple")

local task_balloon = require("mission/task_balloon")

function render_matching_pattern(pattern, x, y)
  local random_color = ceil_rnd(15)

  for i, row in pairs(pattern[1]) do
    local gate1_type, gate2_type = unpack(row)
    local row_x = x
    local row_y = y + (i - 1) * 8

    if gate1_type ~= "?" then
      draw_rounded_box(row_x - 1, row_y - 1, row_x + 7, row_y + 7, random_color)
    end

    if gate2_type then
      draw_rounded_box(row_x + (match_dx * 8) - 1, row_y - 1, row_x + (match_dx + 1) * 8 - 1, row_y + 7, random_color)
    end
  end
end

local function shuffle(t)
  -- do a fisher-yates shuffle
  for i = #t, 1, -1 do
    local j = ceil_rnd(i)
    t[i], t[j] = t[j], t[i]
  end

  return t
end

-- waves
local wave_number = 1

local waves = {
  -- wave 1
  shuffle({
    reduction_rules.h[1],
    reduction_rules.x[1],
    reduction_rules.y[1],
    reduction_rules.z[1]
  }),

  -- wave 2
  shuffle({
    reduction_rules.s[1],
    reduction_rules.t[1]
  }),

  -- wave 3
  shuffle({
    reduction_rules.x[2],
    reduction_rules.z[2]
  }),

  -- wave 4
  {
    reduction_rules.cnot_x[1]
  },

  -- wave 5
  {
    reduction_rules.cnot_x[2]
  },

  -- wave 6
  shuffle({
    reduction_rules.h[5],
    reduction_rules.x[5],
    reduction_rules.y[2],
    reduction_rules.z[5],
    reduction_rules.s[3],
    reduction_rules.t[3]
  }),

  -- wave 7
  shuffle({
    reduction_rules.h[2],
    reduction_rules.h[3],
    reduction_rules.s[2],
    reduction_rules.t[2]
  }),

  -- wave 8
  {
    reduction_rules.swap[1]
  }
}

state = ":play"
match_pattern = nil
match_screen_x = nil
match_screen_y = nil
match_dx = nil

function mission_game.reduce_callback(score, x, y, player, pattern, dx)
  for _, each in pairs(task_balloon.all) do
    if each.rule[5] == pattern then
      state = ":matching"
      match_dx = dx

      local attack_cube_callback = function(target_x, target_y)
        task_balloon:delete(each)
        state = ":play"
        sfx(14)
        particle:create_chunk(target_x, target_y,
          "10,10,9,7,random,random,-0.03,-0.03,20|10,10,9,7,random,random,-0.03,-0.03,20|9,9,9,7,random,random,-0.03,-0.03,20|9,9,2,5,random,random,-0.03,-0.03,20|9,9,6,7,random,random,-0.03,-0.03,20|7,7,9,7,random,random,-0.03,-0.03,20|7,7,9,7,random,random,-0.03,-0.03,20|7,7,6,5,random,random,-0.03,-0.03,20|7,7,6,5,random,random,-0.03,-0.03,20|5,5,2,5,random,random,-0.03,-0.03,20")
      end

      attack_bubble.slow = true
      sfx(13)
      match_pattern = each.rule
      match_screen_x = board:screen_x(x)
      match_screen_y = board:screen_y(y)
      attack_bubble:create(board:screen_x(x), board:screen_y(y), attack_cube_callback, each.x, each.y)
    end
  end
end

function mission:on_enter()
  wave_number = 0

  task_balloon:init()

  player:init()
  board:init()
  board:put_random_gates()

  player_cursor:init()

  mission_game:init()
  mission_game:add_player(player, player_cursor, board)
end

function mission:update()
  mission_game:update()

  if player.steps > last_steps then
    -- 10 ステップごとに
    --   * ゲートをせり上げるスピードを上げる
    if player.steps > 0 and player.steps % 10 == 0 then
      if mission_game.auto_raise_frame_count > 10 then
        mission_game.auto_raise_frame_count = mission_game.auto_raise_frame_count - 1
      end
    end
    last_steps = player.steps
  end

  if mission_game:is_game_over() then
    if t() - mission_game.game_over_time > 2 then
      board.show_gameover_menu = true
      if btnp(4) then -- x でリプレイ
        flow:query_gamestate_type(":mission")
      elseif btnp(5) then -- z でタイトルへ戻る
        load('qitaev_title')
      end
    end
  end

  if not mission_game.countdown and stat(16) == -1 then
    if #task_balloon.all == 0 then
      wave_number = wave_number + 1
      local current_wave = waves[wave_number]
      if current_wave then
        for i, each in pairs(current_wave) do
          task_balloon:create(each, board.offset_x + board.width, i % 3 * 15, (i % 2) * 36)
        end
        task_balloon:enter_all()
      else
        board.win = true
      end
    end
  end

  task_balloon:update()
end

function mission:render() -- override
  if state == ":matching" then
    ripple.slow = true
  else
    ripple.slow = false
  end
  ripple:render()

  task_balloon:render()
  mission_game:render()

  if state == ":matching" then
    render_matching_pattern(match_pattern, match_screen_x, match_screen_y)
  end

  if not mission_game:is_game_over() then
    spr(70, 70, 109)
    print_outlined("swap gates", 81, 110, 7, 0)
    spr(117, 70, 119)
    print_outlined("raise gates", 81, 120, 7, 0)
  end

  if not mission_game.countdown and stat(16) == -1 then
    if task_balloon.state == ":enter" then
      print_outlined("wave #" .. wave_number, 80, 10, 0, 8)
    else
      if flr(t() * 2) % 2 == 0 then
        print_outlined("match", 84, 2, 0, 12)
        print_outlined("the pattern!", 70, 10, 0, 12)
      end
    end
  end
end

return mission
