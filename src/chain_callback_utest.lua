require("engine/test/bustedhelper")
require("test_helper")
require("board")

local match = require("luassert.match")
local game = require("game")

require("player")

describe('chain', function()
  local board
  local player

  before_each(function()
    stub(game, "chain_callback")
    board = create_board()
    board.attack_cube_target = { 85, 30 }
    player = create_player()
  end)

  it("コールバックが呼ばれる #solo", function()
    --    Y           Y          Y
    -- [X H]        H X
    --  H X  -----> H X ----->     ----->   Y
    --  Y Y         Y Y        Y Y        Y Y
    board:put(2, 10, y_gate())
    board:put(1, 11, x_gate())
    board:put(2, 11, h_gate())
    board:put(1, 12, h_gate())
    board:put(2, 12, x_gate())
    board:put(1, 13, y_gate())
    board:put(2, 13, y_gate())

    board:swap(1, 11)

    local chain_callback = assert.spy(game.chain_callback)

    wait_swap_to_finish(board)
    -- TODO: update 回数を式として書く
    for _i = 1, 81 do
      board:update(game, player)
    end

    chain_callback.was_called(1)
    chain_callback.was_called_with(2, 2, 12, match._, match._, match._)
  end)
end)
