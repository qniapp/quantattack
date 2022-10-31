require("engine/core/class")
--#if log
require("engine/debug/dump")
--#endif

local game = new_class()

require("particle")
require("bubble")
require("attack_cube")

local all_players

function game.reduce_callback(score, player)
  player.score = player.score + score
end

function game.combo_callback(combo_count, x, y, player, board, other_board)
  local attack_cube_callback = function()
    player.score = player.score + combo_count
    local b = other_board or board
    if combo_count > 4 then
      b:fall_garbage()
    end
  end

  create_bubble("combo", combo_count, board:screen_x(x), board:screen_y(y))
  create_attack_cube(combo_count, board:screen_x(x), board:screen_y(y), attack_cube_callback,
    unpack(board.attack_cube_target))
end

function game.chain_callback(chain_count, x, y, player, board, other_board)
  local chain_bonus = { 0, 5, 8, 15, 30, 40, 50, 70, 90, 110, 130, 150, 180 }

  if chain_count > 1 then
    local attack_cube_callback = function()
      player.score = player.score + (chain_bonus[chain_count] or 180)
      local b = other_board or board
      if chain_count > 2 then
        b:fall_garbage()
      end
    end

    create_bubble("chain", chain_count, board:screen_x(x), board:screen_y(y))
    create_attack_cube(chain_count, board:screen_x(x), board:screen_y(y), attack_cube_callback,
      unpack(board.attack_cube_target))
  end
end

function game:_init()
end

function game:init()
  all_players = {}
end

function game:add_player(player, player_cursor, board, other_board)
  player.player_cursor = player_cursor
  player.board = board
  player.other_board = other_board
  player.tick = 0

  add(all_players, player)
end

function game:update()
  for _, each in pairs(all_players) do
    local player_cursor = each.player_cursor
    local board = each.board
    local other_board = each.other_board

    if board:is_game_over() then
      board:update()
      each:update(board)
      player_cursor:update()
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
      if each.o then
        if board:swap(player_cursor.x, player_cursor.y) then
          sfx(2)
        end
      end
      if each.x then
        self:_raise(each)
      end

      board:update(self, each, other_board)
      player_cursor:update()
      self:_auto_raise(each)

      each.tick = each.tick + 1

      --#if log
      log("\n" .. board:_tostring())
      --#endif
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

  color(colors.white)
  cursor(1, 1)
  print(stat(1))
  cursor(1, 8)
  print(stat(7))
end

-- ゲートをせりあげる
function game:_raise(player)
  local board = player.board
  local cursor = player.player_cursor

  board.raised_dots = board.raised_dots + 1

  if board.raised_dots == tile_size then
    board.raised_dots = 0
    board:insert_gates_at_bottom(player.steps)
    cursor:move_up()
    player.steps = player.steps + 1
  end
end

function game:_auto_raise(player)
  if (player.tick < 30) then -- TODO: 30 をどこか定数化
    return false
  end

  player.tick = 0

  if player.board:is_busy() then
    return false
  end

  self:_raise(player)

  return true
end

return game
