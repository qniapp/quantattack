local flow = require("engine/application/flow")
local ui = require("engine/ui/ui")

require("engine/application/constants")
require("engine/core/class")
require("engine/render/color")
require("particle")

--#if log
require("engine/debug/dump")
--#endif

local gamestate = require("engine/application/gamestate")
local vs = derived_class(gamestate)

local player_class = require("player")
local player = player_class()

local board_class = require("board")
local board = board_class()

local player_cursor_class = require("player_cursor")
local player_cursor = player_cursor_class(board)

local chain_popup = require("chain_popup")

vs.type = ':vs'

local buttons = {
  left = 0,
  right = 1,
  up = 2,
  down = 3,
  x = 4,
  o = 5,
}

function vs:on_enter()
  board:initialize_with_random_gates()
  player:init()
  self.tick = 0
end

function vs:update()
  if board:is_game_over() then
    if btnp(buttons.o) then
      flow:query_gamestate_type(':title')
    end
  else
    if btnp(buttons.left) then
      sfx(player_cursor_class.sfx_move)
      player_cursor:move_left()
    end
    if btnp(buttons.right) then
      sfx(player_cursor_class.sfx_move)
      player_cursor:move_right()
    end
    if btnp(buttons.up) then
      sfx(player_cursor_class.sfx_move)
      player_cursor:move_up()
    end
    if btnp(buttons.down) then
      sfx(player_cursor_class.sfx_move)
      player_cursor:move_down()
    end
    if btnp(buttons.x) then
      if board:swap(player_cursor.x, player_cursor.x + 1, player_cursor.y) then
        sfx(player_cursor_class.sfx_swap)
      end
    end
    if btn(buttons.o) then
      self:_raise()
    end

    player.score = player.score + board:update()
    player_cursor:update()
    update_particles()
    chain_popup:update()

    if self:_auto_raise() and rnd(1) < 0.05 then
      board:drop_garbage()
    end

    self.tick = self.tick + 1

    log("\n" .. board:_tostring())
  end
end

-- ゲートをせりあげる
function vs:_raise()
  board.raised_dots = board.raised_dots + 1

  if board.raised_dots == tile_size then
    board.raised_dots = 0
    board:insert_gates_at_bottom(player.steps)
    player_cursor:move_up()
    player.steps = player.steps + 1
  end
end

function vs:_auto_raise()
  if (self.tick < 30) then -- TODO: 30 をどこか定数化
    return false
  end

  self.tick = 0

  if (board:is_busy()) then
    return false
  end

  self:_raise()

  return true
end

function vs:render() -- override
  cls()

  board:render()
  player_cursor:render()
  render_particles()
  chain_popup:render()

  if board:is_game_over() then
    ui.draw_rounded_box(10, 55, 117, 78, colors.dark_gray, colors.white)
    ui.print_centered("game over", 64, 63, colors.red)
    ui.print_centered("push x to replay", 64, 71, colors.black)
  end

  color(colors.white)
  cursor(1, 1)
  print(stat(1))
  cursor(1, 8)
  print(stat(7))
end

return vs
