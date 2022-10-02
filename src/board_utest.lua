require("engine/test/bustedhelper")

local board_class = require("src/board")
local h_gate = require("src/h_gate")
local x_gate = require("src/x_gate")
local y_gate = require("src/y_gate")
local z_gate = require("src/z_gate")
local s_gate = require("src/s_gate")
local t_gate = require("src/t_gate")
local swap_gate = require("src/swap_gate")
local control_gate = require("src/control_gate")
local cnot_x_gate = require("src/cnot_x_gate")

describe('board', function()
  describe('reduce', function()
    local board

    before_each(function()
      board = board_class:new()
    end)

    --  H          I
    --  H  ----->  I
    it('should reduce HH', function()
      board:put(1, 11, h_gate())
      board:put(1, 12, h_gate())

      board:reduce()

      assert.are.equals('i', board:gate_at(1, 11).reduce_to.type)
      assert.are.equals('i', board:gate_at(1, 12).reduce_to.type)
    end)

    --  X          I
    --  X  ----->  I
    it('should reduce XX', function()
      board:put(1, 11, x_gate())
      board:put(1, 12, x_gate())

      board:reduce()

      assert.are.equals('i', board:gate_at(1, 11).reduce_to.type)
      assert.are.equals('i', board:gate_at(1, 12).reduce_to.type)
    end)

    --  Y          I
    --  Y  ----->  I
    it('should reduce YY', function()
      board:put(1, 11, y_gate())
      board:put(1, 12, y_gate())

      board:reduce()

      assert.are.equals('i', board:gate_at(1, 11).reduce_to.type)
      assert.are.equals('i', board:gate_at(1, 12).reduce_to.type)
    end)

    --  Z          I
    --  Z  ----->  I
    it('should reduce ZZ', function()
      board:put(1, 11, z_gate())
      board:put(1, 12, z_gate())

      board:reduce()

      assert.are.equals('i', board:gate_at(1, 11).reduce_to.type)
      assert.are.equals('i', board:gate_at(1, 12).reduce_to.type)
    end)

    --  Z          I
    --  X  ----->  Y
    it('should reduce ZX', function()
      board:put(1, 11, z_gate())
      board:put(1, 12, x_gate())

      board:reduce()

      assert.are.equals('i', board:gate_at(1, 11).reduce_to.type)
      assert.are.equals('y', board:gate_at(1, 12).reduce_to.type)
    end)

    --  X          I
    --  Z  ----->  Y
    it('should reduce XZ', function()
      board:put(1, 11, x_gate())
      board:put(1, 12, z_gate())

      board:reduce()

      assert.are.equals('i', board:gate_at(1, 11).reduce_to.type)
      assert.are.equals('y', board:gate_at(1, 12).reduce_to.type)
    end)

    --  S          I
    --  S  ----->  Z
    it('should reduce SS', function()
      board:put(1, 11, s_gate())
      board:put(1, 12, s_gate())

      board:reduce()

      assert.are.equals('i', board:gate_at(1, 11).reduce_to.type)
      assert.are.equals('z', board:gate_at(1, 12).reduce_to.type)
    end)

    --  T          I
    --  T  ----->  S
    it('should reduce TT', function()
      board:put(1, 11, t_gate())
      board:put(1, 12, t_gate())

      board:reduce()

      assert.are.equals('i', board:gate_at(1, 11).reduce_to.type)
      assert.are.equals('s', board:gate_at(1, 12).reduce_to.type)
    end)

    --  SWAP-SWAP          I I
    --  SWAP-SWAP  ----->  I I
    it('should reduce SWAP pairs in the same columns', function()
      board:put(1, 11, swap_gate:new(3))
      board:put(3, 11, swap_gate:new(1))
      board:put(1, 12, swap_gate:new(3))
      board:put(3, 12, swap_gate:new(1))

      board:reduce()

      assert.are.equals('i', board:gate_at(1, 11).reduce_to.type)
      assert.are.equals('i', board:gate_at(3, 11).reduce_to.type)
      assert.are.equals('i', board:gate_at(1, 12).reduce_to.type)
      assert.are.equals('i', board:gate_at(3, 12).reduce_to.type)
    end)

    --  H          I
    --  X          I
    --  H  ----->  Z
    it('should reduce hxh', function()
      board:put(1, 10, h_gate())
      board:put(1, 11, x_gate())
      board:put(1, 12, h_gate())

      board:reduce()

      assert.are.equals('i', board:gate_at(1, 10).reduce_to.type)
      assert.are.equals('i', board:gate_at(1, 11).reduce_to.type)
      assert.are.equals('z', board:gate_at(1, 12).reduce_to.type)
    end)

    --  H          I
    --  Z          I
    --  H  ----->  X
    it('should reduce HZH', function()
      board:put(1, 10, h_gate())
      board:put(1, 11, z_gate())
      board:put(1, 12, h_gate())

      board:reduce()

      assert.are.equals('i', board:gate_at(1, 10).reduce_to.type)
      assert.are.equals('i', board:gate_at(1, 11).reduce_to.type)
      assert.are.equals('x', board:gate_at(1, 12).reduce_to.type)
    end)

    --  S          I
    --  Z          I
    --  S  ----->  Z
    it('should reduce SZS', function()
      board:put(1, 10, s_gate())
      board:put(1, 11, z_gate())
      board:put(1, 12, s_gate())

      board:reduce()

      assert.are.equals('i', board:gate_at(1, 10).reduce_to.type)
      assert.are.equals('i', board:gate_at(1, 11).reduce_to.type)
      assert.are.equals('z', board:gate_at(1, 12).reduce_to.type)
    end)

    --  C-X          I I
    --  C-X  ----->  I I
    it('should reduce CNOT x2', function()
      board:put(1, 11, control_gate:new(3))
      board:put(3, 11, cnot_x_gate:new(1))
      board:put(1, 12, control_gate:new(3))
      board:put(3, 12, cnot_x_gate:new(1))

      board:reduce()

      assert.are.equals('i', board:gate_at(1, 11).reduce_to.type)
      assert.are.equals('i', board:gate_at(3, 11).reduce_to.type)
      assert.are.equals('i', board:gate_at(1, 12).reduce_to.type)
      assert.are.equals('i', board:gate_at(3, 12).reduce_to.type)
    end)

    --  C-X             I I
    --  X-C             I I
    --  C-X  ----->  SWAP-SWAP
    it('should reduce CNOT x3', function()
      board:put(1, 10, control_gate:new(3))
      board:put(3, 10, cnot_x_gate:new(1))
      board:put(1, 11, cnot_x_gate:new(3))
      board:put(3, 11, control_gate:new(1))
      board:put(1, 12, control_gate:new(3))
      board:put(3, 12, cnot_x_gate:new(1))

      board:reduce()

      assert.are.equals('i', board:gate_at(1, 10).reduce_to.type)
      assert.are.equals('i', board:gate_at(3, 10).reduce_to.type)
      assert.are.equals('i', board:gate_at(1, 11).reduce_to.type)
      assert.are.equals('i', board:gate_at(3, 11).reduce_to.type)
      assert.are.equals('swap', board:gate_at(1, 12).reduce_to.type)
      assert.are.equals('swap', board:gate_at(3, 12).reduce_to.type)
    end)

    -- H H          I I
    -- C-X  ----->  X-C
    -- H H          I I
    it('should reduce HH CNOT HH', function()
      board:put(1, 10, h_gate())
      board:put(3, 10, h_gate())
      board:put(1, 11, control_gate:new(3))
      board:put(3, 11, cnot_x_gate:new(1))
      board:put(1, 12, h_gate())
      board:put(3, 12, h_gate())

      board:reduce()

      assert.are.equals('i', board:gate_at(1, 10).reduce_to.type)
      assert.are.equals('i', board:gate_at(3, 10).reduce_to.type)
      assert.are.equals('cnot_x', board:gate_at(1, 11).reduce_to.type)
      assert.are.equals('control', board:gate_at(3, 11).reduce_to.type)
      assert.are.equals('i', board:gate_at(1, 12).reduce_to.type)
      assert.are.equals('i', board:gate_at(3, 12).reduce_to.type)
    end)

    -- X X          I I
    -- C-X  ----->  C-X
    -- X            I
    it('should reduce XX CNOT X', function()
      board:put(1, 10, x_gate())
      board:put(3, 10, x_gate())
      board:put(1, 11, control_gate:new(3))
      board:put(3, 11, cnot_x_gate:new(1))
      board:put(1, 12, x_gate())

      board:reduce()

      assert.are.equals('i', board:gate_at(1, 10).reduce_to.type)
      assert.are.equals('i', board:gate_at(3, 10).reduce_to.type)
      assert.are.equals('control', board:gate_at(1, 11).type)
      assert.are.equals('cnot_x', board:gate_at(3, 11).type)
      assert.are.equals('i', board:gate_at(1, 12).reduce_to.type)
    end)

    -- Z Z          I I
    -- C-X  ----->  C-X
    --   Z            I
    it('should reduce zz cx z', function()
      board:put(1, 10, z_gate())
      board:put(3, 10, z_gate())
      board:put(1, 11, control_gate:new(3))
      board:put(3, 11, cnot_x_gate:new(1))
      board:put(3, 12, z_gate())

      board:reduce()

      assert.are.equals('i', board:gate_at(1, 10).reduce_to.type)
      assert.are.equals('i', board:gate_at(3, 10).reduce_to.type)
      assert.are.equals('control', board:gate_at(1, 11).type)
      assert.are.equals('cnot_x', board:gate_at(3, 11).type)
      assert.are.equals('i', board:gate_at(3, 12).reduce_to.type)
    end)


    -- X            I
    -- X-C  ----->  X-C
    -- X            I
    it('should reduce x xc x', function()
      board:put(1, 10, x_gate())
      board:put(1, 11, cnot_x_gate:new(3))
      board:put(3, 11, control_gate:new(1))
      board:put(1, 12, x_gate())

      board:reduce()

      assert.are.equals('i', board:gate_at(1, 10).reduce_to.type)
      assert.are.equals('cnot_x', board:gate_at(1, 11).type)
      assert.are.equals('control', board:gate_at(3, 11).type)
      assert.are.equals('i', board:gate_at(1, 12).reduce_to.type)
    end)

    -- Z            I
    -- C-X  ----->  C-X
    -- Z            I
    it('should reduce z cx z', function()
      board:put(1, 10, z_gate())
      board:put(1, 11, control_gate:new(3))
      board:put(3, 11, cnot_x_gate:new(1))
      board:put(1, 12, z_gate())

      board:reduce()

      assert.are.equals('i', board:gate_at(1, 10).reduce_to.type)
      assert.are.equals('control', board:gate_at(1, 11).type)
      assert.are.equals('cnot_x', board:gate_at(3, 11).type)
      assert.are.equals('i', board:gate_at(1, 12).reduce_to.type)
    end)

    -- Z            I
    -- H X          H I
    -- X-C  ----->  X-C
    -- H X          H I
    it('should reduce xz cz x', function()
      board:put(1, 9, z_gate())
      board:put(1, 10, h_gate())
      board:put(3, 10, x_gate())
      board:put(1, 11, cnot_x_gate:new(3))
      board:put(3, 11, control_gate:new(1))
      board:put(1, 12, h_gate())
      board:put(3, 12, x_gate())

      board:reduce()

      assert.are.equals('i', board:gate_at(1, 9).reduce_to.type)
      assert.are.equals('h', board:gate_at(1, 10).type)
      assert.are.equals('i', board:gate_at(3, 10).reduce_to.type)
      assert.are.equals('cnot_x', board:gate_at(1, 11).type)
      assert.are.equals('control', board:gate_at(3, 11).type)
      assert.are.equals('h', board:gate_at(1, 12).type)
      assert.are.equals('i', board:gate_at(3, 12).reduce_to.type)
    end)
  end)
end)
