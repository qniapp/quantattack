---@diagnostic disable: lowercase-global

require("engine/test/bustedhelper")
require("test/test_helper")
require("lib/board")

describe('board:is_empty()', function()
  local board

  before_each(function()
    board = board_class()
  end)

  it("ブロックのない場所では true を返す", function()
    assert.is_true(board:is_empty(1, 1))
  end)

  it("ブロックのある場所では false を返す", function()
    board:put(1, 1, block_class("h"))
    assert.is_false(board:is_empty(1, 1))
  end)

  it("入れ替え中の場所では false を返す", function()
    board:put(2, 1, block_class("h"))
    board:swap(1, 1)
    assert.is_false(board:is_empty(1, 1))
  end)

  it("CNOT の上では false を返す", function()
    local control = block_class("control")
    control.other_x = 4
    board:put(1, 1, control)

    local cnot_x = block_class("cnot_x")
    cnot_x.other_x = 1
    board:put(4, 1, cnot_x)

    assert.is_false(board:is_empty(1, 1))
    assert.is_false(board:is_empty(2, 1))
    assert.is_false(board:is_empty(3, 1))
    assert.is_false(board:is_empty(4, 1))
  end)

  it("SWAP の上では false を返す", function()
    local swap_left = block_class("swap")
    swap_left.other_x = 4
    board:put(1, 1, swap_left)

    local swap_right = block_class("swap")
    swap_right.other_x = 1
    board:put(4, 1, swap_right)

    assert.is_false(board:is_empty(1, 1))
    assert.is_false(board:is_empty(2, 1))
    assert.is_false(board:is_empty(3, 1))
    assert.is_false(board:is_empty(4, 1))
  end)

  it("おじゃまブロックの上では false を返す", function()
    board:put(1, 1, garbage_block(3, 1))

    assert.is_false(board:is_empty(1, 1))
    assert.is_false(board:is_empty(2, 1))
    assert.is_false(board:is_empty(3, 1))
  end)
end)
