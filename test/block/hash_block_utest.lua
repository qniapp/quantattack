require("engine/test/bustedhelper")
require("lib/block")

describe('hash_block', function()
  local hash

  before_each(function()
    hash = block_class("#")
  end)

  describe(".type", function()
    it('should be #', function()
      assert.are.equals("#", hash.type)
    end)
  end)

  describe(".state", function()
    it('should be "idle"', function()
      assert.is_true(hash.state == "idle")
    end)
  end)

  describe(".span", function ()
    it("should be 1", function()
      assert.are.equals(1, hash.span)
    end)
  end)

  describe(".height", function ()
    it("should be 1", function()
      assert.are.equals(1, hash.height)
    end)
  end)

  describe("stringify", function()
    it("should return '# '", function()
      assert.are.equals("# ", stringify(hash))
    end)
  end)

  describe("is_not_fallable()", function()
    it("should return false", function()
      assert.is_false(hash:is_not_fallable())
    end)
  end)

  describe("is_reducible()", function()
    it("should return true", function()
      assert.is_true(hash:is_reducible())
    end)
  end)
end)
