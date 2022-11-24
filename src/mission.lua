require("board")

local board = create_board()
board.attack_cube_target = { 85, 30 }

require("player")
local player = create_player()

require("player_cursor")
local player_cursor = create_player_cursor(board)

local game_class = require("game")
local game = game_class()

local gamestate = require("gamestate")
local mission = derived_class(gamestate)

mission.type = ':mission'

local current_task = nil
local last_steps = 0

local reduction_rules = require("reduction_rules")

function mission:on_enter()
  player:init()
  board:put_random_gates()
  player_cursor:init()

  game:init()
  game:add_player(player, player_cursor, board)
end

function mission:update()
  if current_task == nil then
    local first_gates = split("h,x,y,z,s,t,control,swap")
    local first_gate = first_gates[flr(rnd(#first_gates) + 1)]
    local rules = reduction_rules[first_gate]
    current_task = rules[flr(rnd(#rules) + 1)]
    printh(current_task[5])
  end

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
  game:render()

  -- MATCH THE PATTERN を表示
  local pattern_base_x = board.offset_x + board.width + 10
  local pattern_base_y = 16

  print_outlined("match", pattern_base_x, pattern_base_y, 7)
  print_outlined("the pattern!", pattern_base_x, pattern_base_y + 8, 7)

  -- マッチ前のパターンを表示
  for i, row in pairs(current_task[1]) do
    local gate1_type, gate2_type = unpack(row)
    local row_x = pattern_base_x + 4
    local row_y = pattern_base_y + 18 + (i - 1) * 8

    if gate1_type ~= "?" then
      if gate1_type == "swap" or gate1_type == "control" or gate1_type == "cnot_x" then
        line(row_x + 3, row_y + 3, row_x + 11, row_y + 3, 10)
      end
      spr(gate(gate1_type).default_sprite_id, row_x, row_y)

      -- 右側のもここで描く
      spr(gate(gate1_type).default_sprite_id, row_x + 24, row_y)
    end

    if gate2_type then
      spr(gate(gate2_type).default_sprite_id, row_x + 8, row_y)

      -- 右側のもここで描く
      spr(gate(gate2_type).default_sprite_id, row_x + 8 + 24, row_y)
    end
  end

  -- マッチ後のパターンを表示
  for _, reduce_to in pairs(current_task[2]) do
    printh(reduce_to.gate_type)
    printh("dx, dy = " .. (reduce_to.dx and 'true' or 'false') .. ", " .. (reduce_to.dy or 0))

    local reduce_to_x = reduce_to.dx and pattern_base_x + 4 + 32 or pattern_base_x + 4 + 24
    local reduce_to_y = reduce_to.dy and pattern_base_y + 18 + reduce_to.dy * 8 or pattern_base_y + 18

    if reduce_to.gate_type == "i" then
      rectfill(reduce_to_x, reduce_to_y, reduce_to_x + 7, reduce_to_y + 7, 0)
      spr(117, reduce_to_x, reduce_to_y)
    else
      rectfill(reduce_to_x, reduce_to_y, reduce_to_x + 7, reduce_to_y + 7, 0)
      spr(gate(reduce_to.gate_type).default_sprite_id, reduce_to_x, reduce_to_y)
    end
  end
end

return mission
