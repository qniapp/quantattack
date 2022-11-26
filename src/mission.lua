require("board")

local board = create_board()
board.attack_cube_target = { 85, 30 }

require("player")
local player = create_player()

require("player_cursor")
local player_cursor = create_player_cursor(board)

local game_class = require("mission/game")
local game = game_class()

local gamestate = require("gamestate")
local mission = derived_class(gamestate)

mission.type = ':mission'

local current_task = nil
local last_steps = 0

local reduction_rules = require("reduction_rules")

require("attack_bubble")

function shuffle(t)
  -- do a fisher-yates shuffle
  for i = #t, 1, -1 do
    local j = flr(rnd(i)) + 1
    t[i], t[j] = t[j], t[i]
  end

  return t
end

function cat(f, ...)
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

--- タスク
local task_number = 1

local tasks_level1 = shuffle({
  reduction_rules.h[1],
  reduction_rules.x[1],
  reduction_rules.y[1],
  reduction_rules.z[1],
  reduction_rules.s[1],
  reduction_rules.t[1]
})
local tasks_level2 = shuffle({
  reduction_rules.x[2],
  reduction_rules.z[2]
})
local tasks_level3 = shuffle({
  reduction_rules.h[2],
  reduction_rules.h[3],
  reduction_rules.s[2],
  reduction_rules.t[2]
})
local tasks_level4 = shuffle({
  reduction_rules.control[1],
  reduction_rules.control[2]
})
local tasks_level5 = shuffle({
  reduction_rules.h[5],
  reduction_rules.x[5],
  reduction_rules.y[2],
  reduction_rules.z[5],
  reduction_rules.s[3],
  reduction_rules.t[3]
})
local tasks_level6 = {
  reduction_rules.swap[1]
}

local tasks = cat(tasks_level1, tasks_level2, tasks_level3, tasks_level4, tasks_level5, tasks_level6)

function set_task()
  current_task = tasks[task_number]
  if current_task == nil then
    board.win = true
  else
    task_number = task_number + 1
  end
end

function game.reduce_callback(score, x, y, player, pattern)
  if current_task and current_task[5] == pattern then
    local attack_cube_callback = function(target_x, target_y)
      sfx(10)
      create_particle_set(target_x, target_y,
        "10,10,9,7,random,random,-0.03,-0.03,20|10,10,9,7,random,random,-0.03,-0.03,20|9,9,9,7,random,random,-0.03,-0.03,20|9,9,2,5,random,random,-0.03,-0.03,20|9,9,6,7,random,random,-0.03,-0.03,20|7,7,9,7,random,random,-0.03,-0.03,20|7,7,9,7,random,random,-0.03,-0.03,20|7,7,6,5,random,random,-0.03,-0.03,20|7,7,6,5,random,random,-0.03,-0.03,20|5,5,2,5,random,random,-0.03,-0.03,20")
      set_task()
    end

    create_attack_bubble(board:screen_x(x), board:screen_y(y), attack_cube_callback, board.offset_x + board.width + 27,
      40)
  end
end

function mission:on_enter()
  player:init()
  board:put_random_gates()
  player_cursor:init()

  game:init()
  game:add_player(player, player_cursor, board)

  set_task()
end

function mission:update()
  game:update()

  if player.steps > last_steps then
    -- 10 ステップごとに
    --   * おじゃまゲートを降らせる (最大 10 段)
    --   * ゲートをせり上げるスピードを上げる
    if player.steps > 0 and player.steps % 10 == 0 then
      if game.auto_raise_frame_count > 10 then
        game.auto_raise_frame_count = game.auto_raise_frame_count - 1
      end
      board:send_garbage(nil, 6, player.steps / 10 < 11 and player.steps / 10 or 10)
    end
    last_steps = player.steps
  end

  if game:is_game_over() then
    if t() - game.game_over_time > 2 then
      board.push_any_key = true
      if btnp(4) or btnp(5) then -- x または z でタイトルへ戻る
        load('qitaev_title')
      end
    end
  end
end

function mission:render() -- override
  render_ripple()

  if current_task then
    -- MATCH THE PATTERN を表示
    local pattern_base_x = board.offset_x + board.width + 10
    local pattern_base_y = 16 + sin(t()) * 2

    print_outlined("match", pattern_base_x, pattern_base_y, 7)
    print_outlined("the pattern!", pattern_base_x, pattern_base_y + 8, 7)

    for i, row in pairs(current_task[1]) do
      local gate1_type, gate2_type = unpack(row)
      local row_x = pattern_base_x + 17
      local row_y = pattern_base_y + 22 + (i - 1) * 8

      if gate1_type ~= "?" then
        if gate1_type == "swap" or gate1_type == "control" or gate1_type == "cnot_x" then
          line(row_x + 3, row_y + 3, row_x + 11, row_y + 3, 10)
        end
        spr(gate(gate1_type).default_sprite_id, row_x, row_y)
      end

      if gate2_type then
        spr(gate(gate2_type).default_sprite_id, row_x + 8, row_y)
      end
    end
  end

  game:render()
end

return mission
