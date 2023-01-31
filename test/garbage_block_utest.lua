require("engine/test/bustedhelper")
require("lib/helpers")
require("lib/board")

describe('garbage_block', function()
  describe('span', function()
    it("幅はデフォルトで 6", function()
      local garbage = garbage_block()

      assert.are_equal(6, garbage.span)
    end)

    it("幅 (span) を指定して生成", function()
      local garbage = garbage_block(3)

      assert.are_equal(3, garbage.span)
    end)

    it("幅を 2 以下に指定するとエラー", function()
      ---@diagnostic disable-next-line: param-type-mismatch
      assert.error(function() garbage_block(2) end)
    end)

    it("幅を 7 以上に指定するとエラー", function()
      ---@diagnostic disable-next-line: param-type-mismatch
      assert.error(function() garbage_block(7) end)
    end)
  end)

  describe('height', function()
    it("高さはデフォルトで 1", function()
      local garbage = garbage_block(3)

      assert.are_equal(1, garbage.height)
    end)

    it("高さ (height) を指定して生成", function()
      local garbage = garbage_block(3, 4)

      assert.are_equal(4, garbage.height)
    end)
  end)

  describe('body_color', function()
    it("色を指定して生成", function()
      local garbage = garbage_block(6, 1, 2)

      assert.are_equal(2, garbage.body_color)
    end)

    it("色が正しくない場合エラー", function()
      ---@diagnostic disable-next-line: param-type-mismatch
      assert.error(function() garbage_block(1) end)
    end)

    it("色に応じて inner_border_color をセットする", function()
      assert.are_equal(14, garbage_block(6, 1, 2).inner_border_color)
      assert.are_equal(11, garbage_block(6, 1, 3).inner_border_color)
      assert.are_equal(9, garbage_block(6, 1, 4).inner_border_color)
    end)
  end)

  describe('render', function()
    it('おじゃまブロックの本体、影、内側の枠線を描画', function()
      local garbage = garbage_block(6, 1, 2)
      spy.on(garbage, "_render_box")

      garbage:render(50, 50)

      ---@diagnostic disable-next-line: undefined-field
      assert.spy(garbage._render_box).was_called(3)
      ---@diagnostic disable-next-line: undefined-field
      assert.spy(garbage._render_box).was_called_with(51, 51, 95, 55, 14)
    end)
  end)
end)

describe("board", function()
  describe("_is_part_of_garbage", function()
    it("指定した座標がおじゃまブロックに含まれるかどうかを判定", function()
      local board = board_class()

      -- 行
      -- _ _ _ _ _ _
      -- _ g g g _ _
      -- _ g g g _ _
      -- _ g g g _ _
      -- _ _ _ _ _ _
      board:put(2, 2, garbage_block(3, 3))

      -- 5 行目
      assert.is_false(board:_is_part_of_garbage(1, 5))
      assert.is_false(board:_is_part_of_garbage(2, 5))
      assert.is_false(board:_is_part_of_garbage(3, 5))
      assert.is_false(board:_is_part_of_garbage(4, 5))
      assert.is_false(board:_is_part_of_garbage(5, 5))
      assert.is_false(board:_is_part_of_garbage(6, 5))

      -- 4 行目
      assert.is_false(board:_is_part_of_garbage(1, 4))
      assert.is_true(board:_is_part_of_garbage(2, 4))
      assert.is_true(board:_is_part_of_garbage(3, 4))
      assert.is_true(board:_is_part_of_garbage(4, 4))
      assert.is_false(board:_is_part_of_garbage(5, 4))
      assert.is_false(board:_is_part_of_garbage(6, 4))

      -- 3 行目
      assert.is_false(board:_is_part_of_garbage(1, 3))
      assert.is_true(board:_is_part_of_garbage(2, 3))
      assert.is_true(board:_is_part_of_garbage(3, 3))
      assert.is_true(board:_is_part_of_garbage(4, 3))
      assert.is_false(board:_is_part_of_garbage(5, 3))
      assert.is_false(board:_is_part_of_garbage(6, 3))

      -- 2 行目
      assert.is_false(board:_is_part_of_garbage(1, 2))
      assert.is_true(board:_is_part_of_garbage(2, 2))
      assert.is_true(board:_is_part_of_garbage(3, 2))
      assert.is_true(board:_is_part_of_garbage(4, 2))
      assert.is_false(board:_is_part_of_garbage(5, 2))
      assert.is_false(board:_is_part_of_garbage(6, 2))

      -- 1 行目
      assert.is_false(board:_is_part_of_garbage(1, 1))
      assert.is_false(board:_is_part_of_garbage(2, 1))
      assert.is_false(board:_is_part_of_garbage(3, 1))
      assert.is_false(board:_is_part_of_garbage(4, 1))
      assert.is_false(board:_is_part_of_garbage(5, 1))
      assert.is_false(board:_is_part_of_garbage(6, 1))
    end)
  end)
end)
