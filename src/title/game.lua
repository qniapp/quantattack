require("class")

local game = new_class()

require("attack_bubble")
require("bubble")
require("helpers")
require("particle")

local all_players, state

function game.reduce_callback(score, player)
  -- NOP
end

local attack_cube_callback = function()
  -- TODO sfx
end

function game.combo_callback(combo_count, x, y, player, board, other_board)
  create_attack_bubble(board:screen_x(x), board:screen_y(y), attack_cube_callback, 64, 40)
end

function game.gate_offset_callback(chain_id, chain_count, x, y, player, board, other_board)
  return chain_count
end

function game.chain_callback(chain_id, chain_count, x, y, player, board, other_board)
  create_attack_bubble(board:screen_x(x), board:screen_y(y), attack_cube_callback, 64, 40)
end

function game:_init()
  -- NOP
end

function game:init()
  all_players = {}
end

function game:add_player(player, player_cursor, board)
  player.player_cursor = player_cursor
  player.board = board
  player.tick = 0

  add(all_players, player)
end

function game:update()
  for index, each in pairs(all_players) do
    local player_cursor = each.player_cursor
    local board = each.board

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
    if each.o and board:swap(player_cursor.x, player_cursor.y) then
      sfx(2)
    end
    if each.x and board.top_gate_y > 2 then
      self:_raise(each)
    end

    board:update(self, each)
    player_cursor:update()
  end

  update_particles()
  update_bubbles()
  update_attack_bubbles()
end

function game:render() -- override
  for _, each in pairs(all_players) do
    each.board:render()
    each.player_cursor:render()
  end

  render_particles()
  render_bubbles()
  render_attack_bubbles()
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

return game
