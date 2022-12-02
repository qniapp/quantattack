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

local all_balloons = {}

local task_balloon = new_class()

function task_balloon:_init(rule, dx, dy)
  self.rule = rule
  self.dx = dx + rnd(10)
  self.dy = dy + rnd(10)
  self.dt = rnd(10)
  self.state = ":idle"
end

function task_balloon:update()
  self.x = board.offset_x + board.width + 10 + cos((t() + self.dt) / 1.5) * 2 + self.dx
  self.y = 16 + sin((t() + self.dt) / 2) * 4 + self.dy
end

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

function task_balloon:render()
  -- バルーン
  sspr(56, 32, 16, 12, self.x, self.y)

  -- ゲート
  for i, row in pairs(self.rule[1]) do
    local gate1_type, gate2_type = unpack(row)
    local row_x = self.x + 4
    local row_y = self.y + (i - 1) * 8 + 12

    if gate1_type ~= "?" then
      if gate1_type == "swap" or gate1_type == "control" or gate1_type == "cnot_x" then
        line(row_x + 3, row_y + 3, row_x + 11, row_y + 3, 10)
      end
      spr(gate(gate1_type).sprite_set.default, row_x, row_y)
    end

    if gate2_type then
      spr(gate(gate2_type).sprite_set.default, row_x + 8, row_y)
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

local function cat(f, ...)
  for i, s in pairs({ ... }) do
    for k, v in pairs(s) do
      if tonum(k) then
        add(f, v)
      else
        f[k] = v
      end
    end
  end
  return f
end

--- waves
local wave_number = 1

local waves = {
  -- wave 1
  shuffle({
      reduction_rules.h[1],
      reduction_rules.x[1],
      reduction_rules.y[1],
      reduction_rules.z[1],
      reduction_rules.s[1],
      reduction_rules.t[1]
  }),

  -- wave 2
  shuffle({
      reduction_rules.x[2],
      reduction_rules.z[2]
  }),

  -- wave 3
  shuffle({
      reduction_rules.h[2],
      reduction_rules.h[3],
      reduction_rules.s[2],
      reduction_rules.t[2]
  }),

  -- wave 4
  shuffle({
      reduction_rules.control[1],
      reduction_rules.control[2]
  }),

  -- wave 5
  shuffle({
      reduction_rules.h[5],
      reduction_rules.x[5],
      reduction_rules.y[2],
      reduction_rules.z[5],
      reduction_rules.s[3],
      reduction_rules.t[3]
  }),

  -- wave 6
  {
    reduction_rules.swap[1]
  }
}

local all_match_circles = {}

function create_match_circle(x, y)
  add(all_match_circles, { x = x, y = y, r = 0, c = 7 })
  add(all_match_circles, { x = x, y = y, r = 2, c = 13 })
end

function update_match_circles()
  for _, each in pairs(all_match_circles) do
    local dr = 4
    if attack_bubble.slow then
      dr = 0.8
    end
    each.r = each.r + dr
  end
end

function render_match_circles()
  for _, each in pairs(all_match_circles) do
    circ(each.x, each.y, each.r, each.c)
  end
end

state = ":play"
match_pattern = nil
match_screen_x = nil
match_screen_y = nil
match_dx = nil

function mission_game.reduce_callback(score, x, y, player, pattern, dx)
  printh("reduce_callback")

  for _, each in pairs(all_balloons) do
    if each.rule[5] == pattern then
      state = ":matching"
      match_dx = dx

      local attack_cube_callback = function(target_x, target_y)
        del(all_balloons, each)
        state = ":play"
        sfx(10)
        particle:create_chunk(target_x, target_y,
                              "10,10,9,7,random,random,-0.03,-0.03,20|10,10,9,7,random,random,-0.03,-0.03,20|9,9,9,7,random,random,-0.03,-0.03,20|9,9,2,5,random,random,-0.03,-0.03,20|9,9,6,7,random,random,-0.03,-0.03,20|7,7,9,7,random,random,-0.03,-0.03,20|7,7,9,7,random,random,-0.03,-0.03,20|7,7,6,5,random,random,-0.03,-0.03,20|7,7,6,5,random,random,-0.03,-0.03,20|5,5,2,5,random,random,-0.03,-0.03,20")
      end

      attack_bubble.slow = true
      sfx(13)
      match_pattern = each.rule
      match_screen_x = board:screen_x(x)
      match_screen_y = board:screen_y(y)
      create_match_circle(board:screen_x(x) + 3, board:screen_y(y) + 3)
      attack_bubble:create(board:screen_x(x), board:screen_y(y), attack_cube_callback, each.x, each.y)
    end
  end
end

function mission:on_enter()
  wave_number = 0
  all_balloons = {}

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

  update_match_circles()

  if #all_balloons == 0 then
    wave_number = wave_number + 1
    local current_wave = waves[wave_number]
    if current_wave then
      for i, each in pairs(current_wave) do
        add(all_balloons, task_balloon(each, i % 3 * 15, (i % 2) * 38))
      end
    else
      board.win = true
    end
  end

  for _, each in pairs(all_balloons) do
    each:update()
  end
end

function mission:render() -- override
  if state == ":matching" then
    ripple_speed = "slow"
  end
  render_ripple()

  for _, each in pairs(all_balloons) do
    each:render()
  end

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

  render_match_circles()
end

return mission
