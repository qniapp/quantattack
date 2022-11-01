require("engine/test/bustedhelper")
require("engine/debug/dump")
require("board")
require("gate")

local profiler = require("profiler")

describe('board', function()
  local board

  before_each(function()
    board = create_board()
  end)

  describe('swap', function()
    it('should swap gates next to each other', function()
      board:put(1, 12, h_gate())
      board:put(2, 12, x_gate())

      local swapped = board:swap(1, 12)

      assert.is_true(swapped)
      assert.are_equal("h", board:gate_at(1, 12).type)
      assert.are_equal("x", board:gate_at(2, 12).type)
      assert.is_true(board:gate_at(1, 12):is_swapping())
      assert.is_true(board:gate_at(2, 12):is_swapping())
    end)

    it('should not swap gates if the left gate is in swap', function()
      board:put(2, 12, h_gate())
      board:gate_at(2, 12):swap_with_left(1)
      board:put(3, 12, x_gate())

      local swapped = board:swap(2, 12)

      assert.is_false(swapped)
      assert.are_equal("x", board:gate_at(3, 12).type)
      assert.is_true(board:gate_at(3, 12):is_idle())
    end)

    it('should not swap gates if the right gate is in swap', function()
      board:put(1, 12, h_gate())
      board:put(2, 12, x_gate())
      board:gate_at(2, 12):swap_with_right(3)

      local swapped = board:swap(1, 12)

      assert.is_false(swapped)
      assert.are_equal("h", board:gate_at(1, 12).type)
      assert.is_true(board:gate_at(1, 12):is_idle())
    end)

    -- (S は SWAP ゲート)
    --
    --  S-S →(右 の S を左の I と入れ換え)→ SS
    it('should update swap_gate.other_x after a swap', function()
      board:put(1, 12, swap_gate(3))
      board:put(3, 12, swap_gate(1))

      board:swap(2, 12)
      board:update()
      board:update()
      board:update()
      board:update()
      board:update()

      assert.are_equal(2, board:gate_at(1, 12).other_x)
    end)

    it('SWAP 同士の入れ替え', function()
      board:put(1, 12, swap_gate(2))
      board:put(2, 12, swap_gate(1))

      board:swap(1, 12)
      board:update()
      board:update()
      board:update()
      board:update()
      board:update()

      assert.are_equal(2, board:gate_at(1, 12).other_x)
      assert.are_equal(1, board:gate_at(2, 12).other_x)
    end)

    it('おじゃまユニタリが左側にある場合、入れ替えできない', function()
      -- !!!x__
      board:put(1, 12, garbage_gate(3))
      board:put(4, 12, x_gate())

      assert.is_false(board:swap(3, 12))
    end)

    it('おじゃまユニタリが右側にある場合、入れ替えできない', function()
      -- __x!!!
      board:put(3, 12, x_gate())
      board:put(4, 12, garbage_gate(3))

      assert.is_false(board:swap(3, 12))
    end)
  end)

  describe('reduce', function()
    --
    -- reduce -> H
    --           -
    --           X (next gates)
    it('should not reduce when y is the last and include_next_gates = true', function()
      board:put(1, board.rows, h_gate())
      board:put(1, board.row_next_gates, x_gate())

      local reduction = board:reduce(1, board.rows, true)

      assert.are.same({}, reduction.to)
    end)

    --
    -- reduce -> H
    --           -
    --           X (next gates)
    it('should not reduce when y is the last and include_next_gates = true', function()
      board:put(1, board.rows, h_gate())
      board:put(1, board.row_next_gates, x_gate())

      local reduction = board:reduce(1, board.rows, true)

      assert.are.same({}, reduction.to)
    end)

    --           -
    -- reduce -> I (next gates)
    it('should not reduce when y is the next gates row and include_next_gates = true', function()
      local reduction = board:reduce(1, board.row_next_gates, true)

      assert.are.same({}, reduction.to)
    end)
  end)

  describe('reduce_gates', function()
    it('should reduce HH', function()
      board:put(1, 11, h_gate())
      board:put(1, 12, h_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11)._reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12)._reduce_to:is_i())
    end)

    it('should reduce XX', function()
      board:put(1, 11, x_gate())
      board:put(1, 12, x_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11)._reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12)._reduce_to:is_i())
    end)

    it('should reduce YY', function()
      board:put(1, 11, y_gate())
      board:put(1, 12, y_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11)._reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12)._reduce_to:is_i())
    end)

    it('should reduce ZZ', function()
      board:put(1, 11, z_gate())
      board:put(1, 12, z_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11)._reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12)._reduce_to:is_i())
    end)

    it('should reduce SS', function()
      board:put(1, 11, s_gate())
      board:put(1, 12, s_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11)._reduce_to:is_i())
      assert.are_equal("z", board:gate_at(1, 12)._reduce_to.type)
    end)

    it('should reduce TT', function()
      board:put(1, 11, t_gate())
      board:put(1, 12, t_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11)._reduce_to:is_i())
      assert.are_equal("s", board:gate_at(1, 12)._reduce_to.type)
    end)

    it('should reduce XZ', function()
      board:put(1, 11, x_gate())
      board:put(1, 12, z_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11)._reduce_to:is_i())
      assert.are_equal("y", board:gate_at(1, 12)._reduce_to.type)
    end)

    it('should reduce ZX', function()
      board:put(1, 11, z_gate())
      board:put(1, 12, x_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11)._reduce_to:is_i())
      assert.are_equal("y", board:gate_at(1, 12)._reduce_to.type)
    end)

    it('should reduce HXH', function()
      board:put(1, 10, h_gate())
      board:put(1, 11, x_gate())
      board:put(1, 12, h_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10)._reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11)._reduce_to:is_i())
      assert.are_equal("z", board:gate_at(1, 12)._reduce_to.type)
    end)

    it('should reduce HZH', function()
      board:put(1, 10, h_gate())
      board:put(1, 11, z_gate())
      board:put(1, 12, h_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10)._reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11)._reduce_to:is_i())
      assert.are_equal("x", board:gate_at(1, 12)._reduce_to.type)
    end)

    it('should reduce SZS', function()
      board:put(1, 10, s_gate())
      board:put(1, 11, z_gate())
      board:put(1, 12, s_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10)._reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11)._reduce_to:is_i())
      assert.are_equal("z", board:gate_at(1, 12)._reduce_to.type)
    end)

    it('should reduce TST', function()
      board:put(1, 10, t_gate())
      board:put(1, 11, s_gate())
      board:put(1, 12, t_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10)._reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11)._reduce_to:is_i())
      assert.are_equal("z", board:gate_at(1, 12)._reduce_to.type)
    end)

    it('should reduce TZST', function()
      board:put(1, 9, t_gate())
      board:put(1, 10, z_gate())
      board:put(1, 11, s_gate())
      board:put(1, 12, t_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 9)._reduce_to:is_i())
      assert.is_true(board:gate_at(1, 10)._reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11)._reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12)._reduce_to:is_i())
    end)

    it('should reduce TSZT', function()
      board:put(1, 9, t_gate())
      board:put(1, 10, s_gate())
      board:put(1, 11, z_gate())
      board:put(1, 12, t_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 9)._reduce_to:is_i())
      assert.is_true(board:gate_at(1, 10)._reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11)._reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12)._reduce_to:is_i())
    end)

    it('should reduce C-X x2', function()
      board:put(1, 11, control_gate(3))
      board:put(3, 11, cnot_x_gate(1))
      board:put(1, 12, control_gate(3))
      board:put(3, 12, cnot_x_gate(1))

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 11)._reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    it('should reduce X-C x2', function()
      board:put(1, 11, cnot_x_gate(3))
      board:put(3, 11, control_gate(1))
      board:put(1, 12, cnot_x_gate(3))
      board:put(3, 12, control_gate(1))

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 11)._reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    -- C-X          I I
    -- X-C          I I
    -- C-X  ----->  S-S
    it('should reduce C-X X-C C-X', function()
      board:put(1, 10, control_gate(3))
      board:put(3, 10, cnot_x_gate(1))
      board:put(1, 11, cnot_x_gate(3))
      board:put(3, 11, control_gate(1))
      board:put(1, 12, control_gate(3))
      board:put(3, 12, cnot_x_gate(1))

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 10)._reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 11)._reduce_to:is_i())
      assert.are_equal("swap", board:gate_at(1, 12)._reduce_to.type)
      assert.are_equal(3, board:gate_at(1, 12)._reduce_to.other_x)
      assert.are_equal("swap", board:gate_at(3, 12)._reduce_to.type)
      assert.are_equal(1, board:gate_at(3, 12)._reduce_to.other_x)
    end)

    -- X-C          I I
    -- C-X          I I
    -- X-C  ----->  S-S
    it('should reduce C-X X-C C-X', function()
      board:put(1, 10, cnot_x_gate(3))
      board:put(3, 10, control_gate(1))
      board:put(1, 11, control_gate(3))
      board:put(3, 11, cnot_x_gate(1))
      board:put(1, 12, cnot_x_gate(3))
      board:put(3, 12, control_gate(1))

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 10)._reduce_to:is_i())
      assert.is_true(board:gate_at(1, 11)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 11)._reduce_to:is_i())
      assert.are_equal("swap", board:gate_at(1, 12)._reduce_to.type)
      assert.are_equal(3, board:gate_at(1, 12)._reduce_to.other_x)
      assert.are_equal("swap", board:gate_at(3, 12)._reduce_to.type)
      assert.are_equal(1, board:gate_at(3, 12)._reduce_to.other_x)
    end)

    it('should reduce HH C-X HH', function()
      board:put(1, 10, h_gate())
      board:put(3, 10, h_gate())
      board:put(1, 11, control_gate(3))
      board:put(3, 11, cnot_x_gate(1))
      board:put(1, 12, h_gate())
      board:put(3, 12, h_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 10)._reduce_to:is_i())
      assert.are_equal("cnot_x", board:gate_at(1, 11)._reduce_to.type)
      assert.are_equal(3, board:gate_at(1, 11)._reduce_to.other_x)
      assert.are_equal("control", board:gate_at(3, 11)._reduce_to.type)
      assert.are_equal(1, board:gate_at(3, 11)._reduce_to.other_x)
      assert.is_true(board:gate_at(1, 12)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    it('should reduce HH X-C HH', function()
      board:put(1, 10, h_gate())
      board:put(3, 10, h_gate())
      board:put(1, 11, cnot_x_gate(3))
      board:put(3, 11, control_gate(1))
      board:put(1, 12, h_gate())
      board:put(3, 12, h_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 10)._reduce_to:is_i())
      assert.are_equal("control", board:gate_at(1, 11)._reduce_to.type)
      assert.are_equal(3, board:gate_at(1, 11)._reduce_to.other_x)
      assert.are_equal("cnot_x", board:gate_at(3, 11)._reduce_to.type)
      assert.are_equal(1, board:gate_at(3, 11)._reduce_to.other_x)
      assert.is_true(board:gate_at(1, 12)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    it('should reduce XX C-X X', function()
      board:put(1, 10, x_gate())
      board:put(3, 10, x_gate())
      board:put(1, 11, control_gate(3))
      board:put(3, 11, cnot_x_gate(1))
      board:put(1, 12, x_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 10)._reduce_to:is_i())
      assert.are_equal("control", board:gate_at(1, 11).type)
      assert.are_equal("cnot_x", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(1, 12)._reduce_to:is_i())
    end)

    it('should reduce XX X-C X', function()
      board:put(1, 10, x_gate())
      board:put(3, 10, x_gate())
      board:put(1, 11, cnot_x_gate(3))
      board:put(3, 11, control_gate(1))
      board:put(3, 12, x_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 10)._reduce_to:is_i())
      assert.are_equal("cnot_x", board:gate_at(1, 11).type)
      assert.are_equal("control", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    it('should reduce ZZ C-X Z', function()
      board:put(1, 10, z_gate())
      board:put(3, 10, z_gate())
      board:put(1, 11, control_gate(3))
      board:put(3, 11, cnot_x_gate(1))
      board:put(3, 12, z_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 10)._reduce_to:is_i())
      assert.are_equal("control", board:gate_at(1, 11).type)
      assert.are_equal("cnot_x", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    it('should reduce ZZ X-C Z', function()
      board:put(1, 10, z_gate())
      board:put(3, 10, z_gate())
      board:put(1, 11, cnot_x_gate(3))
      board:put(3, 11, control_gate(1))
      board:put(1, 12, z_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 10)._reduce_to:is_i())
      assert.are_equal("cnot_x", board:gate_at(1, 11).type)
      assert.are_equal("control", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(1, 12)._reduce_to:is_i())
    end)

    it('should reduce X C-X X', function()
      board:put(3, 10, x_gate())
      board:put(1, 11, control_gate(3))
      board:put(3, 11, cnot_x_gate(1))
      board:put(3, 12, x_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(3, 10)._reduce_to:is_i())
      assert.are_equal("control", board:gate_at(1, 11).type)
      assert.are_equal("cnot_x", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    it('should reduce X X-C X', function()
      board:put(1, 10, x_gate())
      board:put(1, 11, cnot_x_gate(3))
      board:put(3, 11, control_gate(1))
      board:put(1, 12, x_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10)._reduce_to:is_i())
      assert.are_equal("cnot_x", board:gate_at(1, 11).type)
      assert.are_equal("control", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(1, 12)._reduce_to:is_i())
    end)

    it('should reduce Z C-X Z', function()
      board:put(1, 10, z_gate())
      board:put(1, 11, control_gate(3))
      board:put(3, 11, cnot_x_gate(1))
      board:put(1, 12, z_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10)._reduce_to:is_i())
      assert.are_equal("control", board:gate_at(1, 11).type)
      assert.are_equal("cnot_x", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(1, 12)._reduce_to:is_i())
    end)

    it('should reduce Z X-C Z', function()
      board:put(3, 10, z_gate())
      board:put(1, 11, cnot_x_gate(3))
      board:put(3, 11, control_gate(1))
      board:put(3, 12, z_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(3, 10)._reduce_to:is_i())
      assert.are_equal("cnot_x", board:gate_at(1, 11).type)
      assert.are_equal("control", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    it('should reduce S-S x2', function()
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(1, 12, swap_gate(3))
      board:put(3, 12, swap_gate(1))

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 11)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 11)._reduce_to:is_i())
      assert.is_true(board:gate_at(1, 12)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    --  H            I
    --  S-S  ----->  S-S
    --    H            I
    it('H S-S H を簡約する', function()
      board:put(1, 10, h_gate())
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(1, 12, x_gate()) -- 適当なゴミを置いとく
      board:put(3, 12, h_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10)._reduce_to:is_i())
      assert.are_equal("swap", board:gate_at(1, 11).type)
      assert.are_equal("swap", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    --    H            I
    --  S-S  ----->  S-S
    --  H            I
    it('H S-S H を簡約する (反対側)', function()
      board:put(3, 10, h_gate())
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(1, 12, h_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(3, 10)._reduce_to:is_i())
      assert.are_equal("swap", board:gate_at(1, 11).type)
      assert.are_equal("swap", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(1, 12)._reduce_to:is_i())
    end)

    --  X            I
    --  S-S  ----->  S-S
    --    X            I
    it('X S-S X を簡約する', function()
      board:put(1, 10, x_gate())
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(3, 12, x_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10)._reduce_to:is_i())
      assert.are_equal("swap", board:gate_at(1, 11).type)
      assert.are_equal("swap", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    --    X            I
    --  S-S  ----->  S-S
    --  X            I
    it('X S-S X を簡約する (反対側)', function()
      board:put(3, 10, x_gate())
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(1, 12, x_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(3, 10)._reduce_to:is_i())
      assert.are_equal("swap", board:gate_at(1, 11).type)
      assert.are_equal("swap", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(1, 12)._reduce_to:is_i())
    end)

    --  Y            I
    --  S-S  ----->  S-S
    --    Y            I
    it('should reduce Y S-S Y', function()
      board:put(1, 10, y_gate())
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(3, 12, y_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10)._reduce_to:is_i())
      assert.are_equal("swap", board:gate_at(1, 11).type)
      assert.are_equal("swap", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    --  Z            I
    --  S-S  ----->  S-S
    --    Z            I
    it('should reduce Z S-S Z', function()
      board:put(2, 10, z_gate())
      board:put(2, 11, swap_gate(4))
      board:put(4, 11, swap_gate(2))
      board:put(2, 12, cnot_x_gate(1)) -- 適当なゴミを置いとく
      board:put(4, 12, z_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(2, 10)._reduce_to:is_i())
      assert.are_equal("swap", board:gate_at(2, 11).type)
      assert.are_equal("swap", board:gate_at(4, 11).type)
      assert.is_true(board:gate_at(4, 12)._reduce_to:is_i())
    end)

    --  s            Z
    --  S-S  ----->  S-S
    --    s            I
    it('should reduce S S-S S', function()
      board:put(1, 10, s_gate())
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(3, 12, s_gate())

      board:reduce_gates()

      assert.are_equal("z", board:gate_at(1, 10)._reduce_to.type)
      assert.are_equal("swap", board:gate_at(1, 11).type)
      assert.are_equal("swap", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    --  T            S
    --  S-S  ----->  S-S
    --    T            I
    it('should reduce T S-S T', function()
      board:put(1, 10, t_gate())
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(3, 12, t_gate())

      board:reduce_gates()

      assert.are_equal("s", board:gate_at(1, 10)._reduce_to.type)
      assert.are_equal("swap", board:gate_at(1, 11).type)
      assert.are_equal("swap", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    --  X            Y
    --  S-S  ----->  S-S
    --    Z            I
    it('should reduce X S-S Z', function()
      board:put(1, 10, x_gate())
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(3, 12, z_gate())

      board:reduce_gates()

      assert.are_equal("y", board:gate_at(1, 10)._reduce_to.type)
      assert.are_equal("swap", board:gate_at(1, 11).type)
      assert.are_equal("swap", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    --  H            I
    --  X            Z
    --  S-S  ----->  S-S
    --    H            I
    it('should reduce HX S-S H', function()
      board:put(1, 9, h_gate())
      board:put(1, 10, x_gate())
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(3, 12, h_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 9)._reduce_to:is_i())
      assert.are_equal("z", board:gate_at(1, 10)._reduce_to.type)
      assert.are_equal("swap", board:gate_at(1, 11).type)
      assert.are_equal("swap", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    --  H            Z
    --  S-S  ----->  S-S
    --    X            I
    --    H            I
    it('should reduce H S-S XH', function()
      board:put(1, 9, h_gate())
      board:put(1, 10, swap_gate(3))
      board:put(3, 10, swap_gate(1))
      board:put(3, 11, x_gate())
      board:put(3, 12, h_gate())

      board:reduce_gates()

      assert.are_equal("z", board:gate_at(1, 9)._reduce_to.type)
      assert.are_equal("swap", board:gate_at(1, 10).type)
      assert.are_equal("swap", board:gate_at(3, 10).type)
      assert.is_true(board:gate_at(3, 11)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    --  H            I
    --  Z            X
    --  S-S  ----->  S-S
    --    H            I
    it('should reduce HZ S-S H', function()
      board:put(1, 9, h_gate())
      board:put(1, 10, z_gate())
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(3, 12, h_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 9)._reduce_to:is_i())
      assert.are_equal("x", board:gate_at(1, 10)._reduce_to.type)
      assert.are_equal("swap", board:gate_at(1, 11).type)
      assert.are_equal("swap", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    --  H            X
    --  S-S  ----->  S-S
    --    Z            I
    --    H            I
    it('should reduce H S-S ZH', function()
      board:put(1, 9, h_gate())
      board:put(1, 10, swap_gate(3))
      board:put(3, 10, swap_gate(1))
      board:put(3, 11, z_gate())
      board:put(3, 12, h_gate())

      board:reduce_gates()

      assert.are_equal("x", board:gate_at(1, 9)._reduce_to.type)
      assert.are_equal("swap", board:gate_at(1, 10).type)
      assert.are_equal("swap", board:gate_at(3, 10).type)
      assert.is_true(board:gate_at(3, 11)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    --  S            I
    --  Z            Z
    --  S-S  ----->  S-S
    --    S            I
    it('should reduce SZ S-S S', function()
      board:put(1, 9, s_gate())
      board:put(1, 10, z_gate())
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(3, 12, s_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 9)._reduce_to:is_i())
      assert.are_equal("z", board:gate_at(1, 10)._reduce_to.type)
      assert.are_equal("swap", board:gate_at(1, 11).type)
      assert.are_equal("swap", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    --  S            Z
    --  S-S  ----->  S-S
    --    Z            I
    --    S            I
    it('should reduce S S-S ZS', function()
      board:put(1, 9, s_gate())
      board:put(1, 10, swap_gate(3))
      board:put(3, 10, swap_gate(1))
      board:put(3, 11, z_gate())
      board:put(3, 12, s_gate())

      board:reduce_gates()

      assert.are_equal("z", board:gate_at(1, 9)._reduce_to.type)
      assert.are_equal("swap", board:gate_at(1, 10).type)
      assert.are_equal("swap", board:gate_at(3, 10).type)
      assert.is_true(board:gate_at(3, 11)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    --  T            I
    --  S            Z
    --  S-S  ----->  S-S
    --    T            I
    it('should reduce TS S-S T', function()
      board:put(1, 9, t_gate())
      board:put(1, 10, s_gate())
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(3, 12, t_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 9)._reduce_to:is_i())
      assert.are_equal("z", board:gate_at(1, 10)._reduce_to.type)
      assert.are_equal("swap", board:gate_at(1, 11).type)
      assert.are_equal("swap", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    --  T            Z
    --  S-S  ----->  S-S
    --    S            I
    --    T            I
    it('should reduce T S-S ST', function()
      board:put(1, 9, t_gate())
      board:put(1, 10, swap_gate(3))
      board:put(3, 10, swap_gate(1))
      board:put(3, 11, s_gate())
      board:put(3, 12, t_gate())

      board:reduce_gates()

      assert.are_equal("z", board:gate_at(1, 9)._reduce_to.type)
      assert.are_equal("swap", board:gate_at(1, 10).type)
      assert.are_equal("swap", board:gate_at(3, 10).type)
      assert.is_true(board:gate_at(3, 11)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    --  T            I
    --  S-S  ----->  S-S
    --    Z            I
    --    S            I
    --    T            I
    it('should reduce T S-S ZST', function()
      board:put(1, 8, t_gate())
      board:put(1, 9, swap_gate(3))
      board:put(3, 9, swap_gate(1))
      board:put(3, 10, z_gate())
      board:put(3, 11, s_gate())
      board:put(3, 12, t_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 8)._reduce_to:is_i())
      assert.are_equal("swap", board:gate_at(1, 9).type)
      assert.are_equal("swap", board:gate_at(3, 9).type)
      assert.is_true(board:gate_at(3, 10)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 11)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    --  T            I
    --  S-S  ----->  S-S
    --    S            I
    --    Z            I
    --    T            I
    it('should reduce T S-S SZT', function()
      board:put(1, 8, t_gate())
      board:put(1, 9, swap_gate(3))
      board:put(3, 9, swap_gate(1))
      board:put(3, 10, s_gate())
      board:put(3, 11, z_gate())
      board:put(3, 12, t_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 8)._reduce_to:is_i())
      assert.are_equal("swap", board:gate_at(1, 9).type)
      assert.are_equal("swap", board:gate_at(3, 9).type)
      assert.is_true(board:gate_at(3, 10)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 11)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    --  Z            I
    --  H X          H I
    --  X-C  ----->  X-C
    --  H X          H I
    it('should reduce Z HX X-C HX', function()
      board:put(1, 9, z_gate())
      board:put(1, 10, h_gate())
      board:put(3, 10, x_gate())
      board:put(1, 11, cnot_x_gate(3))
      board:put(3, 11, control_gate(1))
      board:put(1, 12, h_gate())
      board:put(3, 12, x_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 9)._reduce_to:is_i())
      assert.are_equal("h", board:gate_at(1, 10).type)
      assert.is_true(board:gate_at(3, 10)._reduce_to:is_i())
      assert.are_equal("cnot_x", board:gate_at(1, 11).type)
      assert.are_equal("control", board:gate_at(3, 11).type)
      assert.are_equal("h", board:gate_at(1, 12).type)
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    --  X            I
    --  H Z          H I
    --  X-C  ----->  X-C
    --  H            H
    --  X            I
    it('should reduce X HZ X-C H X', function()
      board:put(1, 8, x_gate())
      board:put(1, 9, h_gate())
      board:put(3, 9, z_gate())
      board:put(1, 10, cnot_x_gate(3))
      board:put(3, 10, control_gate(1))
      board:put(1, 11, h_gate())
      board:put(1, 12, x_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 8)._reduce_to:is_i())
      assert.are_equal("h", board:gate_at(1, 9).type)
      assert.is_true(board:gate_at(3, 9)._reduce_to:is_i())
      assert.are_equal("cnot_x", board:gate_at(1, 10).type)
      assert.are_equal("control", board:gate_at(3, 10).type)
      assert.are_equal("h", board:gate_at(1, 11).type)
      assert.is_true(board:gate_at(1, 12)._reduce_to:is_i())
    end)

    --  H Z          H I
    --  X-C  ----->  X-C
    --  H Z          H I
    it('should reduce HZ X-C HZ', function()
      board:put(1, 10, h_gate())
      board:put(3, 10, z_gate())
      board:put(1, 11, cnot_x_gate(3))
      board:put(3, 11, control_gate(1))
      board:put(1, 12, h_gate())
      board:put(3, 12, z_gate())

      board:reduce_gates()

      assert.are_equal("h", board:gate_at(1, 10).type)
      assert.is_true(board:gate_at(3, 10)._reduce_to:is_i())
      assert.are_equal("cnot_x", board:gate_at(1, 11).type)
      assert.are_equal("control", board:gate_at(3, 11).type)
      assert.are_equal("h", board:gate_at(1, 12).type)
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    --  Z            I
    --  H            H
    --  X-C  ----->  X-C
    --  H            H
    --  Z            I
    it('should reduce Z H X-C H Z', function()
      board:put(1, 8, z_gate())
      board:put(1, 9, h_gate())
      board:put(1, 10, cnot_x_gate(3))
      board:put(3, 10, control_gate(1))
      board:put(1, 11, h_gate())
      board:put(1, 12, z_gate())

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 8)._reduce_to:is_i())
      assert.are_equal("h", board:gate_at(1, 9).type)
      assert.are_equal("cnot_x", board:gate_at(1, 10).type)
      assert.are_equal("control", board:gate_at(3, 10).type)
      assert.are_equal("h", board:gate_at(1, 11).type)
      assert.is_true(board:gate_at(1, 12)._reduce_to:is_i())
    end)

    --  C-X          I I
    --  S-S  ----->  S-S
    --  X-C          I I
    it('should reduce C-X S-S X-C', function()
      board:put(1, 10, control_gate(3))
      board:put(3, 10, cnot_x_gate(1))
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(1, 12, cnot_x_gate(3))
      board:put(3, 12, control_gate(1))

      board:reduce_gates()

      assert.is_true(board:gate_at(1, 10)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 10)._reduce_to:is_i())
      assert.are_equal("swap", board:gate_at(1, 11).type)
      assert.are_equal("swap", board:gate_at(3, 11).type)
      assert.is_true(board:gate_at(1, 12)._reduce_to:is_i())
      assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    end)

    it('おじゃまゲートの左に隣接するゲートがマッチした時、おじゃまゲートが破壊される'
      , function()
      local h = h_gate()

      board:put(1, 12, h)
      board:put(2, 12, garbage_gate(2))
      h._state = "match"

      board:reduce_gates()

      assert.are_equal('!', board:gate_at(2, 12).type)
    end)

    it('おじゃまゲートの右に隣接するゲートがマッチした時、おじゃまゲートが破壊される'
      , function()
      local h = h_gate()

      board:put(3, 12, h)
      board:put(1, 12, garbage_gate(2))
      h._state = "match"

      board:reduce_gates()

      assert.are_equal('!', board:gate_at(1, 12).type)
    end)

    it('おじゃまゲートの上に隣接するゲートがマッチした時、おじゃまゲートが破壊される'
      , function()
      local h = h_gate()

      board:put(1, 11, h)
      board:put(1, 12, garbage_gate(2))
      h._state = "match"

      board:reduce_gates()

      assert.are_equal('!', board:gate_at(1, 12).type)
    end)

    it('おじゃまゲートの下に隣接するゲートがマッチした時、おじゃまゲートが破壊される'
      , function()
      local h = h_gate()

      board:put(1, 11, garbage_gate(2))
      board:put(1, 12, h)
      h._state = "match"

      board:reduce_gates()

      assert.are_equal('!', board:gate_at(1, 11).type)
    end)

    -- it('should reduce xz cz x', function()
    --   board:put(1, 9, z_gate())
    --   board:put(1, 10, h_gate())
    --   board:put(3, 10, x_gate())
    --   board:put(1, 11, cnot_x_gate(3))
    --   board:put(3, 11, control_gate(1))
    --   board:put(1, 12, h_gate())
    --   board:put(3, 12, x_gate())

    --   board:reduce_gates()

    --   assert.is_true(board:gate_at(1, 9)._reduce_to:is_i())
    --   assert.is_true(board:gate_at(1, 10):is_h())
    --   assert.is_true(board:gate_at(3, 10)._reduce_to:is_i())
    --   assert.is_true(board:gate_at(1, 11).type)
    --   assert.is_true(board:gate_at(3, 11).type)
    --   assert.is_true(board:gate_at(1, 12):is_h())
    --   assert.is_true(board:gate_at(3, 12)._reduce_to:is_i())
    -- end)
  end)

  describe('fall_gates', function()
    it('should drop gates', function()
      board:put(1, 1, h_gate())

      board:fall_gates()

      assert.is_true(board:gate_at(1, 1):is_falling())
    end)
  end)

  describe('update', function()
    it('should drop swap pair', function()
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(3, 12, h_gate())

      board:swap(2, 11)

      board:update()
      board:update()
      board:update()
      board:update()
      board:update()
      board:fall_gates()
      board:_update_gates()
      board:update()

      assert.are_equal('swap', board:gate_at(1, 11).type)
      assert.is_true(board:gate_at(1, 11):is_falling())
      assert.are_equal('swap', board:gate_at(2, 11).type)
      assert.is_true(board:gate_at(2, 11):is_falling())
    end)

    --
    -- S-S
    --  ?
    --  ?
    --  ? ←
    --  ? ← ここを消した時に S-S が正しく落ちる
    it('swap ペアの真ん中が消えた時に正しく落ちる', function()
      board:put(1, 1, swap_gate(3))
      board:put(3, 1, swap_gate(1))
      board:put(2, 2, x_gate())
      board:put(2, 3, y_gate())
      board:put(2, 4, h_gate())
      board:put(2, 5, x_gate())
      board:put(2, 6, y_gate())
      board:put(2, 7, h_gate())
      board:put(2, 8, x_gate())
      board:put(2, 9, y_gate())
      board:put(2, 10, h_gate())
      board:put(2, 11, x_gate())
      board:put(2, 12, y_gate())
      board:put(1, 12, x_gate())

      board:swap(1, 12)

      for i = 1, 100 do
        board:update()
      end

      assert.are_equal("swap", board:gate_at(1, 3).type)
      assert.are_equal("swap", board:gate_at(3, 3).type)
    end)

    --
    -- S-S
    --  ?
    --  ?
    --  ? ←
    --  ? ← ここを消した時に S-S が正しく落ちる
    it('swap ペアの真ん中が消えた時に正しく落ちる (raised_dots > 0)', function()
      board.raised_dots = 3

      board:put(1, 1, swap_gate(3))
      board:put(3, 1, swap_gate(1))
      board:put(2, 2, x_gate())
      board:put(2, 3, y_gate())
      board:put(2, 4, h_gate())
      board:put(2, 5, x_gate())
      board:put(2, 6, y_gate())
      board:put(2, 7, h_gate())
      board:put(2, 8, x_gate())
      board:put(2, 9, y_gate())
      board:put(2, 10, h_gate())
      board:put(2, 11, x_gate())
      board:put(2, 12, y_gate())
      board:put(1, 12, x_gate())
      board:put(1, 13, y_gate())
      board:put(2, 13, h_gate())

      board:swap(1, 12)

      for i = 1, 100 do
        board:update()
      end

      assert.are_equal("swap", board:gate_at(1, 3).type)
      assert.are_equal("swap", board:gate_at(3, 3).type)
    end)

    it('CNOT 下のゲートを入れ替えて落としたときに消えない', function()
      board:put(5, 4, control_gate(6))
      board:put(6, 4, cnot_x_gate(5))
      board:put(6, 5, s_gate())
      board:put(6, 6, z_gate())
      board:put(6, 7, t_gate())
      board:put(6, 8, x_gate())
      board:put(6, 9, t_gate())
      board:put(6, 10, x_gate())
      board:put(6, 11, t_gate())
      board:put(6, 12, x_gate())

      board:swap(5, 5)

      profiler.start()

      for i = 0, 100 do
        board:update()
      end

      profiler.stop()
      profiler.report("profiler.log")

      assert.are_equal("s", board:gate_at(5, 12).type)
    end)
  end)

  describe('render', function()
    it('should render without errors', function()
      assert.has_no.errors(function() board:render() end)
    end)
  end)

  describe('is_gate_fallable', function()
    it('SWAP ゲートの下にゲートが無い場合 true を返す', function()
      board:put(1, 1, swap_gate(2))
      board:put(2, 1, swap_gate(1))

      assert.is_true(board:is_gate_fallable(1, 1))
      assert.is_true(board:is_gate_fallable(2, 1))
    end)

    -- S-S
    -- H
    it('SWAP ゲートが下に落とせない場合 false を返す (左端下にゲート)', function()
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(1, 12, h_gate())

      assert.is_false(board:is_gate_fallable(1, 11))
      assert.is_false(board:is_gate_fallable(3, 11))
    end)

    -- S-S
    --  H
    it('SWAP ゲートが下に落とせない場合 false を返す (真ん中下にゲート)', function()
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(2, 12, h_gate())

      assert.is_false(board:is_gate_fallable(1, 11))
      assert.is_false(board:is_gate_fallable(3, 11))
    end)

    -- S-S
    --   H
    it('SWAP ゲートが下に落とせない場合 false を返す (右端下にゲート)', function()
      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(3, 12, h_gate())

      assert.is_false(board:is_gate_fallable(1, 11))
      assert.is_false(board:is_gate_fallable(3, 11))
    end)

    -- S-S
    -- H (falling)
    it('SWAP ゲートの下にゲートがあるが落下中の場合 true を返す', function()
      local h = h_gate()
      h._state = "falling"

      board:put(1, 11, swap_gate(3))
      board:put(3, 11, swap_gate(1))
      board:put(1, 12, h)

      assert.is_true(board:is_gate_fallable(1, 11))
      assert.is_true(board:is_gate_fallable(3, 11))
    end)
  end)

  describe('is_empty', function()
    it('おじゃまユニタリの領域は空ではない', function()
      board:put(2, 11, garbage_gate(4))

      assert.is_true(board:is_empty(1, 11))
      assert.is_false(board:is_empty(2, 11))
      assert.is_false(board:is_empty(3, 11))
      assert.is_false(board:is_empty(4, 11))
      assert.is_false(board:is_empty(5, 11))
      assert.is_true(board:is_empty(6, 11))
    end)

    it('S--S の間は空ではない', function()
      board:put(2, 11, swap_gate(5))
      board:put(5, 11, swap_gate(2))

      assert.is_true(board:is_empty(1, 11))
      assert.is_false(board:is_empty(2, 11))
      assert.is_false(board:is_empty(3, 11))
      assert.is_false(board:is_empty(4, 11))
      assert.is_false(board:is_empty(5, 11))
      assert.is_true(board:is_empty(6, 11))
    end)

    it('C--X の間は空ではない', function()
      board:put(2, 11, control_gate(5))
      board:put(5, 11, cnot_x_gate(2))

      assert.is_true(board:is_empty(1, 11))
      assert.is_false(board:is_empty(2, 11))
      assert.is_false(board:is_empty(3, 11))
      assert.is_false(board:is_empty(4, 11))
      assert.is_false(board:is_empty(5, 11))
      assert.is_true(board:is_empty(6, 11))
    end)

    it('X--C の間は空ではない', function()
      board:put(2, 11, cnot_x_gate(5))
      board:put(5, 11, control_gate(2))

      assert.is_true(board:is_empty(1, 11))
      assert.is_false(board:is_empty(2, 11))
      assert.is_false(board:is_empty(3, 11))
      assert.is_false(board:is_empty(4, 11))
      assert.is_false(board:is_empty(5, 11))
      assert.is_true(board:is_empty(6, 11))
    end)
  end)
end)
