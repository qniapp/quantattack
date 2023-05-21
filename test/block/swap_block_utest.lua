require("engine/test/bustedhelper")
require("test/test_helper")
require("lib/block")

describe('swap_block', function()
  local swap

  before_each(function()
    swap = swap_block(2)
  end)

  describe("is_i", function()
    it("should return false", function()
      assert.is_false(swap.type == "i")
    end)
  end)

  describe("state", function()
    it("should return true", function()
      assert.is_true(swap.state == "idle")
    end)
  end)

  describe(".state", function()
    it("should return false", function()
      assert.is_false(swap.state == "swap")
    end)
  end)

  describe(".state", function()
    it("should return false", function()
      assert.is_false(swap.state == "falling")
    end)
  end)

  describe(".state", function()
    it("should return false", function()
      assert.is_false(swap.state == "match")
    end)
  end)

  describe("stringify", function()
    it("should return 'X '", function()
      assert.are.equals("X ", stringify(swap))
    end)
  end)
end)
