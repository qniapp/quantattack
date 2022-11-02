require("engine/test/bustedhelper")
require("test_helper")
require("board")

local match = require("luassert.match")
local game = require("game")

describe('コンボ (同時消し) のコールバック', function()
  local board

  before_each(function()
    board = create_board()
    stub(game, "combo_callback")
  end)

  it("4-コンボ発生でコールバックが呼ばれる", function()
    -- [X H]         H X <- 4-combo
    --  H X  ----->  H X
    board:put(1, 11, x_gate())
    board:put(1, 12, h_gate())
    board:put(2, 11, h_gate())
    board:put(2, 12, x_gate())

    board:swap(1, 12)
    wait_swap_to_finish(board)

    local combo_callback = assert.spy(game.combo_callback)
    board:update(game)

    combo_callback.was_called(1)
    combo_callback.was_called_with(4, 2, 11, match._, match._, match._)
  end)

  it("5-コンボ発生でコールバックが呼ばれる", function()
    --    S            S <- 5-combo
    -- [Z H]         H Z
    --  H S  ----->  H S
    board:put(2, 10, s_gate())
    board:put(1, 11, z_gate())
    board:put(2, 11, h_gate())
    board:put(1, 12, h_gate())
    board:put(2, 12, s_gate())

    board:swap(1, 11)
    wait_swap_to_finish(board)

    local combo_callback = assert.spy(game.combo_callback)
    board:update(game)

    combo_callback.was_called(1)
    combo_callback.was_called_with(5, 2, 10, match._, match._, match._)
  end)

  it("6-コンボ発生でコールバックが呼ばれる", function()
    -- [S H]        H S <- 6-combo
    --  X Z         Z X
    --  H S  -----> H S
    board:put(1, 10, s_gate())
    board:put(2, 10, h_gate())
    board:put(1, 11, x_gate())
    board:put(2, 11, z_gate())
    board:put(1, 12, h_gate())
    board:put(2, 12, s_gate())

    board:swap(1, 10)
    wait_swap_to_finish(board)

    local combo_callback = assert.spy(game.combo_callback)
    board:update(game)

    combo_callback.was_called(1)
    combo_callback.was_called_with(6, 2, 10, match._, match._, match._)
  end)

  it("7-コンボ発生でコールバックが呼ばれる", function()
    --    T            T <- 7-combo
    --  H Z          H Z
    --  X S          X S
    -- [T H]  -----> H T
    board:put(2, 9, t_gate())
    board:put(1, 10, h_gate())
    board:put(2, 10, z_gate())
    board:put(1, 11, x_gate())
    board:put(2, 11, s_gate())
    board:put(1, 12, t_gate())
    board:put(2, 12, h_gate())

    board:swap(1, 12)
    wait_swap_to_finish(board)

    local combo_callback = assert.spy(game.combo_callback)
    board:update(game)

    combo_callback.was_called(1)
    combo_callback.was_called_with(7, 2, 9, match._, match._, match._)
  end)
end)
