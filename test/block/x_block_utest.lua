require("engine/test/bustedhelper")
require("lib/block")

describe('x_block', function()
  local x

  before_each(function()
    x = block_class("x")
  end)

  describe(".type", function()
    it('should be "x"', function()
      assert.are.equals("x", x.type)
    end)
  end)

  describe(".state", function()
    it('should be "idle"', function()
      assert.is_true(x.state == "idle")
    end)
  end)

  describe(".span", function ()
    it("should be 1", function()
      assert.are.equals(1, x.span)
    end)
  end)

  describe(".height", function ()
    it("should be 1", function()
      assert.are.equals(1, x.height)
    end)
  end)

  describe("stringify", function()
    it("should return 'X '", function()
      assert.are.equals("X ", stringify(x))
    end)
  end)

  describe("is_fallable()", function()
    it("should return true", function()
      assert.is_true(x:is_fallable())
    end)
  end)

  describe("is_reducible()", function()
    it("should return true", function()
      assert.is_true(x:is_reducible())
    end)
  end)

  describe("is_empty", function()
    it("should return false", function()
      assert.is_false(x:is_empty())
    end)
  end)
end)
