---@diagnostic disable: global-in-nil-env, lowercase-global

require("lib/helpers")

local particle = require("lib/particle")
local bubble = require("lib/bubble")
local ripple = require("lib/ripple")

local game = new_class()

function game.is_game_over(_ENV)
  return game_over_time ~= nil
end

function game._init(_ENV)
  particle.slow = false

  start_time = t()
  game_over_time = nil
end

function game.update(_ENV)
  ripple:update()

  -- もしどちらかの board でおじゃまゲートを分解中だった場合 "slow" にする
  ripple.slow = false

  if board:is_game_over() then
    board:update()
    ripple.slow = false
  else
    player:update(board)

    if player.left then
      sfx(8)
      cursor:move_left()
    end
    if player.right then
      sfx(8)
      cursor:move_right(board.cols)
    end
    if player.up then
      sfx(8)
      cursor:move_up()
    end
    if player.down then
      sfx(8)
      cursor:move_down(board.rows)
    end
    if player.x and board:swap(cursor.x, cursor.y) then
      sfx(10)
    end

    board:update(_ENV, player, other_board)
    cursor:update()

    if board.contains_garbage_match_gate then
      ripple.slow = true
    end
  end

  particle:update_all()
  bubble:update_all()

  if is_game_over(_ENV) then
    particle.slow = true
  else
    -- ゲーム中だけ elapsed_time を更新
    elapsed_time = t() - start_time

    -- プレーヤーが 2 人であれば、勝ったほうの board に win = true をセット
    if board:is_game_over() then
      game_over_time = t()
    end
  end
end

function game.render(_ENV)
  board:render()
  particle:render_all()
  bubble:render_all()
end

return game
