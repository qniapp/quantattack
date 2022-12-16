---@diagnostic disable: global-in-nil-env, lowercase-global

local attack_bubble = require("lib/attack_bubble")
local particle = require("lib/particle")
local bubble = require("lib/bubble")
local ripple = require("lib/ripple")

require("lib/helpers")

local all_players

function game()
  return setmetatable({
    is_game_over = function(_ENV)
      return game_over_time ~= nil
    end,

    init = function(_ENV)
      attack_bubble.slow = false
      particle.slow = false

      all_players = {}
      start_time = t()
      game_over_time = nil
    end,

    add_player = function(_ENV, player, cursor, board, other_board)
      player.cursor = cursor
      player.board = board
      player.other_board = other_board
      player.tick = 0

      add(all_players, player)
    end,

    update = function(_ENV)
      ripple:update()

      -- もしどちらかの board でおじゃまゲートを分解中だった場合 "slow" にする
      ripple.slow = false

      for _, each in pairs(all_players) do
        local cursor = each.cursor
        local board = each.board
        local other_board = each.other_board

        if board:is_game_over() then
          board:update()
          ripple.slow = false
        else
          each:update(board)

          if each.left then
            sfx(8)
            cursor:move_left()
          end
          if each.right then
            sfx(8)
            cursor:move_right(board.cols)
          end
          if each.up then
            sfx(8)
            cursor:move_up()
          end
          if each.down then
            sfx(8)
            cursor:move_down(board.rows)
          end
          if each.x and board:swap(cursor.x, cursor.y) then
            sfx(10)
          end

          board:update(_ENV, each, other_board)
          cursor:update()

          if board.contains_garbage_match_gate then
            ripple.slow = true
          end
        end
      end

      particle:update_all()
      bubble:update_all()
      attack_bubble:update_all()

      if is_game_over(_ENV) then
        particle.slow = true
      else
        -- ゲーム中だけ elapsed_time を更新
        elapsed_time = t() - start_time

        -- プレーヤーが 2 人であれば、勝ったほうの board に win = true をセット
        if all_players[1].board:is_game_over() then
          game_over_time = t()
        end
      end
    end,

    render = function(_ENV) -- override
      for _, each in pairs(all_players) do
        local board = each.board
        board:render()
      end

      particle:render_all()
      bubble:render_all()
      attack_bubble:render_all()
    end,
  }, { __index = _ENV })
end
