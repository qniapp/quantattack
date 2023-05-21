require("engine/test/bustedhelper")
require("lib/block")

describe('y_block', function()
  local y

  before_each(function()
    y = block_class("y")
  end)

  describe(".type", function()
    it('should be "y"', function()
      assert.are.equals("y", y.type)
    end)
  end)

  describe(".state", function()
    it('should be "idle"', function()
      assert.is_true(y.state == "idle")
    end)
  end)

  describe(".span", function ()
    it("should be 1", function()
      assert.are.equals(1, y.span)
    end)
  end)

  describe(".height", function ()
    it("should be 1", function()
      assert.are.equals(1, y.height)
    end)
  end)

  describe("stringify", function()
    it("should return 'Y '", function()
      assert.are.equals("Y ", stringify(y))
    end)
  end)

  describe("is_fallable()", function()
    it("should return true", function()
      assert.is_true(y:is_fallable())
    end)
  end)

  describe("is_reducible()", function()
    it("should return true", function()
      assert.is_true(y:is_reducible())
    end)
  end)
end)
