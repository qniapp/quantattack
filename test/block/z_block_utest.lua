require("engine/test/bustedhelper")
require("lib/block")

describe('z_block', function()
  local z

  before_each(function()
    z = block_class("z")
  end)

  describe(".type", function()
    it('should be "z"', function()
      assert.are.equals("z", z.type)
    end)
  end)

  describe(".state", function()
    it('should be "idle"', function()
      assert.is_true(z.state == "idle")
    end)
  end)

  describe(".span", function ()
    it("should be 1", function()
      assert.are.equals(1, z.span)
    end)
  end)

  describe(".height", function ()
    it("should be 1", function()
      assert.are.equals(1, z.height)
    end)
  end)

  describe("stringify", function()
    it("should return 'Z '", function()
      assert.are.equals("Z ", stringify(z))
    end)
  end)

  describe("is_fallable()", function()
    it("should return true", function()
      assert.is_true(z:is_fallable())
    end)
  end)

  describe("is_reducible()", function()
    it("should return true", function()
      assert.is_true(z:is_reducible())
    end)
  end)

  describe("is_empty", function()
    it("should return false", function()
      assert.is_false(z:is_empty())
    end)
  end)
end)
