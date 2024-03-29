require("engine/test/bustedhelper")
require("test/test_helper")
require("lib/helpers")
require("lib/game")
require("lib/effects")
require("lib/board")

describe('コンボ (同時消し) のコールバック', function()
  local board
  local match = require("luassert.match")
  local _ = match._

  before_each(function()
    board = board_class()
    stub(game_class, "combo_callback")
  end)

  it("4-コンボ発生でコールバックが呼ばれる", function()
    -- [X H]         H X <- 4-combo
    --  H X  ----->  H X
    board:put(1, 2, block_class("x"))
    board:put(1, 1, block_class("h"))
    board:put(2, 2, block_class("h"))
    board:put(2, 1, block_class("x"))

    board:swap(1, 1)
    wait_swap_to_finish(board)

    local combo_callback = assert.spy(game_class.combo_callback)
    board:update(game_class)

    combo_callback.was_called(1)
    combo_callback.was_called_with(4, { board:screen_x(2), board:screen_y(2) }, _, _, _)
  end)

  it("5-コンボ発生でコールバックが呼ばれる", function()
    --    S            S
    -- [Z H]         H Z
    --  H S  ----->  H S
    board:put(2, 3, block_class("s"))
    board:put(1, 2, block_class("z"))
    board:put(2, 2, block_class("h"))
    board:put(1, 1, block_class("h"))
    board:put(2, 1, block_class("s"))

    board:swap(1, 2)
    wait_swap_to_finish(board)

    local combo_callback = assert.spy(game_class.combo_callback)
    board:update(game_class)

    combo_callback.was_called(1)
    combo_callback.was_called_with(5, { board:screen_x(1), board:screen_y(2) }, _, _, _)
  end)

  it("6-コンボ発生でコールバックが呼ばれる", function()
    -- [S H]        H S <- 6-combo
    --  X Z         Z Z
    --  H S  -----> H S
    board:put(1, 3, block_class("s"))
    board:put(2, 3, block_class("h"))
    board:put(1, 2, block_class("x"))
    board:put(2, 2, block_class("z"))
    board:put(1, 1, block_class("h"))
    board:put(2, 1, block_class("s"))

    board:swap(1, 3)
    wait_swap_to_finish(board)

    local combo_callback = assert.spy(game_class.combo_callback)
    board:update(game_class)

    combo_callback.was_called(1)
    combo_callback.was_called_with(6, { board:screen_x(2), board:screen_y(3) }, _, _, _)
  end)

  it("7-コンボ発生でコールバックが呼ばれる", function()
    --    T            T
    --  H Z          H Z
    --  X S          X S
    -- [T H]  -----> H T
    board:put(2, 4, block_class("t"))
    board:put(1, 3, block_class("h"))
    board:put(2, 3, block_class("z"))
    board:put(1, 2, block_class("x"))
    board:put(2, 2, block_class("s"))
    board:put(1, 1, block_class("t"))
    board:put(2, 1, block_class("h"))

    board:swap(1, 1)
    wait_swap_to_finish(board)

    local combo_callback = assert.spy(game_class.combo_callback)
    board:update(game_class)

    combo_callback.was_called(1)
    combo_callback.was_called_with(7, { board:screen_x(1), board:screen_y(3) }, _, _, _)
  end)
end)
