require("engine/test/bustedhelper")
require("board")
require("gate")

describe('gate', function()
  local board
  local gate

  before_each(function()
    board = create_board()
    gate = h_gate()
  end)

  describe('fall', function()
    it("状態が falling になる", function()
      board:put(1, 11, gate)
      gate:fall()

      assert.is_true(gate:is_falling())
    end)

    it("4 フレームで 1 ゲートほど落下する", function()
      board:put(1, 11, gate)
      gate:fall()

      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(gate:is_falling())
      assert.are_equal(gate, board:gate_at(1, 12))
    end)

    it("着地後 1 フレームで状態が idle になる", function()
      board:put(1, 11, gate)
      gate:fall()

      board:update()
      board:update()
      board:update()
      board:update()
      board:update()

      assert.is_true(board:gate_at(1, 12):is_idle())
    end)
  end)
end)
