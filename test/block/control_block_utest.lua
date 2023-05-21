require("engine/test/bustedhelper")
require("test/test_helper")
require("lib/block")

describe('control_block', function()
  local control

  before_each(function()
    control = control_block(2)
  end)

  describe(".type", function()
    it('should be "control"', function()
      assert.are.equals("control", control.type)
    end)
  end)

  describe(".state", function()
    it('should be "idle"', function()
      assert.is_true(control.state == "idle")
    end)
  end)

  describe(".span", function ()
    it("should be 1", function()
      assert.are.equals(1, control.span)
    end)
  end)

  describe(".height", function ()
    it("should be 1", function()
      assert.are.equals(1, control.height)
    end)
  end)

  describe("stringify", function()
    it("should return '● '", function()
      assert.are.equals("● ", stringify(control))
    end)
  end)

  describe("is_fallable()", function()
    it("should return true", function()
      assert.is_true(control:is_fallable())
    end)
  end)

  describe("is_reducible()", function()
    it("should return true", function()
      assert.is_true(control:is_reducible())
    end)
  end)

  describe("is_empty", function()
    it("should return false", function()
      assert.is_false(control:is_empty())
    end)
  end)
end)
