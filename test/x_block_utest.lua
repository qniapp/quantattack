require("engine/test/bustedhelper")
require("lib/block")

describe('x_block', function()
  local x

  before_each(function()
    x = block_class("x")
  end)

  describe(":is_i", function()
    it("should return false", function()
      assert.is_false(x.type == "i")
    end)
  end)

  describe(":is_garbage", function()
    it("should return false", function()
      assert.is_false(x.type == "g")
    end)
  end)

  describe(".state", function()
    it("should return true", function()
      assert.is_true(x.state == "idle")
    end)
  end)

  describe(":is_swapping", function()
    it("should return false", function()
      assert.is_false(x:is_swapping())
    end)
  end)

  describe(".state", function()
    it("should return false", function()
      assert.is_false(x.state == "falling")
    end)
  end)

  describe(".state", function()
    it("should return false", function()
      assert.is_false(x.state == "match")
    end)
  end)

  describe("stringify", function()
    it("should return 'X '", function()
      assert.are.equals("X ", stringify(x))
    end)
  end)
end)
