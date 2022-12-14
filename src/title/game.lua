---@diagnostic disable: global-in-nil-env, lowercase-global

local attack_bubble = require("lib/attack_bubble")
local particle = require("lib/particle")
local bubble = require("lib/bubble")

require("lib/helpers")

title_logo_bounce_speed, title_logo_bounce_screen_dy = 0, 0

-- タイトルロゴを跳ねさせる
local function bounce_title_logo()
  title_logo_bounce_screen_dy, title_logo_bounce_speed = 0, -5
end

function update_title_logo_bounce()
  if title_logo_bounce_speed ~= 0 then
    title_logo_bounce_speed = title_logo_bounce_speed + 0.9
    title_logo_bounce_screen_dy = title_logo_bounce_screen_dy + title_logo_bounce_speed

    if title_logo_bounce_screen_dy > 0 then
      title_logo_bounce_screen_dy, title_logo_bounce_speed = 0, -title_logo_bounce_speed
    end
  end
end

local attack_cube_callback = function(target_x, target_y)
  bounce_title_logo()
  sfx(19)
  particle:create_chunk(target_x, target_y,
    "5,5,9,7,random,random,-0.03,-0.03,20|5,5,9,7,random,random,-0.03,-0.03,20|4,4,9,7,random,random,-0.03,-0.03,20|4,4,2,5,random,random,-0.03,-0.03,20|4,4,6,7,random,random,-0.03,-0.03,20|2,2,9,7,random,random,-0.03,-0.03,20|2,2,9,7,random,random,-0.03,-0.03,20|2,2,6,5,random,random,-0.03,-0.03,20|2,2,6,5,random,random,-0.03,-0.03,20|0,0,2,5,random,random,-0.03,-0.03,20")
end

function game()
  return setmetatable({
    reduce_callback = function(_score, _x, _y, _player)
      -- NOP
    end,

    combo_callback = function(_combo_count, x, y, _player, board, _other_board)
      attack_bubble:create(
        board:screen_x(x),
        board:screen_y(y),
        attack_cube_callback,
        12,
        64,
        36
      )
    end,

    gate_offset_callback = function(_chain_id, chain_count, _x, _y, _player, _board, _other_board)
      return chain_count
    end,

    chain_callback = function(_chain_id, _chain_count, x, y, _player, board, _other_board)
      attack_bubble:create(
        board:screen_x(x),
        board:screen_y(y),
        attack_cube_callback,
        12,
        64,
        36
      )
    end,

    init = function(_ENV)
      all_players = {}
    end,

    add_player = function(_ENV, player, player_cursor, board)
      player.player_cursor = player_cursor
      player.board = board
      player.tick = 0

      add(all_players, player)
    end,

    update = function(_ENV)
      for _, each in pairs(all_players) do
        local player_cursor, board = each.player_cursor, each.board

        each:update(board)

        if each.left then
          sfx(8)
          player_cursor:move_left()
        end
        if each.right then
          sfx(8)
          player_cursor:move_right()
        end
        if each.up then
          sfx(8)
          player_cursor:move_up()
        end
        if each.down then
          sfx(8)
          player_cursor:move_down()
        end
        if each.x and board:swap(player_cursor.x, player_cursor.y) then
          sfx(10)
        end
        if each.o and board.top_gate_y > 2 then
          _raise(_ENV, each)
        end

        board:update(_ENV, each)
        player_cursor:update()
      end

      particle:update_all()
      bubble:update_all()
      attack_bubble:update_all()
    end,

    render = function(_ENV)
      for _, each in pairs(all_players) do
        each.board:render()
        each.player_cursor:render()
      end

      particle:render_all()
      bubble:render_all()
      attack_bubble:render_all()
    end,

    -- ゲートをせりあげる
    _raise = function(_ENV, player)
      local board, cursor = player.board, player.player_cursor

      board.raised_dots = board.raised_dots + 1

      if board.raised_dots == 8 then
        board.raised_dots = 0
        board:insert_gates_at_bottom(player.steps)
        cursor:move_up()
      end
    end
  }, { __index = _ENV })
end
