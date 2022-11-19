require("engine/test/bustedhelper")
require("board")
require("garbage_gate")

describe('garbage_gate', function()
  describe('color', function()
    it("色を指定", function()
      local garbage = garbage_gate(2)

      assert.are_equal(2, garbage.color)
    end)

    it("色が正しくない場合エラー", function()
      ---@diagnostic disable-next-line: param-type-mismatch
      assert.error(function() garbage_gate(1) end)
    end)

    it("色に応じて inner_border_color をセットする", function()
      assert.are_equal(14, garbage_gate(2).inner_border_color)
      assert.are_equal(11, garbage_gate(3).inner_border_color)
      assert.are_equal(9, garbage_gate(4).inner_border_color)
    end)
  end)

  describe('span', function()
    it("幅はデフォルトで 6", function()
      local garbage = garbage_gate(2)

      assert.are_equal(6, garbage.span)
    end)

    it("幅 (span) を指定", function()
      local garbage = garbage_gate(2, 3)

      assert.are_equal(3, garbage.span)
    end)

    it("幅は 2 以下に指定できない", function()
      ---@diagnostic disable-next-line: param-type-mismatch
      assert.error(function() garbage_gate(2, 2) end)
    end)

    it("幅は 7 以上に指定できない", function()
      ---@diagnostic disable-next-line: param-type-mismatch
      assert.error(function() garbage_gate(2, 7) end)
    end)
  end)

  describe('height', function()
    it("高さはデフォルトで 1", function()
      local garbage = garbage_gate(2, 3)

      assert.are_equal(1, garbage.height)
    end)

    it("高さ (height) を指定", function()
      local garbage = garbage_gate(2, 3, 4)

      assert.are_equal(4, garbage.height)
    end)

    it("高さは 1 未満に指定できない", function()
      assert.error(function() garbage_gate(2, 3, 0) end)
    end)
  end)
end)

describe("board", function()
  describe("_is_part_of_garbage", function()
    it("指定した座標がおじゃまゲートに含まれるかどうかを判定", function()
      local board = create_board()

      -- 行
      --  9 _ _ _ _ _ _
      -- 10 _ g g g _ _
      -- 11 _ g g g _ _
      -- 12 _ g g g _ _
      -- 13 _ _ _ _ _ _
      board:put(2, 12, garbage_gate(2, 3, 3))

      -- 9 行目
      assert.is_false(board:_is_part_of_garbage(1, 9))
      assert.is_false(board:_is_part_of_garbage(2, 9))
      assert.is_false(board:_is_part_of_garbage(3, 9))
      assert.is_false(board:_is_part_of_garbage(4, 9))
      assert.is_false(board:_is_part_of_garbage(5, 9))
      assert.is_false(board:_is_part_of_garbage(6, 9))

      -- 10 行目
      assert.is_false(board:_is_part_of_garbage(1, 10))
      assert.is_true(board:_is_part_of_garbage(2, 10))
      assert.is_true(board:_is_part_of_garbage(3, 10))
      assert.is_true(board:_is_part_of_garbage(4, 10))
      assert.is_false(board:_is_part_of_garbage(5, 10))
      assert.is_false(board:_is_part_of_garbage(6, 10))

      -- 11 行目
      assert.is_false(board:_is_part_of_garbage(1, 11))
      assert.is_true(board:_is_part_of_garbage(2, 11))
      assert.is_true(board:_is_part_of_garbage(3, 11))
      assert.is_true(board:_is_part_of_garbage(4, 11))
      assert.is_false(board:_is_part_of_garbage(5, 11))
      assert.is_false(board:_is_part_of_garbage(6, 11))

      -- 12 行目
      assert.is_false(board:_is_part_of_garbage(1, 12))
      assert.is_true(board:_is_part_of_garbage(2, 12))
      assert.is_true(board:_is_part_of_garbage(3, 12))
      assert.is_true(board:_is_part_of_garbage(4, 12))
      assert.is_false(board:_is_part_of_garbage(5, 12))
      assert.is_false(board:_is_part_of_garbage(6, 12))

      -- 13 行目
      assert.is_false(board:_is_part_of_garbage(1, 13))
      assert.is_false(board:_is_part_of_garbage(2, 13))
      assert.is_false(board:_is_part_of_garbage(3, 13))
      assert.is_false(board:_is_part_of_garbage(4, 13))
      assert.is_false(board:_is_part_of_garbage(5, 13))
      assert.is_false(board:_is_part_of_garbage(6, 13))
    end)
  end)
end)
