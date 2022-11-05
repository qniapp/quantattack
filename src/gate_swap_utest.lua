require("engine/test/bustedhelper")
require("board")
require("gate")

describe('ゲートの入れ替え', function()
  local board

  before_each(function()
    board = create_board()
  end)

  describe('フレーム数', function()
    it("入れ替えると状態が swapping になる", function()
      board:put(1, 12, h_gate())
      board:put(2, 12, x_gate())

      board:swap(1, 12)

      assert.is_true(board:gate_at(1, 12):is_swapping())
    end)

    it("4 フレームで入れ替わる", function()
      board:put(1, 13, h_gate())
      board:put(2, 13, x_gate())

      -- swap 開始フレーム
      board:swap(1, 13)
      board:update()
      assert.is_true(board:gate_at(1, 13):is_swapping())
      assert.is_true(board:gate_at(2, 13):is_swapping())

      board:update()
      assert.is_true(board:gate_at(1, 13):is_swapping())
      assert.is_true(board:gate_at(2, 13):is_swapping())

      board:update()
      assert.is_true(board:gate_at(1, 13):is_swapping())
      assert.is_true(board:gate_at(2, 13):is_swapping())

      board:update()
      assert.is_true(board:gate_at(1, 13):is_swapping())
      assert.is_true(board:gate_at(2, 13):is_swapping())

      board:update()

      assert.is_true(board:gate_at(1, 13):is_idle())
      assert.is_true(board:gate_at(2, 13):is_idle())
    end)
  end)

  describe('I ゲートとの入れ替え', function()
    --
    -- [H ] (H と I を入れ換え)
    it("入れ替え中の I ゲートは empty でない", function()
      board:put(1, 12, h_gate())

      board:swap(1, 12)

      assert.is_false(board:gate_at(2, 12):is_empty())
    end)
  end)
end)
