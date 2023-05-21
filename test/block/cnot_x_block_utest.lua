require("engine/test/bustedhelper")
require("test/test_helper")
require("lib/block")

describe('cnot_x_block', function()
  local cnot_x

  before_each(function()
    cnot_x = cnot_x_block(2)
  end)

  describe(".type", function()
    it('should be "cnot_x"', function()
      assert.are.equals("cnot_x", cnot_x.type)
    end)
  end)

  describe(".state", function()
    it('should be "idle"', function()
      assert.is_true(cnot_x.state == "idle")
    end)
  end)

  describe(".span", function ()
    it("should be 1", function()
      assert.are.equals(1, cnot_x.span)
    end)
  end)

  describe(".height", function ()
    it("should be 1", function()
      assert.are.equals(1, cnot_x.height)
    end)
  end)

  describe("stringify", function()
    it("should return '+ '", function()
      assert.are.equals("+ ", stringify(cnot_x))
    end)
  end)

  describe("is_fallable()", function()
    it("should return true", function()
      assert.is_true(cnot_x:is_fallable())
    end)
  end)

  describe("is_reducible()", function()
    it("should return true", function()
      assert.is_true(cnot_x:is_reducible())
    end)
  end)
end)
