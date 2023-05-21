require("engine/test/bustedhelper")
require("lib/block")

describe('t_block', function()
  local t

  before_each(function()
    t = block_class("t")
  end)

  describe(".type", function()
    it('should be "t"', function()
      assert.are.equals("t", t.type)
    end)
  end)

  describe(".state", function()
    it('should be "idle"', function()
      assert.is_true(t.state == "idle")
    end)
  end)

  describe(".span", function ()
    it("should be 1", function()
      assert.are.equals(1, t.span)
    end)
  end)

  describe(".height", function ()
    it("should be 1", function()
      assert.are.equals(1, t.height)
    end)
  end)

  describe("stringify", function()
    it("should return 'T '", function()
      assert.are.equals("T ", stringify(t))
    end)
  end)

  describe("is_not_fallable()", function()
    it("should return false", function()
      assert.is_false(t:is_not_fallable())
    end)
  end)

  describe("is_reducible()", function()
    it("should return true", function()
      assert.is_true(t:is_reducible())
    end)
  end)
end)
