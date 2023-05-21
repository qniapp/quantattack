require("engine/test/bustedhelper")
require("engine/render/color")
require("test/test_helper")
require("lib/effects")
require("lib/board")


describe('CNOT や SWAP が残る/ちぎれる問題', function()
  local board

  before_each(function()
    board = board_class()
  end)

  it("マッチ中のブロックは落下しない", function()
    board:put(3, 3, cnot_x_block(5))
    board:put(5, 3, control_block(3))
    board:put(3, 2, cnot_x_block(4))
    board:put(4, 2, control_block(3))
    board:put(1, 1, cnot_x_block(4))
    board:put(4, 1, control_block(1))

    board:swap(4, 3)

    board:update()

    board:swap(3, 1)

    for _i = 0, 67 do
      board:update()
    end

    board:swap(2, 1)

    for _i = 61, 73 do
      board:update()
    end

    assert.are_equal("i", board:block_at(3, 1).type)
    assert.are_equal("i", board:block_at(4, 1).type)
  end)
end)
