require("engine/test/bustedhelper")
require('lib/block')

describe('i_block #solo', function()
  local i

  before_each(function()
    i = block_class("i")
  end)

  describe(".type", function()
    it('should be "i"', function()
      assert.are.equals("i", i.type)
    end)
  end)

  describe(".state", function()
    it('should be "idle"', function()
      assert.are.equals("idle", i.state)
    end)
  end)

  describe(".span", function ()
    it("should be 1", function()
      assert.are.equals(1, i.span)
    end)
  end)

  describe(".height", function ()
    it("should be 1", function()
      assert.are.equals(1, i.height)
    end)
  end)

  describe("stringify", function()
    it('should return "_ "', function()
      assert.are.equals("_ ", stringify(i))
    end)
  end)

  describe("is_fallable()", function()
    it("should return false", function()
      assert.is_false(i:is_fallable())
    end)
  end)

  describe("is_reducible()", function()
    it("should return false", function()
      assert.is_false(i:is_reducible())
    end)
  end)

  describe("is_empty", function()
    it("should return true", function()
      assert.is_true(i:is_empty())
    end)
  end)

  describe("is_single_block", function()
    it("should return false", function()
      assert.is_false(i:is_single_block())
    end)
  end)
end)
