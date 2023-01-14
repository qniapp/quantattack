require("engine/test/bustedhelper")
require("test/test_helper")
require("lib/player")
require("lib/game")
require("lib/board")
require("lib/block")
require("lib/cursor")

local match = require("luassert.match")

describe('chain', function()
  local board
  local player

  before_each(function()
    stub(game_class, "chain_callback")
    board = board_class()
    board.attack_ion_target = { 85, 30 }
    player = player_class()
  end)

  it("コールバックが呼ばれる", function()
    --    Y           Y          Y
    -- [X H]        H X
    --  H X  -----> H X ----->     ----->   Y
    --  Y Y         Y Y        Y Y        Y Y
    board:put(2, 4, block_class("y"))
    board:put(1, 3, block_class("x"))
    board:put(2, 3, block_class("h"))
    board:put(1, 2, block_class("h"))
    board:put(2, 2, block_class("x"))
    board:put(1, 1, block_class("y"))
    board:put(2, 1, block_class("y"))

    board:swap(1, 3)

    local chain_callback = assert.spy(game_class.chain_callback)

    wait_swap_to_finish(board)

    -- TODO: update 回数を式として書く
    for _i = 1, 200 do
      board:update(game_class, player)
    end

    chain_callback.was_called(1)
    chain_callback.was_called_with("2,3", 2, board:screen_x(2), board:screen_y(2), match._, match._, match._)
  end)
end)
