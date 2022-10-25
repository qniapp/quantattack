require("engine/test/bustedhelper")
require("gate")

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

    describe("is_falling", function()
      it("should return false", function()
        assert.is_false(garbage:is_falling())
      end)
    end)

    describe("is_match", function()
      it("should return false", function()
        assert.is_false(garbage:is_match())
      end)
    end)
  end)
end)
