require("engine/test/bustedhelper")
require("garbage_gate")

local board_class = require("board")

describe('garbage_gate', function()
  local board

  before_each(function()
    board = board_class()
  end)

  describe("gate type", function()
    local garbage

    before_each(function()
      garbage = garbage_gate(1)
    end)

    describe("type", function()
      describe("is_i", function()
        it("should return false", function()
          assert.is_false(garbage:is_i())
        end)
      end)

      describe("is_h", function()
        it("should return true", function()
          assert.is_false(garbage:is_h())
        end)
      end)

      describe("is_x", function()
        it("should return false", function()
          assert.is_false(garbage:is_x())
        end)
      end)

      describe("is_y", function()
        it("should return false", function()
          assert.is_false(garbage:is_y())
        end)
      end)

      describe("is_z", function()
        it("should return false", function()
          assert.is_false(garbage:is_z())
        end)
      end)

      describe("is_s", function()
        it("should return false", function()
          assert.is_false(garbage:is_s())
        end)
      end)

      describe("is_t", function()
        it("should return false", function()
          assert.is_false(garbage:is_t())
        end)
      end)

      describe("is_swap", function()
        it("should return false", function()
          assert.is_false(garbage:is_swap())
        end)
      end)

      describe("is_control", function()
        it("should return false", function()
          assert.is_false(garbage:is_control())
        end)
      end)

      describe("is_cnot_x", function()
        it("should return false", function()
          assert.is_false(garbage:is_cnot_x())
        end)
      end)

      describe("is_garbage", function()
        it("should return true", function()
          assert.is_true(garbage:is_garbage())
        end)
      end)
    end)
  end)

  describe("state", function()
    local garbage

    before_each(function()
      garbage = garbage_gate(1)
    end)

    describe("is_idle", function()
      it("should return true", function()
        assert.is_true(garbage:is_idle())
      end)
    end)

    describe("is_swapping", function()
      it("should return false", function()
        assert.is_false(garbage:is_swapping())
      end)
    end)

    describe("is_dropping", function()
      it("should return false", function()
        assert.is_false(garbage:is_dropping())
      end)
    end)

    describe("is_match", function()
      it("should return false", function()
        assert.is_false(garbage:is_match())
      end)
    end)
  end)
end)
