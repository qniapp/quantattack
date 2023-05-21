require("engine/test/bustedhelper")
require("lib/block")

describe('q_block #solo', function()
  local q

  before_each(function()
    q = block_class("?")
  end)

  describe(".type", function()
    it('should be "?"', function()
      assert.are.equals("?", q.type)
    end)
  end)

  describe(".state", function()
    it('should be "idle"', function()
      assert.is_true(q.state == "idle")
    end)
  end)

  describe(".span", function ()
    it("should be 1", function()
      assert.are.equals(1, q.span)
    end)
  end)

  describe(".height", function ()
    it("should be 1", function()
      assert.are.equals(1, q.height)
    end)
  end)

  describe("stringify", function()
    it("should return '? '", function()
      assert.are.equals("? ", stringify(q))
    end)
  end)

  describe("is_fallable()", function()
    it("should return false", function()
      assert.is_false(q:is_fallable())
    end)
  end)

  describe("is_reducible()", function()
    it("should return false", function()
      assert.is_false(q:is_reducible())
    end)
  end)

  describe("is_empty", function()
    it("should return false", function()
      assert.is_false(q:is_empty())
    end)
  end)

  describe("is_single_block", function()
    it("should return false", function()
      assert.is_false(q:is_single_block())
    end)
  end)
end)
