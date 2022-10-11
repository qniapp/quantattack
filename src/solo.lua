require("engine/core/class")
require("engine/render/color")

local gamestate = require("engine/application/gamestate")
local solo = derived_class(gamestate)

local board_class = require("board")
local board = board_class()

local player_cursor_class = require("player_cursor")
local player_cursor = player_cursor_class()

local puff_particle = require("puff_particle")

solo.type = ':solo'

local buttons = {
  left = 0,
  right = 1,
  up = 2,
  down = 3,
  x = 4,
  o = 5,
}

function solo:on_enter()
  board:initialize_with_random_gates()
  self.tick = 0
end

function solo:update()
  if btnp(buttons.left) then
    player_cursor:move_left()
  end
  if btnp(buttons.right) then
    player_cursor:move_right()
  end
  if btnp(buttons.up) then
    player_cursor:move_up()
  end
  if btnp(buttons.down) then
    player_cursor:move_down()
  end
  if btnp(buttons.x) then
    if board:swap(player_cursor.x, player_cursor.x + 1, player_cursor.y) then
      player_cursor:sfx_swap()
    end
  end
  if btnp(buttons.o) then
    board:put_garbage()
  end

  board:update()
  self:_create_gate_puff_particles()
  player_cursor:update()
  puff_particle:update()

  self:_maybe_raise_gates()
  self.tick = self.tick + 1
end

function solo:_maybe_raise_gates()
  if (self.tick < 30) then -- TODO: 30 をどこか定数化
    return false
  end

  self.tick = 0

  if (board:is_busy()) then
    return false
  end

  board.raised_dots = board.raised_dots + 1

  if board.raised_dots == 8 then -- FIXME: 定数を quantum_gate.size にする
    board.raised_dots = 0
    board:insert_gates_at_bottom()
    player_cursor:move_up()
  end

  return true
end

function solo:render() -- override
  cls()
  board:render()
  player_cursor:render(board)
  puff_particle:render()
end

function solo:_create_gate_puff_particles()
  foreach(board:gates_to_puff(), function(each)
    local x = board:screen_x(each.x) + 3
    local y = board:screen_y(each.y) + 3

    puff_particle(x, y, 3)
    puff_particle(x, y, 3)
    puff_particle(x, y, 2)
    puff_particle(x, y, 2)
    puff_particle(x, y, 2)
    puff_particle(x, y, 2)
    puff_particle(x, y, 2)
    puff_particle(x, y, 2, colors.light_grey)
    puff_particle(x, y, 1)
    puff_particle(x, y, 1)
    puff_particle(x, y, 1, colors.light_grey)
    puff_particle(x, y, 1, colors.light_grey)
    puff_particle(x, y, 0, colors.dark_purple)

    -- sfx(self.sfx.puff)
  end)
end

return solo
