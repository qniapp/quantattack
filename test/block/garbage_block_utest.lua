require("engine/test/bustedhelper")
require("lib/helpers")
require("lib/board")

describe('garbage_block', function()
  describe('span', function()
    it("幅はデフォルトで 6", function()
      local garbage = garbage_block()

      assert.are.equal(6, garbage.span)
    end)

    it("幅 (span) を指定して生成", function()
      local garbage = garbage_block(3)

      assert.are.equal(3, garbage.span)
    end)

    it("幅を 2 以下に指定するとエラー", function()
      assert.has.errors(function() garbage_block(2) end)
    end)

    it("幅を 7 以上に指定するとエラー", function()
      assert.has.errors(function() garbage_block(7) end)
    end)
  end)

  describe('height', function()
    it("高さはデフォルトで 1", function()
      local garbage = garbage_block(3)

      assert.are.equal(1, garbage.height)
    end)

    it("高さ (height) を指定して生成", function()
      local garbage = garbage_block(3, 4)

      assert.are.equal(4, garbage.height)
    end)
  end)

  describe('body_color', function()
    it("色を指定して生成 (2, 3, 4)", function()
      local garbage

      garbage = garbage_block(6, 1, 2)
      assert.are.equal(2, garbage.body_color)

      garbage = garbage_block(6, 1, 3)
      assert.are.equal(3, garbage.body_color)

      garbage = garbage_block(6, 1, 4)
      assert.are.equal(4, garbage.body_color)
    end)

    it("色が正しくない場合エラー", function()
      assert.has.errors(function() garbage_block(3, 1, 0) end)
      assert.has.errors(function() garbage_block(3, 1, 1) end)
      assert.has.errors(function() garbage_block(3, 1, 5) end)
      assert.has.errors(function() garbage_block(3, 1, 6) end)
      assert.has.errors(function() garbage_block(3, 1, 7) end)
      assert.has.errors(function() garbage_block(3, 1, 8) end)
      assert.has.errors(function() garbage_block(3, 1, 9) end)
      assert.has.errors(function() garbage_block(3, 1, 10) end)
      assert.has.errors(function() garbage_block(3, 1, 11) end)
      assert.has.errors(function() garbage_block(3, 1, 12) end)
      assert.has.errors(function() garbage_block(3, 1, 13) end)
      assert.has.errors(function() garbage_block(3, 1, 14) end)
      assert.has.errors(function() garbage_block(3, 1, 15) end)
    end)

    it("色に応じて inner_border_color をセットする", function()
      assert.are.equal(14, garbage_block(6, 1, 2).inner_border_color)
      assert.are.equal(11, garbage_block(6, 1, 3).inner_border_color)
      assert.are.equal(9, garbage_block(6, 1, 4).inner_border_color)
    end)
  end)

  it("指定した幅と高さで board 上の位置を占有する", function()
    local board = board_class()

      -- _ _ _ _ _ _
      -- _ ■ ■ ■ _ _
      -- _ ■ ■ ■ _ _
      -- _ ■ ■ ■ _ _
      -- _ _ _ _ _ _
      board:put(2, 2, garbage_block(3, 3))

      -- 5 行目は空
      assert.is_true(board:is_empty(1, 5))
      assert.is_true(board:is_empty(2, 5))
      assert.is_true(board:is_empty(3, 5))
      assert.is_true(board:is_empty(4, 5))
      assert.is_true(board:is_empty(5, 5))
      assert.is_true(board:is_empty(6, 5))

      -- 4 行目は x = 1, 5, 6 のみ空
      assert.is_true(board:is_empty(1, 4))
      assert.is_false(board:is_empty(2, 4))
      assert.is_false(board:is_empty(3, 4))
      assert.is_false(board:is_empty(4, 4))
      assert.is_true(board:is_empty(5, 4))
      assert.is_true(board:is_empty(6, 4))

      -- 3 行目も x = 1, 5, 6 のみ空
      assert.is_true(board:is_empty(1, 3))
      assert.is_false(board:is_empty(2, 3))
      assert.is_false(board:is_empty(3, 3))
      assert.is_false(board:is_empty(4, 3))
      assert.is_true(board:is_empty(5, 3))
      assert.is_true(board:is_empty(6, 3))

      -- 2 行目も x = 1, 5, 6 のみ空
      assert.is_true(board:is_empty(1, 2))
      assert.is_false(board:is_empty(2, 2))
      assert.is_false(board:is_empty(3, 2))
      assert.is_false(board:is_empty(4, 2))
      assert.is_true(board:is_empty(5, 2))
      assert.is_true(board:is_empty(6, 2))

      -- 1 行目は空
      assert.is_true(board:is_empty(1, 1))
      assert.is_true(board:is_empty(2, 1))
      assert.is_true(board:is_empty(3, 1))
      assert.is_true(board:is_empty(4, 1))
      assert.is_true(board:is_empty(5, 1))
      assert.is_true(board:is_empty(6, 1))
  end)

  describe('render', function()
    it('おじゃまブロックの本体、影、内側の枠線を描画', function()
      local garbage = garbage_block(6, 1, 2)
      spy.on(garbage, "_render_box")

      garbage:render(50, 50)

      assert.spy(garbage._render_box).was.called(3)
    end)
  end)
end)
