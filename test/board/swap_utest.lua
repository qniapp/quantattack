require("engine/test/bustedhelper")
require("test/test_helper")
require("lib/effects")
require("lib/board")

describe('board', function()
  local board

  before_each(function()
    board = board_class()
  end)

  describe('swap', function()
    describe('単一ブロック同士の入れ換え', function()
      before_each(function()
        board:put(1, 1, block_class("h"))
        board:put(2, 1, block_class("x"))
      end)

      it('swap は true を返す', function()
        assert.is_true(board:swap(1, 1))
      end)

      it('ブロックの状態を swapping にする', function()
        board:swap(1, 1)

        assert.is_true(board:block_at(1, 1).state == "swap")
      end)

      --  TODO: フレーム数のテストは別のテストに分離
      it("3 フレームで swapping 状態が完了する", function()
        board:swap(1, 1)

        -- フレーム 1: swap 開始
        board:update()
        assert.is_true(board:block_at(1, 1).state == "swap")
        assert.is_true(board:block_at(2, 1).state == "swap")

        -- フレーム 2
        board:update()
        assert.is_true(board:block_at(1, 1).state == "swap")
        assert.is_true(board:block_at(2, 1).state == "swap")

        -- フレーム 3: swap 終了
        board:update()
        assert.is_true(board:block_at(1, 1).state == "swap")
        assert.is_true(board:block_at(2, 1).state == "swap")

        -- フレーム 4: idle 状態に遷移
        board:update()
        assert.is_true(board:block_at(1, 1).state == "idle")
        assert.is_true(board:block_at(2, 1).state == "idle")
      end)

      it("ブロックを入れ換える", function()
        board:swap(1, 1)
        board:update() -- swapping (3 フレーム)
        board:update()
        board:update()
        board:update() -- idle 状態に遷移

        assert.are.equal("x", board:block_at(1, 1).type)
        assert.are.equal("h", board:block_at(2, 1).type)
      end)
    end)

    describe('単一ブロックと I ブロックの入れ換え', function()
      before_each(function()
        board:put(1, 1, block_class("h"))
      end)

      it("ブロックを入れ換える", function()
        board:swap(1, 1)
        board:update() -- swapping (3 フレーム)
        board:update()
        board:update()
        board:update() -- idle 状態に遷移

        assert.are.equal("i", board:block_at(1, 1).type)
        assert.are.equal("h", board:block_at(2, 1).type)
      end)
    end)

    describe('I ブロック同士の入れ換え', function()
      it("swap は true を返す", function()
        assert.is_true(board:swap(1, 1))
      end)
    end)

    describe("プレースホルダブロック (#) の入れ換え", function()
      before_each(function()
        board:put(2, 1, block_class("#"))
      end)

      it("swap は false を返す", function()
        assert.is_false(board:swap(1, 1)) -- 右に # がある場合
        assert.is_false(board:swap(2, 1)) -- 左に # がある場合
      end)
    end)

    describe("おじゃまゲートの入れ換え", function()
      before_each(function()
        board:put(2, 1, garbage_block(3))
      end)

      it("swap は false を返す", function()
        assert.is_false(board:swap(1, 1)) -- 右におじゃまゲートがある場合
        assert.is_false(board:swap(4, 1)) -- 左におじゃまゲートがある場合
      end)
    end)

    describe("hover 状態のブロックとの入れ替え", function()
      local left_block, right_block

      before_each(function()
        left_block = block_class("h")
        right_block = block_class("x")

        board:put(1, 1, left_block)
        board:put(2, 1, right_block)
      end)

      it("左のブロックが hover 状態の場合、swap は false を返す", function()
        left_block:hover()

        assert.is_false(board:swap(1, 1))
      end)

      it("右のブロックが hover 状態の場合、swap は false を返す", function()
        right_block:hover()

        assert.is_false(board:swap(1, 1))
      end)
    end)

    describe("swapping 状態のブロックとの入れ替え", function()
      before_each(function()
        board:put(2, 1, block_class("h"))
      end)

      it("左のブロックが swapping 状態の場合、swap は false を返す", function()
        board:swap(1, 1)

        assert.is_false(board:swap(2, 1))
      end)

      it("右のブロックが swapping 状態の場合、swap は false を返す", function()
        board:swap(2, 1)

        assert.is_false(board:swap(1, 1))
      end)
    end)

    describe("fall 状態のブロックとの入れ替え", function()
      local h_gate

      before_each(function()
        h_gate = block_class("h")
        board:put(2, 16, h_gate)
        h_gate:fall()
      end)

      it("左のブロックが fall 状態の場合、swap は true を返す", function()
        assert.is_true(board:swap(2, 16))
      end)

      it("右のブロックが fall 状態の場合、swap は true を返す", function()
        assert.is_true(board:swap(1, 16))
      end)
    end)

    describe("match 状態のブロックとの入れ替え", function()
      local h_gate

      before_each(function()
        h_gate = block_class("h")
        board:put(2, 1, h_gate)
        h_gate.state = "match"
      end)

      it("左のブロックが match 状態の場合、swap は false を返す", function()
        assert.is_false(board:swap(2, 1))
      end)

      it("右のブロックが match 状態の場合、swap は false を返す", function()
        assert.is_false(board:swap(1, 1))
      end)
    end)

    describe("freeze 状態のブロックとの入れ替え", function()
      local h_gate

      before_each(function()
        h_gate = block_class("h")
        board:put(2, 16, h_gate)
        h_gate.state = "freeze"
      end)

      it("左のブロックが freeze 状態の場合、swap は false を返す", function()
        assert.is_false(board:swap(2, 16))
      end)

      it("右のブロックが freeze 状態の場合、swap は false を返す", function()
        assert.is_false(board:swap(1, 16))
      end)
    end)

    describe("CNOT の一部と単一ブロックの入れ替え", function()
      before_each(function()
        board:put(1, 1, block_class("h"))
        board:put(2, 1, control_block(3))
        board:put(3, 1, cnot_x_block(2))
        board:put(4, 1, block_class("h"))
      end)

      it("左が CNOT の一部、右が単一ブロックの場合、swap は false を返す", function()
        assert.is_false(board:swap(3, 1))
      end)

      it("左が単一ブロック、右が CNOT の一部の場合、swap は false を返す", function()
        assert.is_false(board:swap(1, 1))
      end)
    end)

    describe("SWAP の一部と単一ブロックの入れ替え", function()
      before_each(function()
        board:put(1, 1, block_class("h"))
        board:put(2, 1, swap_block(3))
        board:put(3, 1, swap_block(2))
        board:put(4, 1, block_class("h"))
      end)

      it("左が SWAP の一部、右が単一ブロックの場合、swap は false を返す", function()
        assert.is_false(board:swap(3, 1))
      end)

      it("左が単一ブロック、右が SWAP の一部の場合、swap は false を返す", function()
        assert.is_false(board:swap(1, 1))
      end)
    end)
  end)
end)
