require("engine/test/bustedhelper")
require("engine/debug/dump")
require("x_gate")

describe('x_gate', function()
  local x

  before_each(function()
    x = x_gate()
  end)

  describe("gate type", function()
    describe(":is_i", function()
      it("should return false", function()
        assert.is_false(x:is_i())
      end)
    end)

    describe(":is_h", function()
      it("should return false", function()
        assert.is_false(x:is_h())
      end)
    end)

    describe(":is_x", function()
      it("should return true", function()
        assert.is_true(x:is_x())
      end)
    end)

    describe(":is_y", function()
      it("should return false", function()
        assert.is_false(x:is_y())
      end)
    end)

    describe(":is_z", function()
      it("should return false", function()
        assert.is_false(x:is_z())
      end)
    end)

    describe(":is_s", function()
      it("should return false", function()
        assert.is_false(x:is_s())
      end)
    end)

    describe(":is_t", function()
      it("should return false", function()
        assert.is_false(x:is_t())
      end)
    end)

    describe(":is_swap", function()
      it("should return false", function()
        assert.is_false(x:is_swap())
      end)
    end)

    describe(":is_control", function()
      it("should return false", function()
        assert.is_false(x:is_control())
      end)
    end)

    describe(":is_cnot_x", function()
      it("should return false", function()
        assert.is_false(x:is_cnot_x())
      end)
    end)

    describe(":is_garbage", function()
      it("should return false", function()
        assert.is_false(x:is_garbage())
      end)
    end)
  end)

  describe("state", function()
    describe(":is_idle", function()
      it("should return true", function()
        assert.is_true(x:is_idle())
      end)
    end)

    describe(":is_swapping", function()
      it("should return false", function()
        assert.is_false(x:is_swapping())
      end)
    end)

    describe(":is_dropping", function()
      it("should return false", function()
        assert.is_false(x:is_dropping())
      end)
    end)

    describe(":is_match", function()
      it("should return false", function()
        assert.is_false(x:is_match())
      end)
    end)
  end)

  describe("stringify", function()
    it("should return 'x'", function()
      assert.are.equals("x", stringify(x))
    end)
  end)
end)
