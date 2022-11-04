require("engine/test/bustedhelper")
require("board")
require("gate")

describe('ゲートの簡約ルール', function()
  local board

  before_each(function()
    board = create_board()
  end)

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

  -- これは消えてはダメ
  --
  --   C-X
  -- X-C X-C
  it('まちがった C-X x2 は消えない', function()
    board:put(2, 11, control_gate(3))
    board:put(3, 11, cnot_x_gate(2))

    board:put(1, 12, cnot_x_gate(2))
    board:put(2, 12, control_gate(1))
    board:put(3, 12, cnot_x_gate(4))
    board:put(4, 12, control_gate(3))

    local reduction = board:reduce(2, 11)

    assert.are_equal(0, #reduction.to)
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
end)
