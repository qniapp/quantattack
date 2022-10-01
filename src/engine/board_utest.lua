require("engine/test/bustedhelper")

local board_class = require("src/engine/board")
local h_gate = require("src/engine/h_gate")
local x_gate = require("src/engine/x_gate")
local y_gate = require("src/engine/y_gate")
local z_gate = require("src/engine/z_gate")
local s_gate = require("src/engine/s_gate")
local t_gate = require("src/engine/t_gate")

describe('board', function()
  describe('reduce', function()
    local board

    before_each(function()
      board = board_class:new()
    end)

    --
    --  H  reduce
    --  H  ----->  I
    --
    it('should reduce HH', function()
      board:put(1, 11, h_gate:new())
      board:put(1, 12, h_gate:new())

      board:_reduce()

      assert.are.equals('i', board:gate_at(1, 11)._reduce_to.type)
      assert.are.equals('i', board:gate_at(1, 12)._reduce_to.type)
    end)

    --  X  reduce
    --  X  ----->  I
    --
    it('should reduce XX', function()
      board:put(1, 11, x_gate:new())
      board:put(1, 12, x_gate:new())

      board:_reduce()

      assert.are.equals('i', board:gate_at(1, 11)._reduce_to.type)
      assert.are.equals('i', board:gate_at(1, 12)._reduce_to.type)
    end)

    --  Y  reduce
    --  Y  ----->  I
    --
    it('should reduce YY', function()
      board:put(1, 11, y_gate:new())
      board:put(1, 12, y_gate:new())

      board:_reduce()

      assert.are.equals('i', board:gate_at(1, 11)._reduce_to.type)
      assert.are.equals('i', board:gate_at(1, 12)._reduce_to.type)
    end)

    --  Z  reduce
    --  Z  ----->  I
    --
    it('should reduce ZZ', function()
      board:put(1, 11, z_gate:new())
      board:put(1, 12, z_gate:new())

      board:_reduce()

      assert.are.equals('i', board:gate_at(1, 11)._reduce_to.type)
      assert.are.equals('i', board:gate_at(1, 12)._reduce_to.type)
    end)

    --  Z  reduce
    --  X  ----->  Y
    --
    it('should reduce ZX', function()
      board:put(1, 11, z_gate:new())
      board:put(1, 12, x_gate:new())

      board:_reduce()

      assert.are.equals('i', board:gate_at(1, 11)._reduce_to.type)
      assert.are.equals('y', board:gate_at(1, 12)._reduce_to.type)
    end)

    --  X  reduce
    --  Z  ----->  Y
    --
    it('should reduce XZ', function()
      board:put(1, 11, x_gate:new())
      board:put(1, 12, z_gate:new())

      board:_reduce()

      assert.are.equals('i', board:gate_at(1, 11)._reduce_to.type)
      assert.are.equals('y', board:gate_at(1, 12)._reduce_to.type)
    end)

    --  S  reduce
    --  S  ----->  Z
    --
    it('should reduce SS', function()
      board:put(1, 11, s_gate:new())
      board:put(1, 12, s_gate:new())

      board:_reduce()

      assert.are.equals('i', board:gate_at(1, 11)._reduce_to.type)
      assert.are.equals('z', board:gate_at(1, 12)._reduce_to.type)
    end)

    --  T  reduce
    --  T  ----->  S
    --
    it('should reduce TT', function()
      board:put(1, 11, t_gate:new())
      board:put(1, 12, t_gate:new())

      board:_reduce()

      assert.are.equals('i', board:gate_at(1, 11)._reduce_to.type)
      assert.are.equals('s', board:gate_at(1, 12)._reduce_to.type)
    end)
  end)
end)
