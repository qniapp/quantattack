require("engine/test/bustedhelper")
require("lib/board")

describe('h_block', function()
  local h

  before_each(function()
    h = block_class("h")
  end)

  describe("is_single_block", function()
    it("should return true", function()
      assert.is_true(h:is_single_block())
    end)
  end)

  describe("is_garbage", function()
    it("should return false", function()
      assert.is_false(h.type == "g")
    end)
  end)

  describe("state", function()
    it("should return true", function()
      assert.is_true(h.state == "idle")
    end)
  end)

  describe("is_swapping", function()
    it("should return false", function()
      assert.is_false(h:is_swapping())
    end)
  end)

  describe(".state", function()
    it("should return false", function()
      assert.is_false(h.state == "falling")
    end)
  end)

  describe("is_match", function()
    it("should return false", function()
      assert.is_false(h:is_match())
    end)
  end)

  it("should return 'H '", function()
    assert.are.equals("H ", stringify(h))
  end)
end)
