require("engine/test/bustedhelper")
require("test_helper")
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
    board:put(1, 14, y_gate())
    board:put(1, 15, x_gate())
    board:put(1, 16, h_gate())
    board:put(1, 17, h_gate())

    board:update()

    assert.is_not_nil(board:gate_at(1, 14).chain_id)
    assert.is_not_nil(board:gate_at(1, 15).chain_id)
    assert.is_not_nil(board:gate_at(1, 16).chain_id)
    assert.is_not_nil(board:gate_at(1, 17).chain_id)
  end)

  it("chain_id が付いたゲートは、着地すると chain_id が消える", function()
    -- Y
    -- X
    -- H ---> Y
    -- H      X
    board:put(1, 14, y_gate())
    board:put(1, 15, x_gate())
    board:put(1, 16, h_gate())
    board:put(1, 17, h_gate())

    repeat
      board:update()
    until board:gate_at(1, 17).type == "x" and board:gate_at(1, 17):is_idle()

    board:update()

    assert.is_nil(board:gate_at(1, 16).chain_id)
    assert.is_nil(board:gate_at(1, 17).chain_id)
  end)

  it("ゲートがマッチすると、board._chain_count が 1 になる", function()
    -- H
    -- H
    board:put(1, 15, h_gate())
    board:put(1, 16, h_gate())

    board:update()

    assert.are_equal(1, board._chain_count["1,15"])
  end)

  it("2 連鎖", function()
    -- X
    -- H
    -- H --> X
    -- X     X
    board:put(1, 14, x_gate())
    board:put(1, 15, h_gate())
    board:put(1, 16, h_gate())
    board:put(1, 17, x_gate())

    for i = 0, 83 do
      board:update()
    end

    assert.are_equal(2, board._chain_count["1,15"])
  end)

  it("2 連鎖 (ほかのゲートに変化したものとさらにマッチ)", function()
    -- S
    -- T --> S
    -- T     S
    board:put(1, 15, s_gate())
    board:put(1, 16, t_gate())
    board:put(1, 17, t_gate())

    for i = 0, 82 do
      board:update()
    end

    assert.are_equal(2, board._chain_count["1,16"])
  end)

  it("3 連鎖 (ほかのゲートに変化したものとさらにマッチ)", function()
    -- Z
    -- S     Z
    -- T --> S --> Z
    -- T     S     Z
    board:put(1, 14, z_gate())
    board:put(1, 15, s_gate())
    board:put(1, 16, t_gate())
    board:put(1, 17, t_gate())

    for i = 0, 152 do
      board:update()
    end

    assert.are_equal(3, board._chain_count["1,16"])
  end)

  -- G G G      X Y Z
  -- H     --->       --->
  -- H Y          Y        X   Z
  it("おじゃまゲート 2 連鎖", function()
    board:put(1, 15, garbage_gate(3, 1))
    board:put(1, 16, h_gate())
    board:put(1, 17, h_gate())
    board:put(2, 17, y_gate())

    -- HH とおじゃまゲートがマッチ
    board:update()

    -- おじゃまゲートの一番左が分解
    for i = 1, gate_match_animation_frame_count do
      board:update()
    end
    assert.is_true(board.gates[1][15]:is_freeze())

    -- おじゃまゲートの真ん中が分解
    for i = 1, gate_match_delay_per_gate do
      board:update()
    end
    assert.is_true(board.gates[2][15]:is_freeze())

    -- おじゃまゲートの一番右が分解
    for i = 1, gate_match_delay_per_gate do
      board:update()
    end
    assert.is_true(board.gates[3][15]:is_freeze())

    -- 分解してできたゲートすべてのフリーズ解除
    for i = 1, gate_match_delay_per_gate do
      board:update()
    end
    board:update()

    assert.is_false(board.gates[1][15]:is_freeze())
    assert.is_false(board.gates[2][15]:is_freeze())
    assert.is_false(board.gates[3][15]:is_freeze())

    assert.are_equal("1,16", board.gates[1][15].chain_id)
    assert.are_equal("1,16", board.gates[2][15].chain_id)
    assert.are_equal("1,16", board.gates[3][15].chain_id)

    -- 下の Y とマッチするように
    -- おじゃまゲート真ん中が分解してできたゲートを Y にする
    board.gates[2][15].type = "y"

    -- 1 マス落下
    for i = 1, 4 do
      board:update()
    end

    -- 落下完了
    board:update()

    -- YY がマッチ
    board:update()
    assert.is_true(board.gates[2][16]:is_match())
    assert.is_true(board.gates[2][17]:is_match())

    -- 全部で 2 連鎖
    assert.are_equal(2, board._chain_count["1,16"])
  end)

  it("chaina_id を持つゲートが接地すると chain_id が消える", function()
    -- X
    -- H  -->
    -- H      X
    board:put(1, 14, x_gate())
    board:put(1, 15, h_gate())
    board:put(1, 16, h_gate())
    board:put(1, 17, t_gate())

    for i = 1, 84 do
      board:update()
    end

    assert.is_nil(board:gate_at(1, 17).chain_id)
  end)
end)
