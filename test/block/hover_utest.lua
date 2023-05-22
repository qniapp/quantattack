require("engine/test/bustedhelper")
require("test/test_helper")
require("lib/board")

describe('ブロックの hover 状態', function()
  local board

  before_each(function()
    board = board_class()
  end)

  describe('ブロックの下が空の場合', function()
    local block

    before_each(function()
      block = block_class("h")
    end)

    it("ブロックの状態が hover になる", function()
      board:put(1, 2, block)

      board:update()

      assert.are.equal("hover", block.state)
    end)

    it("hover 状態は 12 フレーム継続する", function()
      board:put(1, 2, block)

      -- hover 状態に遷移
      board:update()

      for i = 1, 12 do
        board:update()

        assert.are.equal("hover", block.state)
      end

      -- fall 状態に遷移
      board:update()

      assert.are.equal("fall", block.state)
    end)
  end)

  describe('2 つ積み重なったブロックの下が空の場合', function()
    local block1, block2

    before_each(function()
      block1 = block_class("h")
      block2 = block_class("x")
    end)

    it("状態が hover になる", function()
      board:put(1, 3, block1)
      board:put(1, 2, block2)

      board:update()

      assert.are.equal("hover", block1.state)
      assert.are.equal("hover", block2.state)
    end)

    it("hover 状態は 12 フレーム継続する", function()
      board:put(1, 3, block1)
      board:put(1, 2, block2)

      -- hover 状態に遷移
      board:update()

      -- hover が 12 フレーム続く
      for i = 1, 12 do
        board:update()

        assert.are.equal("hover", board:block_at(1, 3).state)
        assert.are.equal("hover", board:block_at(1, 2).state)
      end

      -- fall 状態に遷移
      board:update()

      assert.are.equal("fall", board:block_at(1, 2).state)
      assert.are.equal("fall", board:block_at(1, 1).state)
    end)
  end)

  describe('CNOT の下が空の場合', function()
    local control, cnot_x

    before_each(function()
      control = control_block(2)
      cnot_x = cnot_x_block(1)
    end)

    it("状態が hover になる", function()
      board:put(1, 2, control)
      board:put(2, 2, cnot_x)

      board:update()

      assert.are.equal("hover", control.state)
      assert.are.equal("hover", cnot_x.state)
    end)

    it("hover 状態は 12 フレーム継続する", function()
      board:put(1, 2, control)
      board:put(2, 2, cnot_x)

      -- hover 状態に遷移
      board:update()

      for i = 1, 12 do
        board:update()

        assert.are.equal("hover", control.state)
        assert.are.equal("hover", cnot_x.state)
      end

      -- fall 状態に遷移
      board:update()

      assert.are.equal("fall", control.state)
      assert.are.equal("fall", cnot_x.state)
    end)
  end)

  describe('2 つ積み重なった CNOT の下が空の場合', function()
    local control1, cnot_x1, control2, cnot_x2

    before_each(function()
      control1 = control_block(2)
      cnot_x1 = cnot_x_block(1)
      control2 = control_block(1)
      cnot_x2 = cnot_x_block(2)
    end)

    it("両方のおじゃまブロックとも状態が hover になる", function()
      board:put(1, 3, control1)
      board:put(2, 3, cnot_x1)
      board:put(1, 2, cnot_x2)
      board:put(2, 2, control2)

      board:update()

      assert.are.equal("hover", control1.state)
      assert.are.equal("hover", cnot_x1.state)
      assert.are.equal("hover", control2.state)
      assert.are.equal("hover", cnot_x2.state)
    end)

    it("hover 状態は 12 フレーム継続する", function()
      board:put(1, 3, control1)
      board:put(2, 3, cnot_x1)
      board:put(1, 2, cnot_x2)
      board:put(2, 2, control2)

      -- hover 状態に遷移
      board:update()

      for i = 1, 12 do
        board:update()

        assert.are.equal("hover", control1.state)
        assert.are.equal("hover", cnot_x1.state)
        assert.are.equal("hover", control2.state)
        assert.are.equal("hover", cnot_x2.state)
      end

      -- fall 状態に遷移
      board:update()

      assert.are.equal("fall", control1.state)
      assert.are.equal("fall", cnot_x1.state)
      assert.are.equal("fall", control2.state)
      assert.are.equal("fall", cnot_x2.state)
    end)
  end)

  describe('SWAP の下が空の場合', function()
    local swap_left, swap_right

    before_each(function()
      swap_left = swap_block(2)
      swap_right = swap_block(1)
    end)

    it("状態が hover になる", function()
      board:put(1, 2, swap_left)
      board:put(2, 2, swap_right)

      board:update()

      assert.are.equal("hover", swap_left.state)
      assert.are.equal("hover", swap_right.state)
    end)

    it("hover 状態は 12 フレーム継続する", function()
      board:put(1, 2, swap_left)
      board:put(2, 2, swap_right)

      -- hover 状態に遷移
      board:update()

      for i = 1, 12 do
        board:update()

        assert.are.equal("hover", swap_left.state)
        assert.are.equal("hover", swap_right.state)
      end

      -- fall 状態に遷移
      board:update()

      assert.are.equal("fall", swap_left.state)
      assert.are.equal("fall", swap_right.state)
    end)
  end)

  describe('2 つ積み重なった SWAP の下が空の場合', function()
    local swap_left1, swap_right1, swap_left2, swap_right2

    before_each(function()
      swap_left1 = swap_block(2)
      swap_right1 = swap_block(1)
      swap_left2 = swap_block(3)
      swap_right2 = swap_block(1)
    end)

    it("両方のおじゃまブロックとも状態が hover になる", function()
      board:put(1, 3, swap_left1)
      board:put(2, 3, swap_right1)
      board:put(1, 2, swap_left2)
      board:put(3, 2, swap_right2)

      board:update()

      assert.are.equal("hover", swap_left1.state)
      assert.are.equal("hover", swap_right1.state)
      assert.are.equal("hover", swap_left2.state)
      assert.are.equal("hover", swap_right2.state)
    end)

    it("hover 状態は 12 フレーム継続する", function()
      board:put(1, 3, swap_left1)
      board:put(2, 3, swap_right1)
      board:put(1, 2, swap_left2)
      board:put(3, 2, swap_right2)

      -- hover 状態に遷移
      board:update()

      for i = 1, 12 do
        board:update()

        assert.are.equal("hover", swap_left1.state)
        assert.are.equal("hover", swap_right1.state)
        assert.are.equal("hover", swap_left2.state)
        assert.are.equal("hover", swap_right2.state)
      end

      -- fall 状態に遷移
      board:update()

      assert.are.equal("fall", swap_left1.state)
      assert.are.equal("fall", swap_right1.state)
      assert.are.equal("fall", swap_left2.state)
      assert.are.equal("fall", swap_right2.state)
    end)
  end)

  describe('おじゃまブロックの下が空の場合', function()
    local garbage

    before_each(function()
      garbage = garbage_block()
    end)

    it("状態が fall になる", function()
      board:put(1, 2, garbage)

      board:update()

      assert.are.equal("hover", garbage.state)
    end)

    it("hover 状態は 12 フレーム継続する", function()
      board:put(1, 2, garbage)

      -- hover 状態に遷移
      board:update()

      for i = 1, 12 do
        board:update()

        assert.are.equal("hover", garbage.state)
      end

      -- fall 状態に遷移
      board:update()

      assert.are.equal("fall", garbage.state)
    end)
  end)

  describe('2 つ積み重なったおじゃまブロックの下が空の場合', function()
    local garbage1, garbage2

    before_each(function()
      garbage1 = garbage_block()
      garbage2 = garbage_block()
    end)

    it("両方のおじゃまブロックとも状態が hover になる", function()
      board:put(1, 3, garbage1)
      board:put(1, 2, garbage2)

      board:update()

      assert.are.equal("hover", garbage1.state)
      assert.are.equal("hover", garbage2.state)
    end)

    it("hover 状態は 12 フレーム継続する", function()
      board:put(1, 3, garbage1)
      board:put(1, 2, garbage2)

      -- hover 状態に遷移
      board:update()

      for i = 1, 12 do
        board:update()

        assert.are.equal("hover", garbage1.state)
        assert.are.equal("hover", garbage2.state)
      end

      -- fall 状態に遷移
      board:update()

      assert.are.equal("fall", garbage1.state)
      assert.are.equal("fall", garbage2.state)
    end)
  end)

  describe('ホバー中のブロックにおじゃまブロックが落ちてきた場合', function()
    local hover_block
    local garbage

    before_each(function()
      hover_block = block_class("h")
      garbage = garbage_block(3)
    end)

    it("ホバー中のブロックのタイマーをおじゃまブロックに伝搬", function()
      board:put(1, 4, garbage)
      board:put(2, 2, hover_block)
      hover_block:hover()
      garbage:fall()

      -- ホバーの残りフレームを 12 - 2 = 10 にする
      board:update()
      board:update()

      assert.are.equal(10, hover_block.timer)
      assert.are.equal(10, garbage.timer)
    end)
  end)
end)
