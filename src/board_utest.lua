require("engine/test/bustedhelper")
require("engine/debug/dump")
require("engine/render/color")
require("test_helper")
require("board")

describe('board', function()
  local board

  before_each(function()
    board = create_board()
  end)

  describe('swap', function()
    it('should swap gates next to each other', function()
      board:put(1, 16, h_gate())
      board:put(2, 16, x_gate())

      local swapped = board:swap(1, 16)

      assert.is_true(swapped)
      assert.are_equal("h", board.gates[1][16].type)
      assert.are_equal("x", board.gates[2][16].type)
      assert.is_true(board.gates[1][16]:is_swapping())
      assert.is_true(board.gates[2][16]:is_swapping())
    end)

    it('should not swap gates if the left gate is in swap', function()
      board:put(2, 16, h_gate())
      board.gates[2][16]:swap_with_left()
      board:put(3, 16, x_gate())

      local swapped = board:swap(2, 16)

      assert.is_false(swapped)
      assert.are_equal("x", board.gates[3][16].type)
      assert.is_true(board.gates[3][16]:is_idle())
    end)

    it('should not swap gates if the right gate is in swap', function()
      board:put(1, 16, h_gate())
      board:put(2, 16, x_gate())
      board.gates[2][16]:swap_with_right()

      local swapped = board:swap(1, 16)

      assert.is_false(swapped)
      assert.are_equal("h", board.gates[1][16].type)
      assert.is_true(board.gates[1][16]:is_idle())
    end)

    -- S-I-S →(右 の S を I と入れ換え)→ S-S
    it('should update swap_gate.other_x after a swap', function()
      board:put(1, 16, swap_gate(3))
      board:put(3, 16, swap_gate(1))

      board:swap(2, 16)
      board:update()
      board:update()
      board:update()
      board:update()
      board:update()

      assert.are_equal(2, board.gates[1][16].other_x)
    end)

    it('SWAP 同士の入れ替え', function()
      board:put(1, 16, swap_gate(2))
      board:put(2, 16, swap_gate(1))

      board:swap(1, 16)
      board:update()
      board:update()
      board:update()
      board:update()
      board:update()

      assert.are_equal(2, board.gates[1][16].other_x)
      assert.are_equal(1, board.gates[2][16].other_x)
    end)

    it('おじゃまユニタリが左側にある場合、入れ替えできない', function()
      -- !!!x__
      board:put(1, 16, garbage_gate(3))
      board:put(4, 16, x_gate())

      assert.is_false(board:swap(3, 16))
    end)

    it('おじゃまユニタリが右側にある場合、入れ替えできない', function()
      -- __x!!!
      board:put(3, 16, x_gate())
      board:put(4, 16, garbage_gate(3))

      assert.is_false(board:swap(3, 16))
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

  describe('おじゃまゲート', function()
    it('おじゃまゲートの左に隣接するゲートがマッチした時、おじゃまゲートが分解される'
      , function()
      local h = h_gate()

      board:put(1, 16, h)
      board:put(2, 16, garbage_gate(3))
      h._state = "match"

      board:reduce_gates()

      assert.are_equal('!', board.gates[2][16].type)
    end)

    it('おじゃまゲートの右に隣接するゲートがマッチした時、おじゃまゲートが破壊される'
      , function()
      local h = h_gate()

      board:put(4, 16, h)
      board:put(1, 16, garbage_gate(3))
      h._state = "match"

      board:reduce_gates()

      assert.are_equal('!', board.gates[1][16].type)
    end)

    it('おじゃまゲートの上に隣接するゲートがマッチした時、おじゃまゲートが破壊される'
      , function()
      local h = h_gate()

      board:put(1, 15, h)
      board:put(1, 16, garbage_gate(3))
      h._state = "match"

      board:reduce_gates()

      assert.are_equal('!', board.gates[1][16].type)
    end)

    it('おじゃまゲートの下に隣接するゲートがマッチした時、おじゃまゲートが破壊される'
      , function()
      local h = h_gate()

      board:put(1, 15, garbage_gate(3))
      board:put(1, 16, h)
      h._state = "match"

      board:reduce_gates()

      assert.are_equal('!', board.gates[1][15].type)
    end)
  end)

  describe('update', function()
    --
    -- S-S
    --  ?
    --  ?
    --  ? ←
    --  ? ← ここを消した時に S-S が正しく落ちる
    it('swap ペアの真ん中が消えた時に正しく落ちる', function()
      board:put(1, 6, swap_gate(3))
      board:put(3, 6, swap_gate(1))
      board:put(2, 7, x_gate())
      board:put(2, 8, y_gate())
      board:put(2, 9, h_gate())
      board:put(2, 10, x_gate())
      board:put(2, 11, y_gate())
      board:put(2, 12, h_gate())
      board:put(2, 13, x_gate())
      board:put(2, 14, y_gate())
      board:put(2, 15, h_gate())
      board:put(2, 16, x_gate())
      board:put(2, 17, y_gate())
      board:put(1, 17, x_gate())

      board:swap(1, 17)

      for i = 1, 100 do
        board:update()
      end

      assert.are_equal("swap", board.gates[1][8].type)
      assert.are_equal("swap", board.gates[3][8].type)
    end)

    --
    -- S-S
    --  ?
    --  ?
    --  ? ←
    --  ? ← ここを消した時に S-S が正しく落ちる
    it('swap ペアの真ん中が消えた時に正しく落ちる (raised_dots > 0)', function()
      board.raised_dots = 3

      board:put(1, 6, swap_gate(3))
      board:put(3, 6, swap_gate(1))
      board:put(2, 7, x_gate())
      board:put(2, 8, y_gate())
      board:put(2, 9, h_gate())
      board:put(2, 10, x_gate())
      board:put(2, 11, y_gate())
      board:put(2, 12, h_gate())
      board:put(2, 13, x_gate())
      board:put(2, 14, y_gate())
      board:put(2, 15, h_gate())
      board:put(2, 16, x_gate())
      board:put(2, 17, y_gate())
      board:put(1, 17, x_gate())

      board:swap(1, 17)

      for i = 1, 100 do
        board:update()
      end

      assert.are_equal("swap", board.gates[1][8].type)
      assert.are_equal("swap", board.gates[3][8].type)
    end)

    it('CNOT 下のゲートを入れ替えて落としたときに消えない', function()
      board:put(5, 9, control_gate(6))
      board:put(6, 9, cnot_x_gate(5))
      board:put(6, 10, s_gate())
      board:put(6, 11, z_gate())
      board:put(6, 12, t_gate())
      board:put(6, 13, x_gate())
      board:put(6, 14, t_gate())
      board:put(6, 15, x_gate())
      board:put(6, 16, t_gate())
      board:put(6, 17, x_gate())

      board:swap(5, 10)

      for i = 0, 100 do
        board:update()
      end

      assert.are_equal("s", board.gates[5][17].type)
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
      board:put(1, 15, swap_gate(3))
      board:put(3, 15, swap_gate(1))
      board:put(1, 16, h_gate())

      assert.is_false(board:is_gate_fallable(1, 15))
      assert.is_false(board:is_gate_fallable(3, 15))
    end)

    -- S-S
    --  H
    it('SWAP ゲートが下に落とせない場合 false を返す (真ん中下にゲート)', function()
      board:put(1, 15, swap_gate(3))
      board:put(3, 15, swap_gate(1))
      board:put(2, 16, h_gate())

      assert.is_false(board:is_gate_fallable(1, 15))
      assert.is_false(board:is_gate_fallable(3, 15))
    end)

    -- S-S
    --   H
    it('SWAP ゲートが下に落とせない場合 false を返す (右端下にゲート)', function()
      board:put(1, 15, swap_gate(3))
      board:put(3, 15, swap_gate(1))
      board:put(3, 16, h_gate())

      assert.is_false(board:is_gate_fallable(1, 15))
      assert.is_false(board:is_gate_fallable(3, 15))
    end)

    -- S-S
    -- H (falling)
    it('SWAP ゲートの下にゲートがあるが落下中の場合 true を返す', function()
      local h = h_gate()
      h._state = "falling"

      board:put(1, 15, swap_gate(3))
      board:put(3, 15, swap_gate(1))
      board:put(1, 16, h)

      assert.is_true(board:is_gate_fallable(1, 15))
      assert.is_true(board:is_gate_fallable(3, 15))
    end)
  end)

  describe('is_gate_empty', function()
    it('おじゃまユニタリの領域は空ではない', function()
      board:put(2, 15, garbage_gate(4))

      assert.is_true(board:is_gate_empty(1, 15))
      assert.is_false(board:is_gate_empty(2, 15))
      assert.is_false(board:is_gate_empty(3, 15))
      assert.is_false(board:is_gate_empty(4, 15))
      assert.is_false(board:is_gate_empty(5, 15))
      assert.is_true(board:is_gate_empty(6, 15))
    end)

    it('S--S の間は空ではない', function()
      board:put(2, 15, swap_gate(5))
      board:put(5, 15, swap_gate(2))

      assert.is_true(board:is_gate_empty(1, 15))
      assert.is_false(board:is_gate_empty(2, 15))
      assert.is_false(board:is_gate_empty(3, 15))
      assert.is_false(board:is_gate_empty(4, 15))
      assert.is_false(board:is_gate_empty(5, 15))
      assert.is_true(board:is_gate_empty(6, 15))
    end)

    it('C--X の間は空ではない', function()
      board:put(2, 15, control_gate(5))
      board:put(5, 15, cnot_x_gate(2))

      assert.is_true(board:is_gate_empty(1, 15))
      assert.is_false(board:is_gate_empty(2, 15))
      assert.is_false(board:is_gate_empty(3, 15))
      assert.is_false(board:is_gate_empty(4, 15))
      assert.is_false(board:is_gate_empty(5, 15))
      assert.is_true(board:is_gate_empty(6, 15))
    end)

    it('X--C の間は空ではない', function()
      board:put(2, 15, cnot_x_gate(5))
      board:put(5, 15, control_gate(2))

      assert.is_true(board:is_gate_empty(1, 15))
      assert.is_false(board:is_gate_empty(2, 15))
      assert.is_false(board:is_gate_empty(3, 15))
      assert.is_false(board:is_gate_empty(4, 15))
      assert.is_false(board:is_gate_empty(5, 15))
      assert.is_true(board:is_gate_empty(6, 15))
    end)
  end)
end)
