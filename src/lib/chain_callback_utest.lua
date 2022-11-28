require("engine/test/bustedhelper")
require("lib/test_helper")
require("lib/board")

local match = require("luassert.match")
local game = require("lib/game")

require("lib/player")

describe('chain', function()
  local board
  local player

  before_each(function()
    stub(game, "chain_callback")
    board = create_board()
    board.attack_cube_target = { 85, 30 }
    player = create_player()
  end)

  it("コールバックが呼ばれる", function()
    --    Y           Y          Y
    -- [X H]        H X
    --  H X  -----> H X ----->     ----->   Y
    --  Y Y         Y Y        Y Y        Y Y
    board:put(2, 14, y_gate())
    board:put(1, 15, x_gate())
    board:put(2, 15, h_gate())
    board:put(1, 16, h_gate())
    board:put(2, 16, x_gate())
    board:put(1, 17, y_gate())
    board:put(2, 17, y_gate())

    board:swap(1, 15)

    local chain_callback = assert.spy(game.chain_callback)

    wait_swap_to_finish(board)
    -- TODO: update 回数を式として書く
    for _i = 1, 81 do
      board:update(game, player)
    end

    chain_callback.was_called(1)
    chain_callback.was_called_with("2,15", 2, 2, 16, match._, match._, match._)
  end)
end)