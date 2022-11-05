require("engine/test/bustedhelper")
require("board")

describe('連鎖 (chain)', function()
  local board

  before_each(function()
    board = create_board()
  end)

  it("ゲートがマッチすると、マッチしたゲートとその上にあるゲートすべてに chain_id が付く"
    , function()
    -- Y <-
    -- X <-
    -- H
    -- H
    board:put(1, 9, y_gate())
    board:put(1, 10, x_gate())
    board:put(1, 11, h_gate())
    board:put(1, 12, h_gate())

    board:update()

    assert.is_not_nil(board:gate_at(1, 9).chain_id)
    assert.is_not_nil(board:gate_at(1, 10).chain_id)
    assert.is_not_nil(board:gate_at(1, 11).chain_id)
    assert.is_not_nil(board:gate_at(1, 12).chain_id)
  end)

  it("chain_id が付いたゲートは、着地すると chain_id が消える", function()
    -- Y
    -- X
    -- H ---> Y
    -- H      X
    board:put(1, 9, y_gate())
    board:put(1, 10, x_gate())
    board:put(1, 11, h_gate())
    board:put(1, 12, h_gate())
    board:put(1, 13, t_gate())

    for i = 0, 83 do
      board:update()
    end

    assert.is_nil(board:gate_at(1, 11).chain_id)
    assert.is_nil(board:gate_at(1, 12).chain_id)
  end)

  it("ゲートがマッチすると、board.chain_count が 1 になる", function()
    -- H
    -- H
    board:put(1, 11, h_gate())
    board:put(1, 12, h_gate())

    board:update()

    assert.are_equal(1, board.chain_count["1,11"])
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

    for i = 0, 83 do
      board:update()
    end

    assert.are_equal(2, board.chain_count["1,10"])
  end)

  it("2 連鎖 (ほかのゲートに変化したものとさらにマッチ)", function()
    -- S
    -- T --> S
    -- T     S
    board:put(1, 11, s_gate())
    board:put(1, 12, t_gate())
    board:put(1, 13, t_gate())

    for i = 0, 82 do
      board:update()
    end

    assert.are_equal(2, board.chain_count["1,12"])
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

    assert.are_equal(3, board.chain_count["1,11"])
  end)

  it("chaina_id を持つゲートが接地すると chain_id が消える", function()
    -- X
    -- H  -->
    -- H      X
    board:put(1, 10, x_gate())
    board:put(1, 11, h_gate())
    board:put(1, 12, h_gate())
    board:put(1, 13, t_gate())

    for i = 1, 84 do
      board:update()
    end

    assert.is_nil(board:gate_at(1, 12).chain_id)
  end)
end)
