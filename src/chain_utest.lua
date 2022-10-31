require("engine/test/bustedhelper")

local board_class = require("board")

describe('連鎖 (chain) #solo', function()
  local board

  before_each(function()
    board = board_class()
  end)

  it("パネルがマッチすると、マッチしたゲートとその上にあるゲートすべてにフラグが付く", function()
    -- Y <- フラグが付く
    -- X <- フラグが付く
    -- H
    -- H
    board:put(1, 9, y_gate())
    board:put(1, 10, x_gate())
    board:put(1, 11, h_gate())
    board:put(1, 12, h_gate())

    board:update()

    assert.is_true(board:gate_at(1, 9).chainable)
    assert.is_true(board:gate_at(1, 10).chainable)
    assert.is_true(board:gate_at(1, 11).chainable)
    assert.is_true(board:gate_at(1, 12).chainable)
  end)

  it("フラグが付いたゲートは、着地するとフラグが消える", function()
    -- Y
    -- X
    -- H ---> Y
    -- H      X
    board:put(1, 9, y_gate())
    board:put(1, 10, x_gate())
    board:put(1, 11, h_gate())
    board:put(1, 12, h_gate())
    board:put(1, 13, t_gate())

    for i = 0, 82 do
      board:update()
    end

    assert.is_false(board:gate_at(1, 11).chainable)
    assert.is_false(board:gate_at(1, 12).chainable)
  end)

  it("パネルがマッチすると、board.chain_count が 1 になる", function()
    -- H
    -- H
    board:put(1, 11, h_gate())
    board:put(1, 12, h_gate())

    board:update()

    assert.are_equal(1, board.chain_count)
  end)

  it("2 連鎖", function()
    -- X
    -- H
    -- H --> X
    -- X     X
    board:put(1, 9, x_gate())
    board:put(1, 10, h_gate())
    board:put(1, 11, h_gate())
    board:put(1, 12, x_gate())

    for i = 0, 82 do
      board:update()
    end

    assert.are_equal(2, board.chain_count)
  end)

  it("2 連鎖 (ほかのゲートに変化したものとさらにマッチ)", function()
    -- S
    -- T --> S
    -- T     S
    board:put(1, 10, s_gate())
    board:put(1, 11, t_gate())
    board:put(1, 12, t_gate())

    for i = 0, 82 do
      board:update()
    end

    assert.are_equal(2, board.chain_count)
  end)

  it("3 連鎖 (ほかのゲートに変化したものとさらにマッチ)", function()
    -- Z
    -- S     Z
    -- T --> S --> Z
    -- T     S     Z
    board:put(1, 9, z_gate())
    board:put(1, 10, s_gate())
    board:put(1, 11, t_gate())
    board:put(1, 12, t_gate())

    for i = 0, 152 do
      board:update()
    end

    assert.are_equal(3, board.chain_count)
  end)

  it("chainable フラグの立ったゲートが接地するとフラグが消える", function()
    -- X
    -- H  -->
    -- H      X
    board:put(1, 10, x_gate())
    board:put(1, 11, h_gate())
    board:put(1, 12, h_gate())
    board:put(1, 13, t_gate())

    for i = 1, 83 do
      board:update()
    end

    assert.is_false(board:gate_at(1, 12).chainable)
  end)
end)
