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

  describe(".state", function()
    it('should be "idle"', function()
      assert.is_true(x.state == "idle")
    end)
  end)

  describe(".state", function()
    it("should return false", function()
      assert.is_false(x.state == "swap")
    end)
  end)

  describe("stringify", function()
    it("should return 'X '", function()
      assert.are.equals("X ", stringify(x))
    end)
  end)
end)
