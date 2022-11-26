require("lib/class")

local game = new_class()

require("lib/attack_bubble")
require("lib/bubble")
require("lib/helpers")
require("lib/particle")
require("lib/ripple")

local all_players, state, countdown

function game:is_game_over()
  return self.game_over_time ~= nil
end

function game:_init()
  self.auto_raise_frame_count = 30
end

function game:init()
  all_players = {}
  countdown = 240
  self.start_time = t()
  init_ripple()
end

function game:add_player(player, player_cursor, board, other_board)
  player.player_cursor = player_cursor
  player.board = board
  player.other_board = other_board
  player.tick = 0

  add(all_players, player)
end

function game:update()
  update_ripple()

  if countdown then
    countdown = countdown - 1
    local countdown_number = flr(countdown / 60 + 1)

    if countdown > 0 then
      self.start_time = t()

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
        self:_raise(each)
      end

      board:update(self, each, other_board)
      player_cursor:update()

      if not countdown then
        self:_auto_raise(each)
      end

      if board.contains_garbage_match_gate then
        ripple_speed = "slow"
      end
    end
  end

  update_particles()
  update_bubbles()
  update_attack_bubbles()

  if not self:is_game_over() then
    -- ゲーム中だけ elapsed_time を更新
    game.elapsed_time = t() - self.start_time

    -- プレーヤーが 2 人であれば、勝ったほうの board に win = true をセット
    if #all_players == 1 then
      if all_players[1].board:is_game_over() then
        self.game_over_time = t()
      end
    else
      local board1, board2 = all_players[1].board, all_players[2].board

      if board1:is_game_over() or board2:is_game_over() then
        self.game_over_time = t()

        if board1.lose then
          board2.win = true
        end
        if board2.lose then
          board1.win = true
        end
      end
    end
  end
end

function game:render() -- override
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

  render_particles()
  render_bubbles()
  render_attack_bubbles()

  -- print_outlined(stat(1), 101, 112, 7)
  -- print_outlined(stat(7), 117, 120, 7)
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

-- ゲーム経過時間を文字列で返す (e.g., "01:23")
function game:elapsed_time_string()
  return length2_number_string_0filled(flr(self.elapsed_time / 60)) ..
      ":" ..
      length2_number_string_0filled(flr(self.elapsed_time) % 60)
end

function length2_number_string_0filled(num)
  return (num < 10) and "0" .. num or num
end

return game
