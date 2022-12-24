require("engine/test/bustedhelper")
require("test/test_helper")
require("lib/board")

local block = require("lib/block")

describe('ブロックの入れ替え', function()
  local board

  before_each(function()
    board = board_class()
  end)

  describe('フレーム数', function()
    it("入れ替えると状態が swapping になる", function()
      board:put(1, 16, block("h"))
      board:put(2, 16, block("x"))

      board:swap(1, 16)

      assert.is_true(board.blocks[1][16]:is_swapping())
    end)

    it("4 フレームで入れ替わる", function()
      board:put(1, 17, block("h"))
      board:put(2, 17, block("x"))

      -- swap 開始フレーム
      board:swap(1, 17)
      board:update()
      assert.is_true(board.blocks[1][17]:is_swapping())
      assert.is_true(board.blocks[2][17]:is_swapping())

      board:update()
      assert.is_true(board.blocks[1][17]:is_swapping())
      assert.is_true(board.blocks[2][17]:is_swapping())

      board:update()
      assert.is_true(board.blocks[1][17]:is_swapping())
      assert.is_true(board.blocks[2][17]:is_swapping())

      board:update()
      assert.is_true(board.blocks[1][17]:is_swapping())
      assert.is_true(board.blocks[2][17]:is_swapping())

      board:update()

      assert.is_true(board.blocks[1][17]:is_idle())
      assert.is_true(board.blocks[2][17]:is_idle())
    end)
  end)

  describe('I ブロックとの入れ替え', function()
    --
    -- [H ] (H と I を入れ換え)
    it("入れ替え中の I ブロックは empty でない", function()
      board:put(1, 16, block("h"))

      board:swap(1, 16)

      assert.is_false(board.blocks[2][16]:is_empty())
    end)
  end)
end)
