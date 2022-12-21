require("engine/test/bustedhelper")
require("engine/render/color")
require("lib/test_helper")

local board_class = require("lib/board")

describe('ゲートの落下', function()
  local board

  before_each(function()
    board = board_class()
  end)

  describe('ゲートが 1 つだけ落ちる', function()
    local block

    before_each(function()
      block = h_block()
    end)

    it("状態が falling になる", function()
      board:put(1, 15, block)

      board:update()

      assert.is_true(block:is_falling())
    end)

    it("4 フレームで 1 ゲートほど落下する", function()
      board:put(1, 15, block)

      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(block:is_falling())
      assert.are_equal(block, board.blocks[1][16])
    end)

    it("着地後 1 フレームで状態が idle になる", function()
      board:put(1, 16, block)

      board:update()
      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(block:is_idle())
    end)
  end)

  describe('ゲートが 2 つ積み重なったまま落ちる', function()
    local block1, block2

    before_each(function()
      block1 = h_block()
      block2 = x_block()
    end)

    it("状態が falling になる", function()
      board:put(1, 14, block1)
      board:put(1, 15, block2)

      board:update()

      assert.is_true(block1:is_falling())
      assert.is_true(block2:is_falling())
    end)

    it("4 フレームで 1 ゲートほど落下する", function()
      board:put(1, 14, block1)
      board:put(1, 15, block2)

      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(block1:is_falling())
      assert.is_true(block2:is_falling())
      assert.are_equal(block1, board.blocks[1][15])
      assert.are_equal(block2, board.blocks[1][16])
    end)

    it("着地後 1 フレームで状態が idle になる", function()
      board:put(1, 15, block1)
      board:put(1, 16, block2)

      board:update()
      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(block1:is_idle())
      assert.is_true(block2:is_idle())
    end)
  end)

  describe('CNOT が落ちる', function()
    local control, cnot_x

    -- C-X
    before_each(function()
      control = control_block(2)
      cnot_x = cnot_x_block(1)
    end)

    it("状態が falling になる", function()
      board:put(1, 15, control)
      board:put(2, 15, cnot_x)

      board:update()

      assert.is_true(control:is_falling())
      assert.is_true(cnot_x:is_falling())
    end)

    it("4 フレームで 1 ゲートほど落下する", function()
      board:put(1, 15, control)
      board:put(2, 15, cnot_x)

      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(control:is_falling())
      assert.is_true(cnot_x:is_falling())
      assert.are_equal(control, board.blocks[1][16])
      assert.are_equal(cnot_x, board.blocks[2][16])
    end)

    it("着地後 1 フレームで状態が idle になる", function()
      board:put(1, 16, control)
      board:put(2, 16, cnot_x)

      board:update()
      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(control:is_idle())
      assert.is_true(cnot_x:is_idle())
    end)
  end)

  describe('SWAP ゲートが落ちる', function()
    local swap_left, swap_right

    before_each(function()
      swap_left = swap_block(2)
      swap_right = swap_block(1)
    end)

    it("状態が falling になる", function()
      board:put(1, 15, swap_left)
      board:put(2, 15, swap_right)

      board:update()

      assert.is_true(swap_left:is_falling())
      assert.is_true(swap_right:is_falling())
    end)

    it("4 フレームで 1 ゲートほど落下する", function()
      board:put(1, 15, swap_left)
      board:put(2, 15, swap_right)

      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(swap_left:is_falling())
      assert.is_true(swap_right:is_falling())
      assert.are_equal(swap_left, board.blocks[1][16])
      assert.are_equal(swap_right, board.blocks[2][16])
    end)

    it("着地後 1 フレームで状態が idle になる", function()
      board:put(1, 16, swap_left)
      board:put(2, 16, swap_right)

      board:update()
      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(swap_left:is_idle())
      assert.is_true(swap_right:is_idle())
    end)

    it('下のゲートをずらして落とす', function()
      --
      -- S-S  --->  S-S    --->
      --   H            H        S-S H
      board:put(1, 16, swap_left)
      board:put(2, 16, swap_right)
      board:put(2, 17, h_block())

      board:swap(2, 17)

      -- swap が 4 フレーム
      board:update()
      board:update()
      board:update()
      board:update()

      -- 4 フレームでひとつ下に落ち idle 状態に
      board:update()
      board:update()
      board:update()
      board:update()
      board:update()

      assert.are_equal(swap_left, board.blocks[1][17])
      assert.are_equal(swap_right, board.blocks[2][17])
      assert.is_true(swap_left:is_idle())
      assert.is_true(swap_right:is_idle())
    end)
  end)

  describe('おじゃまゲートが落ちる', function()
    local garbage

    before_each(function()
      garbage = garbage_block(3)
    end)

    it("状態が falling になる", function()
      board:put(1, 15, garbage)

      board:update()

      assert.is_true(garbage:is_falling())
    end)

    it("4 フレームで 1 ゲートほど落下する", function()
      board:put(1, 15, garbage)

      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(garbage:is_falling())
      assert.are_equal(garbage, board.blocks[1][16])
    end)

    it("着地後 1 フレームで状態が idle になる", function()
      board:put(1, 16, garbage)

      board:update()
      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(garbage:is_idle())
    end)
  end)
end)
