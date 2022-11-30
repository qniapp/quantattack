local attack_bubble = require("lib/attack_bubble")
local particle = require("lib/particle")
local bubble = require("lib/bubble")

require("lib/helpers")
require("lib/ripple")

local all_players, countdown

function game()
  return setmetatable({
    auto_raise_frame_count = 30,

    is_game_over = function(_ENV)
      return game_over_time ~= nil
    end,

    init = function(_ENV)
      all_players = {}
      countdown = 240
      start_time = t()
      game_over_time = nil
      init_ripple()
    end,

    add_player = function(_ENV, player, player_cursor, board, other_board)
      player.player_cursor = player_cursor
      player.board = board
      player.other_board = other_board
      player.tick = 0

      add(all_players, player)
    end,

    update = function(_ENV)
      update_ripple()

      if countdown then
        countdown = countdown - 1
        local countdown_number = flr(countdown / 60 + 1)

        if countdown > 0 then
          start_time = t()

          if countdown_number < 4 then
            for _, each in pairs(all_players) do
              each.board.countdown = countdown_number
            end
          end

          if countdown % 60 == 0 then
            sfx(5)
          end
        elseif countdown == 0 then
          countdown = nil

          for _, each in pairs(all_players) do
            each.board.countdown = nil
          end

          sfx(6)
        end
      end

      -- もしどちらかの board でおじゃまゲートを分解中だった場合 "slow" にする
      ripple_speed = "normal"

      for index, each in pairs(all_players) do
        local player_cursor = each.player_cursor
        local board = each.board
        local other_board = each.other_board

        if board:is_game_over() then
          board:update()
          ripple_speed = "normal"
        else
          each:update(board)

          if each.left then
            sfx(0)
            player_cursor:move_left()
          end
          if each.right then
            sfx(0)
            player_cursor:move_right()
          end
          if each.up then
            sfx(0)
            player_cursor:move_up()
          end
          if each.down then
            sfx(0)
            player_cursor:move_down()
          end
          if each.o and not countdown and board:swap(player_cursor.x, player_cursor.y) then
            sfx(2)
          end
          if each.x and not countdown and board.top_gate_y > 2 then
            _raise(_ENV, each)
          end

          board:update(_ENV, each, other_board)
          player_cursor:update()

          if not countdown then
            _auto_raise(_ENV, each)
          end

          if board.contains_garbage_match_gate then
            ripple_speed = "slow"
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
        if #all_players == 1 then
          if all_players[1].board:is_game_over() then
            game_over_time = t()
          end
        else
          local board1, board2 = all_players[1].board, all_players[2].board

          if board1:is_game_over() or board2:is_game_over() then
            game_over_time = t()

            if board1.lose then
              board2.win = true
            end
            if board2.lose then
              board1.win = true
            end
          end
        end
      end
    end,

    render = function(_ENV) -- override
      for _, each in pairs(all_players) do
        local player_cursor = each.player_cursor
        local board = each.board

        board:render()

        if not board:is_game_over() then
          player_cursor:render()
        end

        -- カウントダウンの数字はカーソルの上に表示
        if board.countdown then
          local countdown_sprite_x = { 96, 80, 64 }
          sspr(countdown_sprite_x[board.countdown], 32,
            16, 16,
            board.offset_x + 16, board.offset_y + 43)
        end
      end

      particle:render_all()
      bubble:render_all()
      attack_bubble:render_all()

      -- print_outlined(stat(1), 101, 112, 7)
      -- print_outlined(stat(7), 117, 120, 7)
    end,

    -- ゲートをせりあげる
    _raise = function(_ENV, player)
      local board, cursor = player.board, player.player_cursor

      board.raised_dots = board.raised_dots + 1

      if board.raised_dots == 8 then
        board.raised_dots = 0
        board:insert_gates_at_bottom(player.steps)
        cursor:move_up()
        player.steps = player.steps + 1
      end
    end,

    -- 可能な場合ゲートを自動的にせりあげる
    _auto_raise = function(_ENV, player)
      if player.board:is_busy() then
        return
      end

      player.tick = player.tick + 1

      if player.tick > auto_raise_frame_count then
        _raise(_ENV, player)
        player.tick = 0
      end
    end,
  }, { __index = _ENV })
end
