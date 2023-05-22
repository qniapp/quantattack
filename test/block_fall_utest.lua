require("engine/test/bustedhelper")
require("engine/render/color")
require("test/test_helper")
require("lib/effects")
require("lib/board")

describe('ブロックの落下', function()
  local board

  before_each(function()
    board = board_class()
  end)

  describe('ブロックが 1 つだけ落ちる', function()
    local block

    before_each(function()
      block = block_class("h")
    end)

    it("状態が hover になる", function()
      board:put(1, 2, block)

      board:update()

      assert.is_true(block.state == "hover")
    end)

    it("1 フレームで 1 ブロック落下する", function()
      board:put(1, 2, block)

      -- hover 状態に遷移
      board:update()

      for i = 1, 12 do
        board:update()
      end

      -- fall 状態に遷移
      board:update()

      assert.is_true(block.state == "fall")
      assert.are.equal("h", board:block_at(1, 1).type)
    end)

    it("着地後 1 フレームで状態が idle になる", function()
      board:put(1, 2, block)

      board:update()

      for i = 1, 12 do
        board:update()
      end

      board:update()
      board:update()

      assert.is_true(block.state == "idle")
    end)
  end)

  describe('ブロックが 2 つ積み重なったまま落ちる', function()
    local block1, block2

    before_each(function()
      block1 = block_class("h")
      block2 = block_class("x")
    end)

    it("状態が hover になる", function()
      board:put(1, 3, block1)
      board:put(1, 2, block2)

      board:update()

      assert.is_true(block1.state == "hover")
      assert.is_true(block2.state == "hover")
    end)

    it("1 フレームで 1 ブロック落下する", function()
      board:put(1, 3, block1)
      board:put(1, 2, block2)

      -- hover 状態に遷移
      board:update()

      -- hover が 12 フレーム続く
      assert.is_true(board:block_at(1, 3).state == "hover")
      assert.is_true(board:block_at(1, 2).state == "hover")

      for i = 1, 12 do
        board:update()

        assert.is_true(board:block_at(1, 3).state == "hover")
        assert.is_true(board:block_at(1, 2).state == "hover")
      end

      -- fall 状態に遷移
      board:update()

      assert.is_true(board:block_at(1, 2).state == "fall")
      assert.is_true(board:block_at(1, 1).state == "fall")

      assert.are.equal("h", board:block_at(1, 2).type)
      assert.are.equal("x", board:block_at(1, 1).type)
    end)

    it("着地後 1 フレームで状態が idle になる", function()
      board:put(1, 3, block1)
      board:put(1, 2, block2)

      board:update()

      for i = 1, 12 do
        board:update()
      end

      board:update()
      board:update()

      assert.is_true(block1.state == "idle")
      assert.is_true(block2.state == "idle")
    end)
  end)

  describe('CNOT が落ちる', function()
    local control, cnot_x

    -- C-X
    before_each(function()
      control = control_block(2)
      cnot_x = cnot_x_block(1)
    end)

    it("状態が fall になる", function()
      board:put(1, 2, control)
      board:put(2, 2, cnot_x)

      board:update()

      for i = 1, 12 do
        board:update()
      end

      board:update()

      assert.is_true(control.state == "fall")
      assert.is_true(cnot_x.state == "fall")
    end)

    it("1 フレームで 1 ブロック落下する", function()
      board:put(1, 2, control)
      board:put(2, 2, cnot_x)

      board:update()

      for i = 1, 12 do
        board:update()
      end

      board:update()

      assert.is_true(control.state == "fall")
      assert.is_true(cnot_x.state == "fall")
      assert.are.equal(control, board:block_at(1, 1))
      assert.are.equal(cnot_x, board:block_at(2, 1))
    end)

    it("着地後 1 フレームで状態が idle になる", function()
      board:put(1, 2, control)
      board:put(2, 2, cnot_x)

      board:update()

      for i = 1, 12 do
        board:update()
      end

      board:update()
      board:update()

      assert.is_true(control.state == "idle")
      assert.is_true(cnot_x.state == "idle")
    end)
  end)

  describe('SWAP ブロックが落ちる', function()
    local swap_left, swap_right

    before_each(function()
      swap_left = swap_block(2)
      swap_right = swap_block(1)
    end)

    it("状態が fall になる", function()
      board:put(1, 2, swap_left)
      board:put(2, 2, swap_right)

      board:update()

      for i = 1, 12 do
        board:update()
      end

      board:update()

      assert.is_true(swap_left.state == "fall")
      assert.is_true(swap_right.state == "fall")
    end)

    it("1 フレームで 1 ブロック落下する", function()
      board:put(1, 2, swap_left)
      board:put(2, 2, swap_right)

      board:update()

      for i = 1, 12 do
        board:update()
      end

      board:update()

      assert.is_true(swap_left.state == "fall")
      assert.is_true(swap_right.state == "fall")
      assert.are.equal(swap_left, board:block_at(1, 1))
      assert.are.equal(swap_right, board:block_at(2, 1))
    end)

    it("着地後 1 フレームで状態が idle になる", function()
      board:put(1, 2, swap_left)
      board:put(2, 2, swap_right)

      board:update()

      for i = 1, 12 do
        board:update()
      end

      board:update()
      board:update()

      assert.is_true(swap_left.state == "idle")
      assert.is_true(swap_right.state == "idle")
    end)

    it('下のブロックをずらして落とす', function()
      --
      -- S-S  --->  S-S    --->
      --   H            H        S-S H
      board:put(1, 2, swap_left)
      board:put(2, 2, swap_right)
      board:put(2, 1, block_class("h"))

      board:swap(2, 1)

      -- swap が 3 フレーム
      board:update()
      board:update()
      board:update()

      board:update()

      -- hover 状態
      for i = 1, 12 do
        board:update()
      end

      board:update()
      board:update()

      assert.are.equal(swap_left, board:block_at(1, 1))
      assert.are.equal(swap_right, board:block_at(2, 1))
      assert.is_true(swap_left.state == "idle")
      assert.is_true(swap_right.state == "idle")
    end)
  end)

  describe('おじゃまブロックが落ちる', function()
    local garbage

    before_each(function()
      garbage = garbage_block(3, 3)
    end)

    it("状態が fall になる", function()
      board:put(1, 2, garbage)

      board:update()

      for i = 1, 12 do
        board:update()
      end

      board:update()

      assert.is_true(garbage.state == "fall")
    end)

    it("1 フレームで 1 ブロック落下する", function()
      board:put(1, 2, garbage)

      board:update()

      for i = 1, 12 do
        board:update()
      end

      board:update()

      assert.is_true(garbage.state == "fall")
      assert.are.equal(garbage, board:block_at(1, 1))
    end)

    it("着地後 1 フレームで状態が idle になる", function()
      board:put(1, 2, garbage)

      board:update()

      for i = 1, 12 do
        board:update()
      end

      board:update()
      board:update()

      assert.is_true(garbage.state == "idle")
    end)
  end)
end)
