require("engine/test/bustedhelper")
require("lib/board")

describe('h_block', function()
  local h

  before_each(function()
    h = block_class("h")
  end)

  describe(".type", function()
    it('should be "h"', function()
      assert.are.equals("h", h.type)
    end)
  end)

  describe(".state", function()
    it('should be "idle"', function()
      assert.is_true(h.state == "idle")
    end)
  end)

  describe(".span", function ()
    it("should be 1", function()
      assert.are.equals(1, h.span)
    end)
  end)

  describe(".height", function ()
    it("should be 1", function()
      assert.are.equals(1, h.height)
    end)
  end)

  describe("stringify", function()
    it('should return "H"', function()
      assert.are.equals("H ", stringify(h))
    end)
  end)

  describe("is_fallable()", function()
    it("should return true", function()
      assert.is_true(h:is_fallable())
    end)
  end)

  describe("is_reducible()", function()
    it("should return true", function()
      assert.is_true(h:is_reducible())
    end)
  end)

  describe("is_empty", function()
    it("should return false", function()
      assert.is_false(h:is_empty())
    end)
  end)
end)
