require("engine/test/bustedhelper")
require("board")
require("gate")

describe('garbage_gate #solo', function()
  describe("おじゃまゲートのインスタンス生成", function()
    it("幅 (span) をセットできる", function()
      local garbage = garbage_gate(3)

      assert.are_equal(3, garbage.span)
    end)

    it("高さ (height) をセットできる", function()
      local garbage = garbage_gate(3, 4)

      assert.are_equal(4, garbage.height)
    end)
  end)

  describe("指定した座標がおじゃまゲートかどうかの判定", function()
    it("高さ 1 のおじゃまゲートに含まれる座標", function()
      local board = create_board()

      -- 13 行目の 1, 2, 3 列目はおじゃまゲートに含まれる
      --
      -- g g g _ _ _
      board:put(1, 13, garbage_gate(3, 1))

      assert.is_true(board:is_part_of_garbage(1, 13))
      assert.is_true(board:is_part_of_garbage(2, 13))
      assert.is_true(board:is_part_of_garbage(3, 13))
      assert.is_false(board:is_part_of_garbage(4, 13))
      assert.is_false(board:is_part_of_garbage(5, 13))
      assert.is_false(board:is_part_of_garbage(6, 13))
    end)
  end)

  describe("gate type", function()
    local garbage

    before_each(function()
      garbage = garbage_gate(1)
    end)

    describe("type", function()
      describe("is_i", function()
        it("should return false", function()
          assert.is_false(garbage:is_i())
        end)
      end)

      describe("is_garbage", function()
        it("should return true", function()
          assert.is_true(garbage:is_garbage())
        end)
      end)
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
