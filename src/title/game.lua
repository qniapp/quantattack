require("lib/class")

local game = new_class()

require("lib/attack_bubble")
require("lib/bubble")
require("lib/helpers")
require("lib/particle")

local all_players, state

function game.reduce_callback(_score, _x, _y, _player)
  -- NOP
end

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
  sfx(10)
  create_particle_set(target_x, target_y,
    "5,5,9,7,random,random,-0.03,-0.03,20|5,5,9,7,random,random,-0.03,-0.03,20|4,4,9,7,random,random,-0.03,-0.03,20|4,4,2,5,random,random,-0.03,-0.03,20|4,4,6,7,random,random,-0.03,-0.03,20|2,2,9,7,random,random,-0.03,-0.03,20|2,2,9,7,random,random,-0.03,-0.03,20|2,2,6,5,random,random,-0.03,-0.03,20|2,2,6,5,random,random,-0.03,-0.03,20|0,0,2,5,random,random,-0.03,-0.03,20")

end

function game.combo_callback(combo_count, x, y, player, board, other_board)
  create_attack_bubble(board:screen_x(x), board:screen_y(y), attack_cube_callback, 64, 36)
end

function game.gate_offset_callback(chain_id, chain_count, x, y, player, board, other_board)
  return chain_count
end

function game.chain_callback(chain_id, chain_count, x, y, player, board, other_board)
  create_attack_bubble(board:screen_x(x), board:screen_y(y), attack_cube_callback, 64, 36)
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
