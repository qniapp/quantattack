require("engine/test/bustedhelper")
local match = require("luassert.match")

local game = require("game")
local board_class = require("board")

local function wait_swap_to_finish(board)
  for _i = 1, 5 do
    board:update()
  end
end

describe('combo', function()
  local board

  before_each(function()
    stub(game, "combo_callback")
    board = board_class()
  end)

  it("コンボでコールバックが呼ばれる", function()
    -- [X H]         H X
    --  H X  ----->  H X
    board:put(1, 11, x_gate())
    board:put(1, 12, h_gate())
    board:put(2, 11, h_gate())
    board:put(2, 12, x_gate())

    board:swap(1, 2, 12)
    wait_swap_to_finish(board)

    local combo_callback = assert.spy(game.combo_callback)
    board:update(game.combo_callback)

    combo_callback.was_called(1)
    combo_callback.was_called_with(4, match._)
  end)
end)
