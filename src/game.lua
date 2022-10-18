local flow = require("engine/application/flow")
local player_cursor_class = require("player_cursor")

require("engine/core/class")
--#if log
require("engine/debug/dump")
--#endif

local game = new_class()

local particle = require("particle")
local chain_popup = require("chain_popup")

local all_players

function game:_init()
  self.tick = 0
end

function game:init()
  all_players = {}
end

function game:add_player(player, board, player_cursor)
  add(all_players, { player = player, board = board, player_cursor = player_cursor })
end

function game:update()
  for _, each in pairs(all_players) do
    local player = each.player
    local board = each.board
    local player_cursor = each.player_cursor

    if player:left() then
      sfx(player_cursor_class.sfx_move)
      player_cursor:move_left()
    end
    if player:right() then
      sfx(player_cursor_class.sfx_move)
      player_cursor:move_right()
    end
    if player:up() then
      sfx(player_cursor_class.sfx_move)
      player_cursor:move_up()
    end
    if player:down() then
      sfx(player_cursor_class.sfx_move)
      player_cursor:move_down()
    end
    if player:x() then
      if board:swap(player_cursor.x, player_cursor.x + 1, player_cursor.y) then
        sfx(player_cursor_class.sfx_swap)
      end
    end
    if player:o() then
      self:_raise(board, player, player_cursor)
    end

    player.score = player.score + board:update()
    player_cursor:update()
    particle:update()
    chain_popup:update()

    if self:_auto_raise(board, player, player_cursor) and rnd(1) < 0.05 then
      board:drop_garbage()
    end

    self.tick = self.tick + 1

    --#if log
    log("\n" .. board:_tostring())
    --#endif
  end
end

function game:render() -- override
  cls()

  for _, each in pairs(all_players) do
    local board = each.board
    local player_cursor = each.player_cursor

    board:render()
    player_cursor:render()
  end

  particle:render()
  chain_popup:render()

  color(colors.white)
  cursor(1, 1)
  print(stat(1))
  cursor(1, 8)
  print(stat(7))
end

-- ゲートをせりあげる
function game:_raise(board, player, player_cursor)
  board.raised_dots = board.raised_dots + 1

  if board.raised_dots == tile_size then
    board.raised_dots = 0
    board:insert_gates_at_bottom(player.steps)
    player_cursor:move_up()
    player.steps = player.steps + 1
  end
end

function game:_auto_raise(board, player, player_cursor)
  if (self.tick < 30) then -- TODO: 30 をどこか定数化
    return false
  end

  self.tick = 0

  if (board:is_busy()) then
    return false
  end

  self:_raise(board, player, player_cursor)

  return true
end

return game
