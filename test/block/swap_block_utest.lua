require("engine/test/bustedhelper")
require("test/test_helper")
require("lib/block")

describe('swap_block', function()
  local swap

  before_each(function()
    swap = swap_block(2)
  end)

  describe(".type", function()
    it('should be "swap"', function()
      assert.are.equals("swap", swap.type)
    end)
  end)

  describe(".state", function()
    it('should be "idle"', function()
      assert.is_true(swap.state == "idle")
    end)
  end)

  describe(".span", function ()
    it("should be 1", function()
      assert.are.equals(1, swap.span)
    end)
  end)

  describe(".height", function ()
    it("should be 1", function()
      assert.are.equals(1, swap.height)
    end)
  end)

  describe("stringify", function()
    it("should return 'X '", function()
      assert.are.equals("X ", stringify(swap))
    end)
  end)

  describe("is_fallable()", function()
    it("should return true", function()
      assert.is_true(swap:is_fallable())
    end)
  end)

  describe("is_reducible()", function()
    it("should return true", function()
      assert.is_true(swap:is_reducible())
    end)
  end)

  describe("is_empty", function()
    it("should return false", function()
      assert.is_false(swap:is_empty())
    end)
  end)
end)
