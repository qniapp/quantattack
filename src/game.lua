require("engine/core/class")
--#if log
require("engine/debug/dump")
--#endif

local game = new_class()

local particle = require("particle")
local chain_bubble = require("chain_bubble")
local chain_cube = require("chain_cube")

local all_players

function game:_init()
end

function game:init()
  all_players = {}
end

function game:add_player(player, board, player_cursor)
  add(all_players, { player = player, board = board, player_cursor = player_cursor, tick = 0 })
end

function game:update()
  for _, each in pairs(all_players) do
    local player = each.player
    local board = each.board
    local player_cursor = each.player_cursor

    if board:is_game_over() then
      board:update()
      player:update(board)
      player_cursor:update()
    else
      player:update(board)

      if player.left then
        sfx(0)
        player_cursor:move_left()
      end
      if player.right then
        sfx(0)
        player_cursor:move_right()
      end
      if player.up then
        sfx(0)
        player_cursor:move_up()
      end
      if player.down then
        sfx(0)
        player_cursor:move_down()
      end
      if player.o then
        if board:swap(player_cursor.x, player_cursor.x + 1, player_cursor.y) then
          sfx(2)
        end
      end
      if player.x then
        self:_raise(each)
      end

      player.score = player.score + (board:update() or 0)
      player_cursor:update()
      self:_auto_raise(each)

      each.tick = each.tick + 1

      --#if log
      log("\n" .. board:_tostring())
      --#endif
    end
  end

  particle:update()
  chain_bubble:update()
  chain_cube:update()
end

function game:render() -- override
  cls()

  for _, each in pairs(all_players) do
    local board = each.board
    local player_cursor = each.player_cursor

    board:render()

    if not board:is_game_over() then
      player_cursor:render()
    end
  end

  particle:render()
  chain_bubble:render()
  chain_cube:render()

  color(colors.white)
  cursor(1, 1)
  print(stat(1))
  cursor(1, 8)
  print(stat(7))
end

-- ゲートをせりあげる
function game:_raise(player_info)
  local board = player_info.board
  local player = player_info.player
  local cursor = player_info.player_cursor

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

  if (player.board:is_busy()) then
    return false
  end

  self:_raise(player)

  return true
end

return game
