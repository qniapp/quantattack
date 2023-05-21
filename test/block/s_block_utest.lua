require("engine/test/bustedhelper")
require("lib/block")

describe('s_block', function()
  local s

  before_each(function()
    s = block_class("s")
  end)

  describe(".type", function()
    it('should be "s"', function()
      assert.are.equals("s", s.type)
    end)
  end)

  describe(".state", function()
    it('should be "idle"', function()
      assert.is_true(s.state == "idle")
    end)
  end)

  describe(".span", function ()
    it("should be 1", function()
      assert.are.equals(1, s.span)
    end)
  end)

  describe(".height", function ()
    it("should be 1", function()
      assert.are.equals(1, s.height)
    end)
  end)

  describe("stringify", function()
    it("should return 'S '", function()
      assert.are.equals("S ", stringify(s))
    end)
  end)

  describe("is_fallable()", function()
    it("should return true", function()
      assert.is_true(s:is_fallable())
    end)
  end)

  describe("is_reducible()", function()
    it("should return true", function()
      assert.is_true(s:is_reducible())
    end)
  end)

  describe("is_empty", function()
    it("should return false", function()
      assert.is_false(s:is_empty())
    end)
  end)
end)
