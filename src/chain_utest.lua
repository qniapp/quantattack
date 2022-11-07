require("engine/test/bustedhelper")
require("board")
require("gate")

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
    board:put(1, 10, y_gate())
    board:put(1, 11, x_gate())
    board:put(1, 12, h_gate())
    board:put(1, 13, h_gate())

    repeat
      board:update()
    until board:gate_at(1, 13).type == "x" and board:gate_at(1, 13):is_idle()
    board:update()

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
    board:put(1, 10, x_gate())
    board:put(1, 11, h_gate())
    board:put(1, 12, h_gate())
    board:put(1, 13, x_gate())

    for i = 0, 83 do
      board:update()
    end

    assert.are_equal(2, board.chain_count["1,11"])
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
    board:put(1, 10, z_gate())
    board:put(1, 11, s_gate())
    board:put(1, 12, t_gate())
    board:put(1, 13, t_gate())

    for i = 0, 152 do
      board:update()
    end

    assert.are_equal(3, board.chain_count["1,12"])
  end)

  -- G G G      X Y Z
  -- H     --->       --->
  -- H Y          Y        X   Z
  it("おじゃまゲート 2 連鎖", function()
    board:put(1, 11, garbage_gate(3, 1))
    board:put(1, 12, h_gate())
    board:put(1, 13, h_gate())
    board:put(2, 13, y_gate())

    -- HH とおじゃまゲートがマッチ
    board:update()

    -- おじゃまゲートの一番左が分解
    for i = 1, gate_match_animation_frame_count do
      board:update()
    end
    assert.is_true(board.gates[1][11]:is_freeze())

    -- おじゃまゲートの真ん中が分解
    for i = 1, gate_match_delay_per_gate do
      board:update()
    end
    assert.is_true(board.gates[2][11]:is_freeze())

    -- おじゃまゲートの一番右が分解
    for i = 1, gate_match_delay_per_gate do
      board:update()
    end
    assert.is_true(board.gates[3][11]:is_freeze())

    -- 分解してできたゲートすべてのフリーズ解除
    for i = 1, gate_match_delay_per_gate do
      board:update()
    end
    board:update()

    assert.is_false(board.gates[1][11]:is_freeze())
    assert.is_false(board.gates[2][11]:is_freeze())
    assert.is_false(board.gates[3][11]:is_freeze())

    assert.are_equal("1,12", board.gates[1][11].chain_id)
    assert.are_equal("1,12", board.gates[2][11].chain_id)
    assert.are_equal("1,12", board.gates[3][11].chain_id)

    -- 下の Y とマッチするように
    -- おじゃまゲート真ん中が分解してできたゲートを Y にする
    board.gates[2][11].type = "y"

    -- 1 マス落下
    for i = 1, 4 do
      board:update()
    end

    -- 落下完了
    board:update()

    -- YY がマッチ
    board:update()
    assert.is_true(board.gates[2][12]:is_match())
    assert.is_true(board.gates[2][13]:is_match())

    -- 全部で 2 連鎖
    assert.are_equal(2, board.chain_count["1,12"])
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
