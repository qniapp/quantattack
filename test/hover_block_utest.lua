require("engine/test/bustedhelper")
require("engine/render/color")
require("test/test_helper")
require("lib/board")
require("lib/block")

describe('ブロックの hover 状態', function()
  local board

  before_each(function()
    board = board_class()
  end)

  describe('単一ブロックの下が空の場合', function()
    local block

    before_each(function()
      block = block_class("h")
    end)

    it("状態が hover になる", function()
      board:put(1, 16, block)

      board:update()

      assert.is_true(block:is_hover())
    end)

    it("hover 状態は 12 フレーム継続する", function()
      board:put(1, 16, block)

      -- hover 状態に遷移
      board:update()

      for i = 1, 12 do
        board:update()

        assert.is_true(block:is_hover())
      end

      -- falling 状態に遷移
      board:update()

      assert.is_true(block:is_falling())
    end)
  end)

  describe('2 つ積み重なったブロックの下が空の場合', function()
    local block1, block2

    before_each(function()
      block1 = block_class("h")
      block2 = block_class("x")
    end)

    it("状態が hover になる", function()
      board:put(1, 15, block1)
      board:put(1, 16, block2)

      board:update()

      assert.is_true(block1:is_hover())
      assert.is_true(block2:is_hover())
    end)

    it("hover 状態は 12 フレーム継続する", function()
      board:put(1, 14, block1)
      board:put(1, 15, block2)

      -- hover 状態に遷移
      board:update()

      -- hover が 12 フレーム続く
      for i = 1, 12 do
        board:update()

        assert.is_true(board.blocks[1][14]:is_hover())
        assert.is_true(board.blocks[1][15]:is_hover())
      end

      -- falling 状態に遷移
      board:update()

      assert.is_true(board.blocks[1][15]:is_falling())
      assert.is_true(board.blocks[1][16]:is_falling())
    end)
  end)

  describe('CNOT の下が空の場合', function()
    local control, cnot_x

    before_each(function()
      control = control_block(2)
      cnot_x = cnot_x_block(1)
    end)

    it("状態が hover になる", function()
      board:put(1, 15, control)
      board:put(2, 15, cnot_x)

      board:update()

      assert.is_true(control:is_hover())
      assert.is_true(cnot_x:is_hover())
    end)

    it("hover 状態は 12 フレーム継続する", function()
      board:put(1, 15, control)
      board:put(2, 15, cnot_x)

      -- hover 状態に遷移
      board:update()

      for i = 1, 12 do
        board:update()

        assert.is_true(control:is_hover())
        assert.is_true(cnot_x:is_hover())
      end

      -- falling 状態に遷移
      board:update()

      assert.is_true(control:is_falling())
      assert.is_true(cnot_x:is_falling())
    end)
  end)

  describe('SWAP の下が空の場合', function()
    local swap_left, swap_right

    before_each(function()
      swap_left = swap_block(2)
      swap_right = swap_block(1)
    end)

    it("状態が hover になる", function()
      board:put(1, 15, swap_left)
      board:put(2, 15, swap_right)

      board:update()

      assert.is_true(swap_left:is_hover())
      assert.is_true(swap_right:is_hover())
    end)

    it("hover 状態は 12 フレーム継続する", function()
      board:put(1, 15, swap_left)
      board:put(2, 15, swap_right)

      -- hover 状態に遷移
      board:update()

      for i = 1, 12 do
        board:update()

        assert.is_true(swap_left:is_hover())
        assert.is_true(swap_right:is_hover())
      end

      -- falling 状態に遷移
      board:update()

      assert.is_true(swap_left:is_falling())
      assert.is_true(swap_right:is_falling())
    end)
  end)

  describe('おじゃまブロックの下が空の場合', function()
    local garbage

    before_each(function()
      garbage = garbage_block(3)
    end)

    it("状態が falling になる", function()
      board:put(1, 16, garbage)

      board:update()

      assert.is_true(garbage:is_hover())
    end)

    it("hover 状態は 12 フレーム継続する", function()
      board:put(1, 16, garbage)

      -- hover 状態に遷移
      board:update()

      for i = 1, 12 do
        board:update()
      end

      -- falling 状態に遷移
      board:update()

      assert.is_true(garbage:is_falling())
    end)
  end)

  describe('2 つ積み重なったおじゃまブロックの下が空の場合', function()
    local garbage1, garbage2

    before_each(function()
      garbage1 = garbage_block(3)
      garbage2 = garbage_block(3)
    end)

    it("両方のおじゃまブロックとも状態が hover になる", function()
      board:put(1, 15, garbage1)
      board:put(1, 16, garbage2)

      board:update()

      assert.is_true(garbage1:is_hover())
      assert.is_true(garbage2:is_hover())
    end)

    it("hover 状態は 12 フレーム継続する", function()
      board:put(1, 15, garbage1)
      board:put(1, 16, garbage2)

      -- hover 状態に遷移
      board:update()

      for i = 1, 12 do
        board:update()
      end

      -- falling 状態に遷移
      board:update()

      assert.is_true(garbage1:is_falling())
      assert.is_true(garbage2:is_falling())
    end)
  end)
end)
