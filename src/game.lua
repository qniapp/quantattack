require("engine/core/class")
--#if log
require("engine/debug/dump")
--#endif

local game = new_class()

require("attack_cube")
require("bubble")
require("helpers")
require("particle")

local all_players, state, countdown

function game.reduce_callback(score, player)
  player.score = player.score + score
end

function game.combo_callback(combo_count, x, y, player, board, other_board)
  local attack_cube_callback = function()
    player.score = player.score + combo_count

    -- 対戦相手がいる時、おじゃまゲートを送る
    if other_board then
      other_board:send_garbage(combo_count > 6 and 6 or combo_count - 1, 1)
    end
  end

  create_bubble("combo", combo_count, board:screen_x(x), board:screen_y(y))
  create_attack_cube(board:screen_x(x), board:screen_y(y), attack_cube_callback,
    unpack(board.attack_cube_target))
end

function game.chain_callback(chain_id, chain_count, x, y, player, board, other_board)
  local chain_bonus = { 0, 5, 8, 15, 30, 40, 50, 70, 90, 110, 130, 150, 180 }

  if chain_count > 1 then
    local attack_cube_callback = function()
      player.score = player.score + (chain_bonus[chain_count] or 180)

      -- 対戦相手がいる時、おじゃまゲートを送る
      if other_board then
        other_board:send_garbage(chain_id, 6, chain_count - 1 < 6 and chain_count - 1 or 5)
      end
    end

    create_bubble("chain", chain_count, board:screen_x(x), board:screen_y(y))
    create_attack_cube(board:screen_x(x), board:screen_y(y), attack_cube_callback,
      unpack(board.attack_cube_target))
  end
end

function game:_init()
  self.auto_raise_frame_count = 30
end

function game:init()
  all_players = {}
  countdown = 240
end

function game:add_player(player, player_cursor, board, other_board)
  player.player_cursor = player_cursor
  player.board = board
  player.other_board = other_board
  player.tick = 0

  add(all_players, player)
end

function game:update()
  if countdown then
    countdown = countdown - 1
    local countdown_number = flr(countdown / 60 + 1)

    if countdown > 0 then
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

  for _, each in pairs(all_players) do
    local player_cursor = each.player_cursor
    local board = each.board
    local other_board = each.other_board

    if board:is_game_over() then
      board:update()
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
      if each.x and not countdown and board:top_gate_y() > 2 then
        self:_raise(each)
      end

      board:update(self, each, other_board)
      player_cursor:update()

      if not countdown then
        self:_auto_raise(each)
      end
    end
  end

  update_particles()
  update_bubbles()
  update_attack_cubes()
end

function game:render() -- override
  cls()

  for _, each in pairs(all_players) do
    local player_cursor = each.player_cursor
    local board = each.board

    board:render()

    if not board:is_game_over() then
      player_cursor:render()
    end
  end

  render_particles()
  render_bubbles()
  render_attack_cubes()

  print_outlined(stat(1), 1, 1, 7)
  print_outlined(stat(7), 1, 8, 7)
end

-- ゲートをせりあげる
function game:_raise(player)
  local board, cursor = player.board, player.player_cursor

  board.raised_dots = board.raised_dots + 1

  if board.raised_dots == 8 then
    board.raised_dots = 0
    board:insert_gates_at_bottom(player.steps)
    cursor:move_up()
    player.steps = player.steps + 1
  end
end

-- 可能な場合ゲートを自動的にせりあげる
function game:_auto_raise(player)
  if player.board:is_busy() then
    return
  end

  player.tick = player.tick + 1

  if player.tick > self.auto_raise_frame_count then
    self:_raise(player)
    player.tick = 0
  end
end

return game
