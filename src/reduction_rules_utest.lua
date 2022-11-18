require("engine/test/bustedhelper")

require("board")
require("gate")
require("h_gate")

-- https://github.com/lunarmodules/say
local say = require("say")

local function is_i(_state, arguments)
  if not type(arguments[1]) == "table" or #arguments ~= 1 then
    return false
  end

  return arguments[1].type == "i"
end

say:set("assertion.is_i.positive", "Expected %s \nto be an I gate")
say:set("assertion.is_i.negative", "Expected %s \n not to be an I gate")
assert:register("assertion", "is_i", is_i, "assertion.is_i.positive", "assertion.is_i.negative")

local function is_x(_state, arguments)
  if not type(arguments[1]) == "table" or #arguments ~= 1 then
    return false
  end

  return arguments[1].type == "x"
end

say:set("assertion.is_x.positive", "Expected %s \nto be an X gate")
say:set("assertion.is_x.negative", "Expected %s \n not to be an X gate")
assert:register("assertion", "is_x", is_x, "assertion.is_x.positive", "assertion.is_x.negative")

local function is_y(_state, arguments)
  if not type(arguments[1]) == "table" or #arguments ~= 1 then
    return false
  end

  return arguments[1].type == "y"
end

say:set("assertion.is_y.positive", "Expected %s \nto be a Y gate")
say:set("assertion.is_y.negative", "Expected %s \n not to be a Y gate")
assert:register("assertion", "is_y", is_y, "assertion.is_y.positive", "assertion.is_y.negative")

local function is_z(_state, arguments)
  if not type(arguments[1]) == "table" or #arguments ~= 1 then
    return false
  end

  return arguments[1].type == "z"
end

say:set("assertion.is_z.positive", "Expected %s \nto be a Z gate")
say:set("assertion.is_z.negative", "Expected %s \n not to be a Z gate")
assert:register("assertion", "is_z", is_z, "assertion.is_z.positive", "assertion.is_z.negative")

local function is_s(_state, arguments)
  if not type(arguments[1]) == "table" or #arguments ~= 1 then
    return false
  end

  return arguments[1].type == "s"
end

say:set("assertion.is_s.positive", "Expected %s \nto be an S gate")
say:set("assertion.is_s.negative", "Expected %s \n not to be an S gate")
assert:register("assertion", "is_s", is_s, "assertion.is_s.positive", "assertion.is_s.negative")

local function is_swap(_state, arguments)
  if not type(arguments[1]) == "table" or #arguments ~= 1 then
    return false
  end

  return arguments[1].type == "swap"
end

say:set("assertion.is_swap.positive", "Expected %s \nto be a SWAP gate")
say:set("assertion.is_swap.negative", "Expected %s \n not to be a SWAP gate")
assert:register("assertion", "is_swap", is_swap, "assertion.is_swap.positive", "assertion.is_swap.negative")

describe('ゲートの簡約ルール #solo', function()
  local board

  before_each(function()
    board = create_board()
  end)

  it('should reduce HH', function()
    board:put(1, 11, h_gate())
    board:put(1, 12, h_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 11).new_gate)
    assert.is_i(board:gate_at(1, 12).new_gate)
  end)

  it('should reduce XX', function()
    board:put(1, 11, x_gate())
    board:put(1, 12, x_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 11).new_gate)
    assert.is_i(board:gate_at(1, 12).new_gate)
  end)

  it('should reduce YY', function()
    board:put(1, 11, y_gate())
    board:put(1, 12, y_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 11).new_gate)
    assert.is_i(board:gate_at(1, 12).new_gate)
  end)

  it('should reduce ZZ', function()
    board:put(1, 11, z_gate())
    board:put(1, 12, z_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 11).new_gate)
    assert.is_i(board:gate_at(1, 12).new_gate)
  end)

  it('should reduce SS', function()
    board:put(1, 11, s_gate())
    board:put(1, 12, s_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 11).new_gate)
    assert.is_z(board:gate_at(1, 12).new_gate)
  end)

  it('should reduce TT', function()
    board:put(1, 11, t_gate())
    board:put(1, 12, t_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 11).new_gate)
    assert.is_s(board:gate_at(1, 12).new_gate)
  end)

  it('should reduce XZ', function()
    board:put(1, 11, x_gate())
    board:put(1, 12, z_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 11).new_gate)
    assert.is_y(board:gate_at(1, 12).new_gate)
  end)

  it('should reduce ZX', function()
    board:put(1, 11, z_gate())
    board:put(1, 12, x_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 11).new_gate)
    assert.is_y(board:gate_at(1, 12).new_gate)
  end)

  it('should reduce HXH', function()
    board:put(1, 10, h_gate())
    board:put(1, 11, x_gate())
    board:put(1, 12, h_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 10).new_gate)
    assert.is_i(board:gate_at(1, 11).new_gate)
    assert.is_z(board:gate_at(1, 12).new_gate)
  end)

  it('should reduce HZH', function()
    board:put(1, 10, h_gate())
    board:put(1, 11, z_gate())
    board:put(1, 12, h_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 10).new_gate)
    assert.is_i(board:gate_at(1, 11).new_gate)
    assert.is_x(board:gate_at(1, 12).new_gate)
  end)

  it('should reduce SZS', function()
    board:put(1, 10, s_gate())
    board:put(1, 11, z_gate())
    board:put(1, 12, s_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 10).new_gate)
    assert.is_i(board:gate_at(1, 11).new_gate)
    assert.is_z(board:gate_at(1, 12).new_gate)
  end)

  it('should reduce TST', function()
    board:put(1, 10, t_gate())
    board:put(1, 11, s_gate())
    board:put(1, 12, t_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 10).new_gate)
    assert.is_i(board:gate_at(1, 11).new_gate)
    assert.is_z(board:gate_at(1, 12).new_gate)
  end)

  it('should reduce TZST', function()
    board:put(1, 9, t_gate())
    board:put(1, 10, z_gate())
    board:put(1, 11, s_gate())
    board:put(1, 12, t_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 9).new_gate)
    assert.is_i(board:gate_at(1, 10).new_gate)
    assert.is_i(board:gate_at(1, 11).new_gate)
    assert.is_i(board:gate_at(1, 12).new_gate)
  end)

  it('should reduce TSZT', function()
    board:put(1, 9, t_gate())
    board:put(1, 10, s_gate())
    board:put(1, 11, z_gate())
    board:put(1, 12, t_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 9).new_gate)
    assert.is_i(board:gate_at(1, 10).new_gate)
    assert.is_i(board:gate_at(1, 11).new_gate)
    assert.is_i(board:gate_at(1, 12).new_gate)
  end)

  it('should reduce C-X x2', function()
    board:put(1, 11, control_gate(3))
    board:put(3, 11, cnot_x_gate(1))
    board:put(1, 12, control_gate(3))
    board:put(3, 12, cnot_x_gate(1))

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 11).new_gate)
    assert.is_i(board:gate_at(3, 11).new_gate)
    assert.is_i(board:gate_at(1, 12).new_gate)
    assert.is_i(board:gate_at(3, 12).new_gate)
  end)

  it('should reduce X-C x2', function()
    board:put(1, 11, cnot_x_gate(3))
    board:put(3, 11, control_gate(1))
    board:put(1, 12, cnot_x_gate(3))
    board:put(3, 12, control_gate(1))

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 11).new_gate)
    assert.is_i(board:gate_at(3, 11).new_gate)
    assert.is_i(board:gate_at(1, 12).new_gate)
    assert.is_i(board:gate_at(3, 12).new_gate)
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

    assert.is_i(board:gate_at(1, 10).new_gate)
    assert.is_i(board:gate_at(3, 10).new_gate)
    assert.is_i(board:gate_at(1, 11).new_gate)
    assert.is_i(board:gate_at(3, 11).new_gate)
    assert.is_swap(board:gate_at(1, 12).new_gate)
    assert.are_equal(3, board:gate_at(1, 12).new_gate.other_x)
    assert.is_swap(board:gate_at(3, 12).new_gate)
    assert.are_equal(1, board:gate_at(3, 12).new_gate.other_x)
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

    assert.is_i(board:gate_at(1, 10).new_gate)
    assert.is_i(board:gate_at(3, 10).new_gate)
    assert.is_i(board:gate_at(1, 11).new_gate)
    assert.is_i(board:gate_at(3, 11).new_gate)
    assert.is_swap(board:gate_at(1, 12).new_gate)
    assert.are_equal(3, board:gate_at(1, 12).new_gate.other_x)
    assert.is_swap(board:gate_at(3, 12).new_gate)
    assert.are_equal(1, board:gate_at(3, 12).new_gate.other_x)
  end)

  it('should reduce HH C-X HH', function()
    board:put(1, 10, h_gate())
    board:put(3, 10, h_gate())
    board:put(1, 11, control_gate(3))
    board:put(3, 11, cnot_x_gate(1))
    board:put(1, 12, h_gate())
    board:put(3, 12, h_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 10).new_gate)
    assert.is_i(board:gate_at(3, 10).new_gate)
    assert.are_equal("cnot_x", board:gate_at(1, 11).new_gate.type)
    assert.are_equal(3, board:gate_at(1, 11).new_gate.other_x)
    assert.are_equal("control", board:gate_at(3, 11).new_gate.type)
    assert.are_equal(1, board:gate_at(3, 11).new_gate.other_x)
    assert.is_i(board:gate_at(1, 12).new_gate)
    assert.is_i(board:gate_at(3, 12).new_gate)
  end)

  it('should reduce HH X-C HH', function()
    board:put(1, 10, h_gate())
    board:put(3, 10, h_gate())
    board:put(1, 11, cnot_x_gate(3))
    board:put(3, 11, control_gate(1))
    board:put(1, 12, h_gate())
    board:put(3, 12, h_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 10).new_gate)
    assert.is_i(board:gate_at(3, 10).new_gate)
    assert.are_equal("control", board:gate_at(1, 11).new_gate.type)
    assert.are_equal(3, board:gate_at(1, 11).new_gate.other_x)
    assert.are_equal("cnot_x", board:gate_at(3, 11).new_gate.type)
    assert.are_equal(1, board:gate_at(3, 11).new_gate.other_x)
    assert.is_i(board:gate_at(1, 12).new_gate)
    assert.is_i(board:gate_at(3, 12).new_gate)
  end)

  it('should reduce XX C-X X', function()
    board:put(1, 10, x_gate())
    board:put(3, 10, x_gate())
    board:put(1, 11, control_gate(3))
    board:put(3, 11, cnot_x_gate(1))
    board:put(1, 12, x_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 10).new_gate)
    assert.is_i(board:gate_at(3, 10).new_gate)
    assert.are_equal("control", board:gate_at(1, 11).type)
    assert.are_equal("cnot_x", board:gate_at(3, 11).type)
    assert.is_i(board:gate_at(1, 12).new_gate)
  end)

  it('should reduce XX X-C X', function()
    board:put(1, 10, x_gate())
    board:put(3, 10, x_gate())
    board:put(1, 11, cnot_x_gate(3))
    board:put(3, 11, control_gate(1))
    board:put(3, 12, x_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 10).new_gate)
    assert.is_i(board:gate_at(3, 10).new_gate)
    assert.are_equal("cnot_x", board:gate_at(1, 11).type)
    assert.are_equal("control", board:gate_at(3, 11).type)
    assert.is_i(board:gate_at(3, 12).new_gate)
  end)

  it('should reduce ZZ C-X Z', function()
    board:put(1, 10, z_gate())
    board:put(3, 10, z_gate())
    board:put(1, 11, control_gate(3))
    board:put(3, 11, cnot_x_gate(1))
    board:put(3, 12, z_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 10).new_gate)
    assert.is_i(board:gate_at(3, 10).new_gate)
    assert.are_equal("control", board:gate_at(1, 11).type)
    assert.are_equal("cnot_x", board:gate_at(3, 11).type)
    assert.is_i(board:gate_at(3, 12).new_gate)
  end)

  it('should reduce ZZ X-C Z', function()
    board:put(1, 10, z_gate())
    board:put(3, 10, z_gate())
    board:put(1, 11, cnot_x_gate(3))
    board:put(3, 11, control_gate(1))
    board:put(1, 12, z_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 10).new_gate)
    assert.is_i(board:gate_at(3, 10).new_gate)
    assert.are_equal("cnot_x", board:gate_at(1, 11).type)
    assert.are_equal("control", board:gate_at(3, 11).type)
    assert.is_i(board:gate_at(1, 12).new_gate)
  end)

  it('should reduce X C-X X', function()
    board:put(3, 10, x_gate())
    board:put(1, 11, control_gate(3))
    board:put(3, 11, cnot_x_gate(1))
    board:put(3, 12, x_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(3, 10).new_gate)
    assert.are_equal("control", board:gate_at(1, 11).type)
    assert.are_equal("cnot_x", board:gate_at(3, 11).type)
    assert.is_i(board:gate_at(3, 12).new_gate)
  end)

  it('should reduce X X-C X', function()
    board:put(1, 10, x_gate())
    board:put(1, 11, cnot_x_gate(3))
    board:put(3, 11, control_gate(1))
    board:put(1, 12, x_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 10).new_gate)
    assert.are_equal("cnot_x", board:gate_at(1, 11).type)
    assert.are_equal("control", board:gate_at(3, 11).type)
    assert.is_i(board:gate_at(1, 12).new_gate)
  end)

  it('should reduce Z C-X Z', function()
    board:put(1, 10, z_gate())
    board:put(1, 11, control_gate(3))
    board:put(3, 11, cnot_x_gate(1))
    board:put(1, 12, z_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 10).new_gate)
    assert.are_equal("control", board:gate_at(1, 11).type)
    assert.are_equal("cnot_x", board:gate_at(3, 11).type)
    assert.is_i(board:gate_at(1, 12).new_gate)
  end)

  it('should reduce Z X-C Z', function()
    board:put(3, 10, z_gate())
    board:put(1, 11, cnot_x_gate(3))
    board:put(3, 11, control_gate(1))
    board:put(3, 12, z_gate())

    board:reduce_gates()

    assert.is_i(board:gate_at(3, 10).new_gate)
    assert.are_equal("cnot_x", board:gate_at(1, 11).type)
    assert.are_equal("control", board:gate_at(3, 11).type)
    assert.is_i(board:gate_at(3, 12).new_gate)
  end)

  it('should reduce S-S x2', function()
    board:put(1, 11, swap_gate(3))
    board:put(3, 11, swap_gate(1))
    board:put(1, 12, swap_gate(3))
    board:put(3, 12, swap_gate(1))

    board:reduce_gates()

    assert.is_i(board:gate_at(1, 11).new_gate)
    assert.is_i(board:gate_at(3, 11).new_gate)
    assert.is_i(board:gate_at(1, 12).new_gate)
    assert.is_i(board:gate_at(3, 12).new_gate)
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

    assert.is_i(board:gate_at(1, 10).new_gate)
    assert.is_swap(board:gate_at(1, 11))
    assert.is_swap(board:gate_at(3, 11))
    assert.is_i(board:gate_at(3, 12).new_gate)
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

    assert.is_i(board:gate_at(3, 10).new_gate)
    assert.is_swap(board:gate_at(1, 11))
    assert.is_swap(board:gate_at(3, 11))
    assert.is_i(board:gate_at(1, 12).new_gate)
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

    assert.is_i(board:gate_at(1, 10).new_gate)
    assert.is_swap(board:gate_at(1, 11))
    assert.is_swap(board:gate_at(3, 11))
    assert.is_i(board:gate_at(3, 12).new_gate)
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

    assert.is_i(board:gate_at(3, 10).new_gate)
    assert.is_swap(board:gate_at(1, 11))
    assert.is_swap(board:gate_at(3, 11))
    assert.is_i(board:gate_at(1, 12).new_gate)
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

    assert.is_i(board:gate_at(1, 10).new_gate)
    assert.is_swap(board:gate_at(1, 11))
    assert.is_swap(board:gate_at(3, 11))
    assert.is_i(board:gate_at(3, 12).new_gate)
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

    assert.is_i(board:gate_at(2, 10).new_gate)
    assert.is_swap(board:gate_at(2, 11))
    assert.is_swap(board:gate_at(4, 11))
    assert.is_i(board:gate_at(4, 12).new_gate)
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

    assert.is_z(board:gate_at(1, 10).new_gate)
    assert.is_swap(board:gate_at(1, 11))
    assert.is_swap(board:gate_at(3, 11))
    assert.is_i(board:gate_at(3, 12).new_gate)
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

    assert.is_s(board:gate_at(1, 10).new_gate)
    assert.is_swap(board:gate_at(1, 11))
    assert.is_swap(board:gate_at(3, 11))
    assert.is_i(board:gate_at(3, 12).new_gate)
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

    assert.is_y(board:gate_at(1, 10).new_gate)
    assert.is_swap(board:gate_at(1, 11))
    assert.is_swap(board:gate_at(3, 11))
    assert.is_i(board:gate_at(3, 12).new_gate)
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

    assert.is_i(board:gate_at(1, 9).new_gate)
    assert.is_z(board:gate_at(1, 10).new_gate)
    assert.is_swap(board:gate_at(1, 11))
    assert.is_swap(board:gate_at(3, 11))
    assert.is_i(board:gate_at(3, 12).new_gate)
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

    assert.is_z(board:gate_at(1, 9).new_gate)
    assert.is_swap(board:gate_at(1, 10))
    assert.is_swap(board:gate_at(3, 10))
    assert.is_i(board:gate_at(3, 11).new_gate)
    assert.is_i(board:gate_at(3, 12).new_gate)
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

    assert.is_i(board:gate_at(1, 9).new_gate)
    assert.is_x(board:gate_at(1, 10).new_gate)
    assert.is_swap(board:gate_at(1, 11))
    assert.is_swap(board:gate_at(3, 11))
    assert.is_i(board:gate_at(3, 12).new_gate)
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

    assert.is_x(board:gate_at(1, 9).new_gate)
    assert.is_swap(board:gate_at(1, 10))
    assert.is_swap(board:gate_at(3, 10))
    assert.is_i(board:gate_at(3, 11).new_gate)
    assert.is_i(board:gate_at(3, 12).new_gate)
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

    assert.is_i(board:gate_at(1, 9).new_gate)
    assert.is_z(board:gate_at(1, 10).new_gate)
    assert.is_swap(board:gate_at(1, 11))
    assert.is_swap(board:gate_at(3, 11))
    assert.is_i(board:gate_at(3, 12).new_gate)
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

    assert.is_z(board:gate_at(1, 9).new_gate)
    assert.is_swap(board:gate_at(1, 10))
    assert.is_swap(board:gate_at(3, 10))
    assert.is_i(board:gate_at(3, 11).new_gate)
    assert.is_i(board:gate_at(3, 12).new_gate)
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

    assert.is_i(board:gate_at(1, 9).new_gate)
    assert.is_z(board:gate_at(1, 10).new_gate)
    assert.is_swap(board:gate_at(1, 11))
    assert.is_swap(board:gate_at(3, 11))
    assert.is_i(board:gate_at(3, 12).new_gate)
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

    assert.is_z(board:gate_at(1, 9).new_gate)
    assert.is_swap(board:gate_at(1, 10))
    assert.is_swap(board:gate_at(3, 10))
    assert.is_i(board:gate_at(3, 11).new_gate)
    assert.is_i(board:gate_at(3, 12).new_gate)
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

    assert.is_i(board:gate_at(1, 8).new_gate)
    assert.is_swap(board:gate_at(1, 9))
    assert.is_swap(board:gate_at(3, 9))
    assert.is_i(board:gate_at(3, 10).new_gate)
    assert.is_i(board:gate_at(3, 11).new_gate)
    assert.is_i(board:gate_at(3, 12).new_gate)
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

    assert.is_i(board:gate_at(1, 8).new_gate)
    assert.is_swap(board:gate_at(1, 9))
    assert.is_swap(board:gate_at(3, 9))
    assert.is_i(board:gate_at(3, 10).new_gate)
    assert.is_i(board:gate_at(3, 11).new_gate)
    assert.is_i(board:gate_at(3, 12).new_gate)
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

    assert.is_i(board:gate_at(1, 9).new_gate)
    assert.are_equal("h", board:gate_at(1, 10).type)
    assert.is_i(board:gate_at(3, 10).new_gate)
    assert.are_equal("cnot_x", board:gate_at(1, 11).type)
    assert.are_equal("control", board:gate_at(3, 11).type)
    assert.are_equal("h", board:gate_at(1, 12).type)
    assert.is_i(board:gate_at(3, 12).new_gate)
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

    assert.is_i(board:gate_at(1, 8).new_gate)
    assert.are_equal("h", board:gate_at(1, 9).type)
    assert.is_i(board:gate_at(3, 9).new_gate)
    assert.are_equal("cnot_x", board:gate_at(1, 10).type)
    assert.are_equal("control", board:gate_at(3, 10).type)
    assert.are_equal("h", board:gate_at(1, 11).type)
    assert.is_i(board:gate_at(1, 12).new_gate)
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
    assert.is_i(board:gate_at(3, 10).new_gate)
    assert.are_equal("cnot_x", board:gate_at(1, 11).type)
    assert.are_equal("control", board:gate_at(3, 11).type)
    assert.are_equal("h", board:gate_at(1, 12).type)
    assert.is_i(board:gate_at(3, 12).new_gate)
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

    assert.is_i(board:gate_at(1, 8).new_gate)
    assert.are_equal("h", board:gate_at(1, 9).type)
    assert.are_equal("cnot_x", board:gate_at(1, 10).type)
    assert.are_equal("control", board:gate_at(3, 10).type)
    assert.are_equal("h", board:gate_at(1, 11).type)
    assert.is_i(board:gate_at(1, 12).new_gate)
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

    assert.is_i(board:gate_at(1, 10).new_gate)
    assert.is_i(board:gate_at(3, 10).new_gate)
    assert.is_swap(board:gate_at(1, 11))
    assert.is_swap(board:gate_at(3, 11))
    assert.is_i(board:gate_at(1, 12).new_gate)
    assert.is_i(board:gate_at(3, 12).new_gate)
  end)
end)
