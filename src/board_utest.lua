require("engine/test/bustedhelper")
require("engine/debug/dump")
require("board")
require("gate")

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
      board:gate_at(2, 12):swap_with_left()
      board:put(3, 12, x_gate())

      local swapped = board:swap(2, 12)

      assert.is_false(swapped)
      assert.are_equal("x", board:gate_at(3, 12).type)
      assert.is_true(board:gate_at(3, 12):is_idle())
    end)

    it('should not swap gates if the right gate is in swap', function()
      board:put(1, 12, h_gate())
      board:put(2, 12, x_gate())
      board:gate_at(2, 12):swap_with_right()

      local swapped = board:swap(1, 12)

      assert.is_false(swapped)
      assert.are_equal("h", board:gate_at(1, 12).type)
      assert.is_true(board:gate_at(1, 12):is_idle())
    end)

    -- S-I-S →(右 の S を I と入れ換え)→ S-S
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

  describe('おじゃまゲート', function()
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
  end)

  describe('update', function()
    --
    -- S-S
    --  ?
    --  ?
    --  ? ←
    --  ? ← ここを消した時に S-S が正しく落ちる
    it('swap ペアの真ん中が消えた時に正しく落ちる', function()
      board:put(1, 2, swap_gate(3))
      board:put(3, 2, swap_gate(1))
      board:put(2, 3, x_gate())
      board:put(2, 4, y_gate())
      board:put(2, 5, h_gate())
      board:put(2, 6, x_gate())
      board:put(2, 7, y_gate())
      board:put(2, 8, h_gate())
      board:put(2, 9, x_gate())
      board:put(2, 10, y_gate())
      board:put(2, 11, h_gate())
      board:put(2, 12, x_gate())
      board:put(2, 13, y_gate())
      board:put(1, 13, x_gate())

      board:swap(1, 13)

      for i = 1, 100 do
        board:update()
      end

      assert.are_equal("swap", board:gate_at(1, 4).type)
      assert.are_equal("swap", board:gate_at(3, 4).type)
    end)

    --
    -- S-S
    --  ?
    --  ?
    --  ? ←
    --  ? ← ここを消した時に S-S が正しく落ちる
    it('swap ペアの真ん中が消えた時に正しく落ちる (raised_dots > 0)', function()
      board.raised_dots = 3

      board:put(1, 2, swap_gate(3))
      board:put(3, 2, swap_gate(1))
      board:put(2, 3, x_gate())
      board:put(2, 4, y_gate())
      board:put(2, 5, h_gate())
      board:put(2, 6, x_gate())
      board:put(2, 7, y_gate())
      board:put(2, 8, h_gate())
      board:put(2, 9, x_gate())
      board:put(2, 10, y_gate())
      board:put(2, 11, h_gate())
      board:put(2, 12, x_gate())
      board:put(2, 13, y_gate())
      board:put(1, 13, x_gate())
      board:put(1, 14, y_gate())
      board:put(2, 14, h_gate())

      board:swap(1, 13)

      for i = 1, 100 do
        board:update()
      end

      assert.are_equal("swap", board:gate_at(1, 4).type)
      assert.are_equal("swap", board:gate_at(3, 4).type)
    end)

    it('CNOT 下のゲートを入れ替えて落としたときに消えない', function()
      board:put(5, 5, control_gate(6))
      board:put(6, 5, cnot_x_gate(5))
      board:put(6, 6, s_gate())
      board:put(6, 7, z_gate())
      board:put(6, 8, t_gate())
      board:put(6, 9, x_gate())
      board:put(6, 10, t_gate())
      board:put(6, 11, x_gate())
      board:put(6, 12, t_gate())
      board:put(6, 13, x_gate())

      board:swap(5, 6)

      for i = 0, 100 do
        board:update()
      end

      assert.are_equal("s", board:gate_at(5, 13).type)
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
