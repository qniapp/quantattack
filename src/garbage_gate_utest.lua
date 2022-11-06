require("engine/test/bustedhelper")
require("board")
require("gate")

describe('おじゃまゲート #solo', function()
  describe("インスタンス生成", function()
    it("幅 (span) をセットできる", function()
      local garbage = garbage_gate(3)

      assert.are_equal(3, garbage.span)
    end)

    it("高さ (height) をセットできる", function()
      local garbage = garbage_gate(3, 4)

      assert.are_equal(4, garbage.height)
    end)
  end)

  describe("判定", function()
    it("おじゃまゲートであるかどうかの判定", function()
      local garbage = garbage_gate(1)

      assert.is_true(garbage:is_garbage())
    end)

    it("指定した座標がおじゃまゲートに含まれるかどうかを判定", function()
      local board = create_board()

      -- 行
      --  9 _ _ _ _ _ _
      -- 10 _ g g g _ _
      -- 11 _ g g g _ _
      -- 12 _ g g g _ _
      -- 13 _ _ _ _ _ _
      board:put(2, 12, garbage_gate(3, 3))

      -- 9 行目
      assert.is_false(board:is_part_of_garbage(1, 9))
      assert.is_false(board:is_part_of_garbage(2, 9))
      assert.is_false(board:is_part_of_garbage(3, 9))
      assert.is_false(board:is_part_of_garbage(4, 9))
      assert.is_false(board:is_part_of_garbage(5, 9))
      assert.is_false(board:is_part_of_garbage(6, 9))

      -- 10 行目
      assert.is_false(board:is_part_of_garbage(1, 10))
      assert.is_true(board:is_part_of_garbage(2, 10))
      assert.is_true(board:is_part_of_garbage(3, 10))
      assert.is_true(board:is_part_of_garbage(4, 10))
      assert.is_false(board:is_part_of_garbage(5, 10))
      assert.is_false(board:is_part_of_garbage(6, 10))

      -- 11 行目
      assert.is_false(board:is_part_of_garbage(1, 11))
      assert.is_true(board:is_part_of_garbage(2, 11))
      assert.is_true(board:is_part_of_garbage(3, 11))
      assert.is_true(board:is_part_of_garbage(4, 11))
      assert.is_false(board:is_part_of_garbage(5, 11))
      assert.is_false(board:is_part_of_garbage(6, 11))

      -- 12 行目
      assert.is_false(board:is_part_of_garbage(1, 12))
      assert.is_true(board:is_part_of_garbage(2, 12))
      assert.is_true(board:is_part_of_garbage(3, 12))
      assert.is_true(board:is_part_of_garbage(4, 12))
      assert.is_false(board:is_part_of_garbage(5, 12))
      assert.is_false(board:is_part_of_garbage(6, 12))

      -- 13 行目
      assert.is_false(board:is_part_of_garbage(1, 13))
      assert.is_false(board:is_part_of_garbage(2, 13))
      assert.is_false(board:is_part_of_garbage(3, 13))
      assert.is_false(board:is_part_of_garbage(4, 13))
      assert.is_false(board:is_part_of_garbage(5, 13))
      assert.is_false(board:is_part_of_garbage(6, 13))
    end)
  end)

  describe("state", function()
    local garbage

    before_each(function()
      garbage = garbage_gate(1)
    end)

    describe("is_idle", function()
      it("should return true", function()
        assert.is_true(garbage:is_idle())
      end)
    end)

    describe("is_swapping", function()
      it("should return false", function()
        assert.is_false(garbage:is_swapping())
      end)
    end)

    describe("is_falling", function()
      it("should return false", function()
        assert.is_false(garbage:is_falling())
      end)
    end)

    describe("is_match", function()
      it("should return false", function()
        assert.is_false(garbage:is_match())
      end)
    end)
  end)
end)
