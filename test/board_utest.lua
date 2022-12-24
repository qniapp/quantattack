require("engine/test/bustedhelper")
require("test/test_helper")
require("lib/cursor")
require("lib/board")
require("lib/block")

describe('board', function()
  local board

  before_each(function()
    board = board_class(cursor_class())
  end)

  describe('swap', function()
    it('should swap blocks next to each other', function()
      board:put(1, 16, block_class("h"))
      board:put(2, 16, block_class("x"))

      local swapped = board:swap(1, 16)

      assert.is_true(swapped)
      assert.are_equal("h", board.blocks[1][16].type)
      assert.are_equal("x", board.blocks[2][16].type)
      assert.is_true(board.blocks[1][16]:is_swapping())
      assert.is_true(board.blocks[2][16]:is_swapping())
    end)

    it('should not swap blocks if the left block is in swap', function()
      board:put(2, 16, block_class("h"))
      board.blocks[2][16]:swap_with("left")
      board:put(3, 16, block_class("x"))

      local swapped = board:swap(2, 16)

      assert.is_false(swapped)
      assert.are_equal("x", board.blocks[3][16].type)
      assert.is_true(board.blocks[3][16]:is_idle())
    end)

    it('should not swap blocks if the right block is in swap', function()
      board:put(1, 16, block_class("h"))
      board:put(2, 16, block_class("x"))
      board.blocks[2][16]:swap_with("right")

      local swapped = board:swap(1, 16)

      assert.is_false(swapped)
      assert.are_equal("h", board.blocks[1][16].type)
      assert.is_true(board.blocks[1][16]:is_idle())
    end)

    -- S-I-S →(右 の S を I と入れ換え)→ S-S
    it('should update swap_block.other_x after a swap', function()
      board:put(1, 16, swap_block(3))
      board:put(3, 16, swap_block(1))

      board:swap(2, 16)
      board:update()
      board:update()
      board:update()
      board:update()
      board:update()

      assert.are_equal(2, board.blocks[1][16].other_x)
    end)

    it('SWAP 同士の入れ替え', function()
      board:put(1, 16, swap_block(2))
      board:put(2, 16, swap_block(1))

      board:swap(1, 16)
      board:update()
      board:update()
      board:update()
      board:update()
      board:update()

      assert.are_equal(2, board.blocks[1][16].other_x)
      assert.are_equal(1, board.blocks[2][16].other_x)
    end)

    it('おじゃまユニタリが左側にある場合、入れ替えできない', function()
      -- !!!x__
      board:put(1, 16, garbage_block(3))
      board:put(4, 16, block_class("x"))

      assert.is_false(board:swap(3, 16))
    end)

    it('おじゃまユニタリが右側にある場合、入れ替えできない', function()
      -- __x!!!
      board:put(3, 16, block_class("x"))
      board:put(4, 16, garbage_block(3))

      assert.is_false(board:swap(3, 16))
    end)
  end)

  describe('reduce', function()
    --
    -- reduce -> H
    --           -
    --           X (next blocks)
    it('should not reduce when y is the last and include_next_blocks = true', function()
      board:put(1, board.rows, block_class("h"))
      board:put(1, board.row_next_blocks, block_class("x"))

      local reduction = board:reduce(1, board.rows, true)

      assert.are.same({}, reduction.to)
    end)

    --
    -- reduce -> H
    --           -
    --           X (next blocks)
    it('should not reduce when y is the last and include_next_blocks = true', function()
      board:put(1, board.rows, block_class("h"))
      board:put(1, board.row_next_blocks, block_class("x"))

      local reduction = board:reduce(1, board.rows, true)

      assert.are.same({}, reduction.to)
    end)

    --           -
    -- reduce -> I (next blocks)
    it('should not reduce when y is the next blocks row and include_next_blocks = true', function()
      local reduction = board:reduce(1, board.row_next_blocks, true)

      assert.are.same({}, reduction.to)
    end)
  end)

  describe('おじゃまブロック', function()
    it('おじゃまブロックの左に隣接するブロックがマッチした時、おじゃまブロックが分解される'
      , function()
      local h = block_class("h")

      board:put(1, 16, h)
      board:put(2, 16, garbage_block(3))
      h._state = "match"

      board:reduce_blocks()

      assert.are_equal("?", board.blocks[2][16].type)
    end)

    it('おじゃまブロックの右に隣接するブロックがマッチした時、おじゃまブロックが破壊される'
      , function()
      local h = block_class("h")

      board:put(4, 16, h)
      board:put(1, 16, garbage_block(3))
      h._state = "match"

      board:reduce_blocks()

      assert.are_equal("?", board.blocks[1][16].type)
    end)

    it('おじゃまブロックの上に隣接するブロックがマッチした時、おじゃまブロックが破壊される'
      , function()
      local h = block_class("h")

      board:put(1, 15, h)
      board:put(1, 16, garbage_block(3))
      h._state = "match"

      board:reduce_blocks()

      assert.are_equal("?", board.blocks[1][16].type)
    end)

    it('おじゃまブロックの下に隣接するブロックがマッチした時、おじゃまブロックが破壊される'
      , function()
      local h = block_class("h")

      board:put(1, 15, garbage_block(3))
      board:put(1, 16, h)
      h._state = "match"

      board:reduce_blocks()

      assert.are_equal("?", board.blocks[1][15].type)
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
      board:put(1, 6, swap_block(3))
      board:put(3, 6, swap_block(1))
      board:put(2, 7, block_class("x"))
      board:put(2, 8, block_class("y"))
      board:put(2, 9, block_class("h"))
      board:put(2, 10, block_class("x"))
      board:put(2, 11, block_class("y"))
      board:put(2, 12, block_class("h"))
      board:put(2, 13, block_class("x"))
      board:put(2, 14, block_class("y"))
      board:put(2, 15, block_class("h"))
      board:put(2, 16, block_class("x"))
      board:put(2, 17, block_class("y"))
      board:put(1, 17, block_class("x"))

      board:swap(1, 17)

      for i = 1, 100 do
        board:update()
      end

      assert.are_equal("swap", board.blocks[1][8].type)
      assert.are_equal("swap", board.blocks[3][8].type)
    end)

    --
    -- S-S
    --  ?
    --  ?
    --  ? ←
    --  ? ← ここを消した時に S-S が正しく落ちる
    it('swap ペアの真ん中が消えた時に正しく落ちる (raised_dots > 0)', function()
      board.raised_dots = 3

      board:put(1, 6, swap_block(3))
      board:put(3, 6, swap_block(1))
      board:put(2, 7, block_class("x"))
      board:put(2, 8, block_class("y"))
      board:put(2, 9, block_class("h"))
      board:put(2, 10, block_class("x"))
      board:put(2, 11, block_class("y"))
      board:put(2, 12, block_class("h"))
      board:put(2, 13, block_class("x"))
      board:put(2, 14, block_class("y"))
      board:put(2, 15, block_class("h"))
      board:put(2, 16, block_class("x"))
      board:put(2, 17, block_class("y"))
      board:put(1, 17, block_class("x"))

      board:swap(1, 17)

      for i = 1, 100 do
        board:update()
      end

      assert.are_equal("swap", board.blocks[1][8].type)
      assert.are_equal("swap", board.blocks[3][8].type)
    end)

    it('CNOT 下のブロックを入れ替えて落としたときに消えない', function()
      board:put(5, 9, control_block(6))
      board:put(6, 9, cnot_x_block(5))
      board:put(6, 10, block_class("s"))
      board:put(6, 11, block_class("z"))
      board:put(6, 12, block_class("t"))
      board:put(6, 13, block_class("x"))
      board:put(6, 14, block_class("t"))
      board:put(6, 15, block_class("x"))
      board:put(6, 16, block_class("t"))
      board:put(6, 17, block_class("x"))

      board:swap(5, 10)

      for i = 0, 100 do
        board:update()
      end

      assert.are_equal("s", board.blocks[5][17].type)
    end)
  end)

  describe('render', function()
    it('should render without errors', function()
      assert.has_no.errors(function() board:render() end)
    end)
  end)

  describe('is_block_fallable', function()
    it('SWAP ブロックの下にブロックが無い場合 true を返す', function()
      board:put(1, 1, swap_block(2))
      board:put(2, 1, swap_block(1))

      assert.is_true(board:is_block_fallable(1, 1))
      assert.is_true(board:is_block_fallable(2, 1))
    end)

    -- S-S
    -- H
    it('SWAP ブロックが下に落とせない場合 false を返す (左端下にブロック)', function()
      board:put(1, 15, swap_block(3))
      board:put(3, 15, swap_block(1))
      board:put(1, 16, block_class("h"))

      assert.is_false(board:is_block_fallable(1, 15))
      assert.is_false(board:is_block_fallable(3, 15))
    end)

    -- S-S
    --  H
    it('SWAP ブロックが下に落とせない場合 false を返す (真ん中下にブロック)', function()
      board:put(1, 15, swap_block(3))
      board:put(3, 15, swap_block(1))
      board:put(2, 16, block_class("h"))

      assert.is_false(board:is_block_fallable(1, 15))
      assert.is_false(board:is_block_fallable(3, 15))
    end)

    -- S-S
    --   H
    it('SWAP ブロックが下に落とせない場合 false を返す (右端下にブロック)', function()
      board:put(1, 15, swap_block(3))
      board:put(3, 15, swap_block(1))
      board:put(3, 16, block_class("h"))

      assert.is_false(board:is_block_fallable(1, 15))
      assert.is_false(board:is_block_fallable(3, 15))
    end)

    -- S-S
    -- H (falling)
    it('SWAP ブロックの下にブロックがあるが落下中の場合 true を返す', function()
      local h = block_class("h")
      h._state = "falling"

      board:put(1, 15, swap_block(3))
      board:put(3, 15, swap_block(1))
      board:put(1, 16, h)

      assert.is_true(board:is_block_fallable(1, 15))
      assert.is_true(board:is_block_fallable(3, 15))
    end)
  end)

  describe('is_block_empty', function()
    it('おじゃまユニタリの領域は空ではない', function()
      board:put(2, 15, garbage_block(4))

      assert.is_true(board:is_block_empty(1, 15))
      assert.is_false(board:is_block_empty(2, 15))
      assert.is_false(board:is_block_empty(3, 15))
      assert.is_false(board:is_block_empty(4, 15))
      assert.is_false(board:is_block_empty(5, 15))
      assert.is_true(board:is_block_empty(6, 15))
    end)

    it('S--S の間は空ではない', function()
      board:put(2, 15, swap_block(5))
      board:put(5, 15, swap_block(2))

      assert.is_true(board:is_block_empty(1, 15))
      assert.is_false(board:is_block_empty(2, 15))
      assert.is_false(board:is_block_empty(3, 15))
      assert.is_false(board:is_block_empty(4, 15))
      assert.is_false(board:is_block_empty(5, 15))
      assert.is_true(board:is_block_empty(6, 15))
    end)

    it('C--X の間は空ではない', function()
      board:put(2, 15, control_block(5))
      board:put(5, 15, cnot_x_block(2))

      assert.is_true(board:is_block_empty(1, 15))
      assert.is_false(board:is_block_empty(2, 15))
      assert.is_false(board:is_block_empty(3, 15))
      assert.is_false(board:is_block_empty(4, 15))
      assert.is_false(board:is_block_empty(5, 15))
      assert.is_true(board:is_block_empty(6, 15))
    end)

    it('X--C の間は空ではない', function()
      board:put(2, 15, cnot_x_block(5))
      board:put(5, 15, control_block(2))

      assert.is_true(board:is_block_empty(1, 15))
      assert.is_false(board:is_block_empty(2, 15))
      assert.is_false(board:is_block_empty(3, 15))
      assert.is_false(board:is_block_empty(4, 15))
      assert.is_false(board:is_block_empty(5, 15))
      assert.is_true(board:is_block_empty(6, 15))
    end)
  end)
end)
