require("engine/test/bustedhelper")
require("board")
require("gate")

describe('gate', function()
  local board

  before_each(function()
    board = create_board()
  end)

  describe('ゲートが 1 つだけ落ちる', function()
    local gate

    before_each(function()
      gate = h_gate()
    end)

    it("状態が falling になる", function()
      board:put(1, 11, gate)

      board:update()

      assert.is_true(gate:is_falling())
    end)

    it("4 フレームで 1 ゲートほど落下する", function()
      board:put(1, 11, gate)

      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(gate:is_falling())
      assert.are_equal(gate, board:gate_at(1, 12))
    end)

    it("着地後 1 フレームで状態が idle になる", function()
      board:put(1, 11, gate)

      board:update()
      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(gate:is_idle())
    end)
  end)

  describe('ゲートが 2 つ積み重なったまま落ちる', function()
    local gate1, gate2

    before_each(function()
      gate1 = h_gate()
      gate2 = x_gate()
    end)

    it("状態が falling になる", function()
      board:put(1, 10, gate1)
      board:put(1, 11, gate2)

      board:update()

      assert.is_true(gate1:is_falling())
      assert.is_true(gate2:is_falling())
    end)

    it("4 フレームで 1 ゲートほど落下する", function()
      board:put(1, 10, gate1)
      board:put(1, 11, gate2)

      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(gate1:is_falling())
      assert.is_true(gate2:is_falling())
      assert.are_equal(gate1, board:gate_at(1, 11))
      assert.are_equal(gate2, board:gate_at(1, 12))
    end)

    it("着地後 1 フレームで状態が idle になる", function()
      board:put(1, 10, gate1)
      board:put(1, 11, gate2)

      board:update()
      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(gate1:is_idle())
      assert.is_true(gate2:is_idle())
    end)
  end)

  describe('CNOT が落ちる', function()
    local control, cnot_x

    -- C-X
    before_each(function()
      control = control_gate(2)
      cnot_x = cnot_x_gate(1)
    end)

    it("状態が falling になる", function()
      board:put(1, 11, control)
      board:put(2, 11, cnot_x)

      board:update()

      assert.is_true(control:is_falling())
      assert.is_true(cnot_x:is_falling())
    end)

    it("4 フレームで 1 ゲートほど落下する", function()
      board:put(1, 11, control)
      board:put(2, 11, cnot_x)

      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(control:is_falling())
      assert.is_true(cnot_x:is_falling())
      assert.are_equal(control, board:gate_at(1, 12))
      assert.are_equal(cnot_x, board:gate_at(2, 12))
    end)

    it("着地後 1 フレームで状態が idle になる", function()
      board:put(1, 11, control)
      board:put(2, 11, cnot_x)

      board:update()
      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(control:is_idle())
      assert.is_true(cnot_x:is_idle())
    end)
  end)

  describe('SWAP ゲートが落ちる', function()
    local swap_left, swap_right

    before_each(function()
      swap_left = swap_gate(2)
      swap_right = swap_gate(1)
    end)

    it("状態が falling になる", function()
      board:put(1, 11, swap_left)
      board:put(2, 11, swap_right)

      board:update()

      assert.is_true(swap_left:is_falling())
      assert.is_true(swap_right:is_falling())
    end)

    it("4 フレームで 1 ゲートほど落下する", function()
      board:put(1, 11, swap_left)
      board:put(2, 11, swap_right)

      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(swap_left:is_falling())
      assert.is_true(swap_right:is_falling())
      assert.are_equal(swap_left, board:gate_at(1, 12))
      assert.are_equal(swap_right, board:gate_at(2, 12))
    end)

    it("着地後 1 フレームで状態が idle になる", function()
      board:put(1, 11, swap_left)
      board:put(2, 11, swap_right)

      board:update()
      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(swap_left:is_idle())
      assert.is_true(swap_right:is_idle())
    end)
  end)

  describe('おじゃまゲートが落ちる', function()
    local garbage

    before_each(function()
      garbage = garbage_gate(2)
    end)

    it("状態が falling になる", function()
      board:put(1, 11, garbage)

      board:update()

      assert.is_true(garbage:is_falling())
    end)

    it("4 フレームで 1 ゲートほど落下する", function()
      board:put(1, 11, garbage)

      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(garbage:is_falling())
      assert.are_equal(garbage, board:gate_at(1, 12))
    end)

    it("着地後 1 フレームで状態が idle になる", function()
      board:put(1, 11, garbage)

      board:update()
      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(garbage:is_idle())
    end)
  end)
end)
