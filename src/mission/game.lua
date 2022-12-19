---@diagnostic disable: global-in-nil-env, lowercase-global

require("lib/helpers")

local gate = require("lib/gate")
local particle = require("lib/particle")
local bubble = require("lib/bubble")
local ripple = require("lib/ripple")

local game = new_class()
local _state

function game._init(_ENV)
  _state = ":initial"
  show_board = false
end

local board_data = {
  { "placeholder", "placeholder", "h", "i", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "h", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" },
  { "placeholder", "placeholder", "placeholder", "placeholder", "placeholder", "placeholder" }
}

function game.update(_ENV)
  if _state == ":initial" then
    -- NOP
  elseif _state == ":raise_stack" then
    board.raised_dots = board.raised_dots + 1

    if _rows_raised < 8 then
      if board.raised_dots == 8 then
        _rows_raised = _rows_raised + 1
        board.raised_dots = 0
        board:shift_all_blocks_up()

        for x = 1, board.cols do
          board:put(x, board.row_next_gates, gate(board_data[_rows_raised][x]))
        end

        cursor:move_up()
      end
    else
      _state = ":idle"
      _raise_stack_callback()
    end
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
  end

  -- すべてのモードに共通な update 処理
  board:update(_ENV, player)
  cursor:update()

  ripple:update()
  particle:update_all()
  bubble:update_all()
end

function game.render(_ENV)
  if _state ~= ":initial" then
    board:render()
  end
  particle:render_all()
  bubble:render_all()
end

function game.raise_stack(_ENV, callback)
  _state = ":raise_stack"
  _rows_raised = 0
  _raise_stack_callback = callback
end

return game
