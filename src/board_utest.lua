require("engine/test/bustedhelper")
require("engine/debug/dump")

local board_class = require("board")
local h_gate = require("h_gate")
local x_gate = require("x_gate")
local y_gate = require("y_gate")
local z_gate = require("z_gate")
local s_gate = require("s_gate")
local t_gate = require("t_gate")
local swap_gate = require("swap_gate")
local control_gate = require("control_gate")
local cnot_x_gate = require("cnot_x_gate")

describe('board', function()
  local board

  before_each(function()
    board = board_class()
  end)

  describe('swap', function()
    it('should swap gates next to each other', function()
      board:put(1, 12, h_gate())
      board:put(2, 12, x_gate())

      local swapped = board:swap(1, 2, 12)

      assert.is_true(swapped)
      assert.is_true(board:gate_at(1, 12):is_h())
      assert.is_true(board:gate_at(2, 12):is_x())
      assert.is_true(board:gate_at(1, 12):is_swapping())
      assert.is_true(board:gate_at(2, 12):is_swapping())
    end)

    it('should not swap gates if the left gate is in swap', function()
      board:put(2, 12, h_gate())
      board:gate_at(2, 12):swap_with_left(1)
      board:put(3, 12, x_gate())

      local swapped = board:swap(2, 3, 12)

      assert.is_false(swapped)
      assert.is_true(board:gate_at(3, 12):is_x())
      assert.is_true(board:gate_at(3, 12):is_idle())
    end)

    it('should not swap gates if the right gate is in swap', function()
      board:put(1, 12, h_gate())
      board:put(2, 12, x_gate())
      board:gate_at(2, 12):swap_with_right(3)

      local swapped = board:swap(1, 2, 12)

      assert.is_false(swapped)
      assert.is_true(board:gate_at(1, 12):is_h())
      assert.is_true(board:gate_at(1, 12):is_idle())
    end)

    -- (S は SWAP ゲート)
    --
    --  S-S →(右 の S を左と入れ換え)→ SS
    it('should update swap_gate.other_x after a swap', function()
      board:put(1, 12, swap_gate(3))
      board:put(3, 12, swap_gate(1))

      board:swap(2, 3, 12)
      board:update()
      board:update()
      board:update()
      board:update()
      board:update()

      assert.are_equal(2, board:gate_at(1, 12).other_x)
    end)
  end)

  describe('reduce', function()
    --
    -- reduce -> H
    --           -
    --           X (next gates)
    it('should not reduce when y is the last and include_next_gates = true', function()
      board:put(1, board.rows, h_gate())
      board:put(1, board_class.row_next_gates, x_gate())

      local reduction = board:reduce(1, board.rows, true)

      assert.are.same({}, reduction.to)
    end)

    --
    -- reduce -> H
    --           -
    --           X (next gates)
    it('should not reduce when y is the last and include_next_gates = true', function()
      board:put(1, board.rows, h_gate())
      board:put(1, board_class.row_next_gates, x_gate())

      local reduction = board:reduce(1, board.rows, true)

      assert.are.same({}, reduction.to)
    end)

    --           -
    -- reduce -> I (next gates)
    it('should not reduce when y is the next gates row and include_next_gates = true', function()
      local reduction = board:reduce(1, board_class.row_next_gates, true)

      assert.are.same({}, reduction.to)
    end)
  end)

  describe('reduce_gates', function()
    -- reduce -> H          I
    --           -          -
    --           H  ----->  I (next gates)
    it('should reduce HH', function()
      board:put(1, 11, h_gate())
      board:put(1, 12, h_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12).reduce_to:is_i())
    end)

    it('should reduce XX', function()
      board:put(1, 11, x_gate())
      board:put(1, 12, x_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12).reduce_to:is_i())
    end)

    it('should reduce YY', function()
      board:put(1, 11, y_gate())
      board:put(1, 12, y_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12).reduce_to:is_i())
    end)

    it('should reduce ZZ', function()
      board:put(1, 11, z_gate())
      board:put(1, 12, z_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12).reduce_to:is_i())
    end)

    it('should reduce ZX', function()
      board:put(1, 11, z_gate())
      board:put(1, 12, x_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12).reduce_to:is_y())
    end)

    it('should reduce XZ', function()
      board:put(1, 11, x_gate())
      board:put(1, 12, z_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12).reduce_to:is_y())
    end)

    it('should reduce SS', function()
      board:put(1, 11, s_gate())
      board:put(1, 12, s_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12).reduce_to:is_z())
    end)

    it('should reduce TT', function()
      board:put(1, 11, t_gate())
      board:put(1, 12, t_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12).reduce_to:is_s())
    end)

    it('should reduce SWAP pairs in the same columns', function()
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(1, 12, swap_gate(3))
      board:put(3, 12, swap_gate(1))

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11).reduce_to:is_i())
      assert.is_true(board:gate_at(3, 11).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12).reduce_to:is_i())
      assert.is_true(board:gate_at(3, 12).reduce_to:is_i())
    end)

    it('should reduce hxh', function()
      board:put(1, 10, h_gate())
      board:put(1, 11, x_gate())
      board:put(1, 12, h_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12).reduce_to:is_z())
    end)

    it('should reduce HZH', function()
      board:put(1, 10, h_gate())
      board:put(1, 11, z_gate())
      board:put(1, 12, h_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12).reduce_to:is_x())
    end)

    it('should reduce SZS', function()
      board:put(1, 10, s_gate())
      board:put(1, 11, z_gate())
      board:put(1, 12, s_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12).reduce_to:is_z())
    end)

    it('should reduce CNOT x2', function()
      board:put(1, 11, control_gate(3))
      board:put(3, 11, cnot_x_gate(1))
      board:put(1, 12, control_gate(3))
      board:put(3, 12, cnot_x_gate(1))

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11).reduce_to:is_i())
      assert.is_true(board:gate_at(3, 11).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12).reduce_to:is_i())
      assert.is_true(board:gate_at(3, 12).reduce_to:is_i())
    end)

    it('should reduce CNOT x3', function()
      board:put(1, 10, control_gate(3))
      board:put(3, 10, cnot_x_gate(1))
      board:put(1, 11, cnot_x_gate(3))
      board:put(3, 11, control_gate(1))
      board:put(1, 12, control_gate(3))
      board:put(3, 12, cnot_x_gate(1))

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10).reduce_to:is_i())
      assert.is_true(board:gate_at(3, 10).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11).reduce_to:is_i())
      assert.is_true(board:gate_at(3, 11).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12).reduce_to:is_swap())
      assert.is_true(board:gate_at(3, 12).reduce_to:is_swap())
    end)

    it('should reduce HH CNOT HH', function()
      board:put(1, 10, h_gate())
      board:put(3, 10, h_gate())
      board:put(1, 11, control_gate(3))
      board:put(3, 11, cnot_x_gate(1))
      board:put(1, 12, h_gate())
      board:put(3, 12, h_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10).reduce_to:is_i())
      assert.is_true(board:gate_at(3, 10).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11).reduce_to:is_cnot_x())
      assert.is_true(board:gate_at(3, 11).reduce_to:is_control())
      assert.is_true(board:gate_at(1, 12).reduce_to:is_i())
      assert.is_true(board:gate_at(3, 12).reduce_to:is_i())
    end)

    it('should reduce XX CNOT X', function()
      board:put(1, 10, x_gate())
      board:put(3, 10, x_gate())
      board:put(1, 11, control_gate(3))
      board:put(3, 11, cnot_x_gate(1))
      board:put(1, 12, x_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10).reduce_to:is_i())
      assert.is_true(board:gate_at(3, 10).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11):is_control())
      assert.is_true(board:gate_at(3, 11):is_cnot_x())
      assert.is_true(board:gate_at(1, 12).reduce_to:is_i())
    end)

    it('should reduce zz cx z', function()
      board:put(1, 10, z_gate())
      board:put(3, 10, z_gate())
      board:put(1, 11, control_gate(3))
      board:put(3, 11, cnot_x_gate(1))
      board:put(3, 12, z_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10).reduce_to:is_i())
      assert.is_true(board:gate_at(3, 10).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11):is_control())
      assert.is_true(board:gate_at(3, 11):is_cnot_x())
      assert.is_true(board:gate_at(3, 12).reduce_to:is_i())
    end)


    it('should reduce x xc x', function()
      board:put(1, 10, x_gate())
      board:put(1, 11, cnot_x_gate(3))
      board:put(3, 11, control_gate(1))
      board:put(1, 12, x_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11):is_cnot_x())
      assert.is_true(board:gate_at(3, 11):is_control())
      assert.is_true(board:gate_at(1, 12).reduce_to:is_i())
    end)

    it('should reduce z cx z', function()
      board:put(1, 10, z_gate())
      board:put(1, 11, control_gate(3))
      board:put(3, 11, cnot_x_gate(1))
      board:put(1, 12, z_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11):is_control())
      assert.is_true(board:gate_at(3, 11):is_cnot_x())
      assert.is_true(board:gate_at(1, 12).reduce_to:is_i())
    end)

    it('should reduce xz cz x', function()
      board:put(1, 9, z_gate())
      board:put(1, 10, h_gate())
      board:put(3, 10, x_gate())
      board:put(1, 11, cnot_x_gate(3))
      board:put(3, 11, control_gate(1))
      board:put(1, 12, h_gate())
      board:put(3, 12, x_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 9).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 10):is_h())
      assert.is_true(board:gate_at(3, 10).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11):is_cnot_x())
      assert.is_true(board:gate_at(3, 11):is_control())
      assert.is_true(board:gate_at(1, 12):is_h())
      assert.is_true(board:gate_at(3, 12).reduce_to:is_i())
    end)

    --  H            I
    --  S-S  ----->  S-S
    --    H            I
    it('should reduce H SWAP-SWAP H', function()
      board:put(1, 10, h_gate())
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(3, 12, h_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11):is_swap())
      assert.is_true(board:gate_at(3, 11):is_swap())
      assert.is_true(board:gate_at(3, 12).reduce_to:is_i())
    end)

    --  X            I
    --  S-S  ----->  S-S
    --    X            I
    it('should reduce X SWAP-SWAP X', function()
      board:put(1, 10, x_gate())
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(3, 12, x_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11):is_swap())
      assert.is_true(board:gate_at(3, 11):is_swap())
      assert.is_true(board:gate_at(3, 12).reduce_to:is_i())
    end)

    --  Y            I
    --  S-S  ----->  S-S
    --    Y            I
    it('should reduce Y SWAP-SWAP Y', function()
      board:put(1, 10, y_gate())
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(3, 12, y_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11):is_swap())
      assert.is_true(board:gate_at(3, 11):is_swap())
      assert.is_true(board:gate_at(3, 12).reduce_to:is_i())
    end)

    --  Z            I
    --  S-S  ----->  S-S
    --    Z            I
    it('should reduce Z SWAP-SWAP Z', function()
      board:put(1, 10, z_gate())
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(3, 12, z_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11):is_swap())
      assert.is_true(board:gate_at(3, 11):is_swap())
      assert.is_true(board:gate_at(3, 12).reduce_to:is_i())
    end)

    --  S            Z
    --  S-S  ----->  S-S
    --    S            I
    it('should reduce S SWAP-SWAP S', function()
      board:put(1, 10, s_gate())
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(3, 12, s_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10).reduce_to:is_z())
      assert.is_true(board:gate_at(1, 11):is_swap())
      assert.is_true(board:gate_at(3, 11):is_swap())
      assert.is_true(board:gate_at(3, 12).reduce_to:is_i())
    end)

    --  T            S
    --  S-S  ----->  S-S
    --    T            I
    it('should reduce T SWAP-SWAP T', function()
      board:put(1, 10, t_gate())
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(3, 12, t_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10).reduce_to:is_s())
      assert.is_true(board:gate_at(1, 11):is_swap())
      assert.is_true(board:gate_at(3, 11):is_swap())
      assert.is_true(board:gate_at(3, 12).reduce_to:is_i())
    end)

    --  C-X          I I
    --  S-S  ----->  S-S
    --  X-C          I I
    it('should reduce C-X SWAP-SWAP X-C', function()
      board:put(1, 10, control_gate(3))
      board:put(3, 10, cnot_x_gate(1))
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(1, 12, cnot_x_gate(3))
      board:put(3, 12, control_gate(1))

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10).reduce_to:is_i())
      assert.is_true(board:gate_at(3, 10).reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11):is_swap())
      assert.is_true(board:gate_at(3, 11):is_swap())
      assert.is_true(board:gate_at(1, 12).reduce_to:is_i())
      assert.is_true(board:gate_at(3, 12).reduce_to:is_i())
    end)
  end)

  describe('drop_gates', function()
    it('should drop gates', function()
      board:put(1, 1, h_gate())

      board:drop_gates()

      assert.is_true(board:gate_at(1, 1):is_dropping())
    end)

    it('should drop swap pair', function()
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(3, 12, h_gate())

      board:swap(2, 3, 11)

      board:update()
      board:update()
      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(board:gate_at(1, 11):is_dropping())
      assert.is_true(board:gate_at(2, 11):is_dropping())
    end)
  end)

  describe('render', function()
    it('should render without errors', function()
      assert.has_no.errors(function() board:render() end)
    end)
  end)
end)
