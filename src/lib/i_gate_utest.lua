require("engine/test/bustedhelper")
require("lib/test_helper")

describe('i_gate', function()
  local i

  before_each(function()
    i = i_gate()
  end)

  describe("gate type", function()
    describe("is_garbage", function()
      it("should return false", function()
        assert.is_false(i.type == "g")
      end)
    end)
  end)

  describe("state", function()
    describe("is_idle", function()
      it("should return true", function()
        assert.is_true(i:is_idle())
      end)
    end)

    describe("is_swapping", function()
      it("should return false", function()
        assert.is_false(i:is_swapping())
      end)
    end)

    describe("is_falling", function()
      it("should return false", function()
        assert.is_false(i:is_falling())
      end)
    end)

    describe("is_match", function()
      it("should return false", function()
        assert.is_false(i:is_match())
      end)
    end)
  end)

  describe("is_empty", function()
    it("should return true", function()
      assert.is_true(i:is_empty())
    end)
  end)

  describe("is_reducible", function()
    it("should return false", function()
      assert.is_false(i:is_reducible())
    end)
  end)

  describe("fall", function()
    it("should raise", function()
      assert.error(function() i:fall() end)
    end)
  end)

  describe("stringify", function()
    it("should return '_ '", function()
      assert.are.equals("_ ", stringify(i))
    end)
  end)
end)