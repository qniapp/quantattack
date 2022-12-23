require("engine/test/bustedhelper")
require("test/test_helper")

local board_class = require("lib/board")
local block_class = require("lib/block")

describe('block', function()
  describe('type', function()
    it("type を指定", function()
      local g = block_class("i")

      assert.are_equal("i", g.type)
    end)

    it("すべての type のブロックを作る", function()
      assert.has_no.errors(function() block_class("i") end)
      assert.has_no.errors(function() block_class("h") end)
      assert.has_no.errors(function() block_class("x") end)
      assert.has_no.errors(function() block_class("y") end)
      assert.has_no.errors(function() block_class("z") end)
      assert.has_no.errors(function() block_class("s") end)
      assert.has_no.errors(function() block_class("t") end)
      assert.has_no.errors(function() block_class("control") end)
      assert.has_no.errors(function() block_class("cnot_x") end)
      assert.has_no.errors(function() block_class("swap") end)
      assert.has_no.errors(function() block_class("g") end)
      assert.has_no.errors(function() block_class("?") end)
    end)
  end)

  describe('span', function()
    it("幅はデフォルトで 1", function()
      assert.are_equal(1, block_class("i").span)
    end)

    it("幅 (span) を指定", function()
      assert.are_equal(3, block_class("g", 3).span)
    end)
  end)

  describe('height', function()
    it("高さはデフォルトで 1", function()
      assert.are_equal(1, block_class("i").height)
    end)

    it("高さ (height) を指定", function()
      assert.are_equal(4, block_class("g", 1, 4).height)
    end)
  end)

  describe('render', function()
    it('should render without errors', function()
      local board = board_class()
      local block = block_class("h")

      board:put(1, 1, block)

      assert.has_no.errors(function() block:render(board:screen_x(1), board:screen_y(1)) end)
    end)
  end)

  describe('swap_with("left")', function()
    local block

    before_each(function()
      local board = board_class()
      block = block_class("h")

      board:put(2, 1, block)
    end)

    it('should swap with the left block without errors', function()
      assert.has_no.errors(function() block:swap_with("left") end)
    end)

    it('should transition its state to swapping', function()
      block:swap_with("left")

      assert.is_true(block:is_swapping())
    end)
  end)

  describe('swap_with("right")', function()
    local block

    before_each(function()
      local board = board_class()
      block = block_class("h")

      board:put(1, 1, block)
    end)

    it('should swap with the right block without errors', function()
      assert.has_no.errors(function() block:swap_with("right") end)
    end)

    it('should transition its state to swapping', function()
      block:swap_with("right")

      assert.is_true(block:is_swapping())
    end)
  end)

  describe('drop', function()
    local block

    before_each(function()
      local board = board_class()
      block = block_class("h")

      board:put(1, 1, block)
    end)

    it('should drop the block without errors', function()
      assert.has_no.errors(function() block:fall() end)
    end)

    it('should transition its state to falling', function()
      block:fall()

      assert.is_true(block:is_falling())
    end)
  end)

  it('should replace with other block', function()
    local board = board_class()
    local block = block_class("h")
    local other_block = block_class("x")
    board:put(1, 1, block)

    block:replace_with(other_block)

    assert.are_equal(other_block, block.new_block)
  end)
end)
