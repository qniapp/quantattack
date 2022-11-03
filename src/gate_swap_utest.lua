require("engine/test/bustedhelper")
require("board")
require("gate")

describe('ゲートの入れ替え', function()
  local board

  before_each(function()
    board = create_board()
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
