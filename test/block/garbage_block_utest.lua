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
  describe("_garbage_head_block", function()
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
      assert.is_false(board:_garbage_head_block(1, 5) ~= nil)
      assert.is_false(board:_garbage_head_block(2, 5) ~= nil)
      assert.is_false(board:_garbage_head_block(3, 5) ~= nil)
      assert.is_false(board:_garbage_head_block(4, 5) ~= nil)
      assert.is_false(board:_garbage_head_block(5, 5) ~= nil)
      assert.is_false(board:_garbage_head_block(6, 5) ~= nil)

      -- 4 行目
      assert.is_false(board:_garbage_head_block(1, 4) ~= nil)
      assert.is_true(board:_garbage_head_block(2, 4) ~= nil)
      assert.is_true(board:_garbage_head_block(3, 4) ~= nil)
      assert.is_true(board:_garbage_head_block(4, 4) ~= nil)
      assert.is_false(board:_garbage_head_block(5, 4) ~= nil)
      assert.is_false(board:_garbage_head_block(6, 4) ~= nil)

      -- 3 行目
      assert.is_false(board:_garbage_head_block(1, 3) ~= nil)
      assert.is_true(board:_garbage_head_block(2, 3) ~= nil)
      assert.is_true(board:_garbage_head_block(3, 3) ~= nil)
      assert.is_true(board:_garbage_head_block(4, 3) ~= nil)
      assert.is_false(board:_garbage_head_block(5, 3) ~= nil)
      assert.is_false(board:_garbage_head_block(6, 3) ~= nil)

      -- 2 行目
      assert.is_false(board:_garbage_head_block(1, 2) ~= nil)
      assert.is_true(board:_garbage_head_block(2, 2) ~= nil)
      assert.is_true(board:_garbage_head_block(3, 2) ~= nil)
      assert.is_true(board:_garbage_head_block(4, 2) ~= nil)
      assert.is_false(board:_garbage_head_block(5, 2) ~= nil)
      assert.is_false(board:_garbage_head_block(6, 2) ~= nil)

      -- 1 行目
      assert.is_false(board:_garbage_head_block(1, 1) ~= nil)
      assert.is_false(board:_garbage_head_block(2, 1) ~= nil)
      assert.is_false(board:_garbage_head_block(3, 1) ~= nil)
      assert.is_false(board:_garbage_head_block(4, 1) ~= nil)
      assert.is_false(board:_garbage_head_block(5, 1) ~= nil)
      assert.is_false(board:_garbage_head_block(6, 1) ~= nil)
    end)
  end)
end)
