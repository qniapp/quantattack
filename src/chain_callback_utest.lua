require("engine/test/bustedhelper")
require("test_helper")
local match = require("luassert.match")

local game = require("game")
local board_class = require("board")

describe('chain', function()
  local board

  before_each(function()
    stub(game, "chain_callback")
    board = board_class()
  end)

  it("連鎖でコールバックが呼ばれる #solo", function()
    --    Y           Y
    -- [X H]
    --  H X  ----->     ----->
    --  Y Y         Y Y        Y
    board:put(2, 9, y_gate())
    board:put(1, 10, x_gate())
    board:put(2, 10, h_gate())
    board:put(1, 11, h_gate())
    board:put(2, 11, x_gate())
    board:put(1, 12, y_gate())
    board:put(2, 12, y_gate())

    board:swap(1, 2, 10)

    local chain_callback = assert.spy(game.chain_callback)

    wait_swap_to_finish(board)

    -- TODO: update 回数を式として書く
    for _i = 1, 158 do
      board:update(game.combo_callback, game.chain_callback)
    end

    chain_callback.was_called(1)
    chain_callback.was_called_with(2, match._, 2, 11, match._)
  end)
end)
