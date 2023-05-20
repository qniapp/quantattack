require("engine/test/bustedhelper")
require("engine/render/color")
require("test/test_helper")
require("lib/effects")
require("lib/board")

describe('連鎖 (chain)', function()
  local board

  before_each(function()
    board = board_class()
  end)

  it("ブロックがマッチすると、マッチしたブロックとその上にあるブロックすべてに chain_id が付く"
  , function()
    -- T <-
    -- X <-
    -- H
    -- H
    board:put(1, 4, block_class("t"))
    board:put(1, 3, block_class("x"))
    board:put(1, 2, block_class("h"))
    board:put(1, 1, block_class("h"))

    board:update()

    assert.is_not_nil(board:block_at(1, 4).chain_id)
    assert.is_not_nil(board:block_at(1, 3).chain_id)
    assert.is_not_nil(board:block_at(1, 2).chain_id)
    assert.is_not_nil(board:block_at(1, 1).chain_id)
  end)

  it("chain_id が付いたブロックは、着地すると chain_id が消える", function()
    -- T
    -- X
    -- H ---> T
    -- H      X
    board:put(1, 4, block_class("t"))
    board:put(1, 3, block_class("x"))
    board:put(1, 2, block_class("h"))
    board:put(1, 1, block_class("h"))

    repeat
      board:update()
    until board:block_at(1, 1).type == "x" and board:block_at(1, 1).state == "idle"

    board:update()

    assert.is_nil(board:block_at(1, 2).chain_id)
    assert.is_nil(board:block_at(1, 1).chain_id)
  end)

  it("ブロックがマッチすると、board._chain_count が 1 になる", function()
    -- H
    -- H
    board:put(1, 2, block_class("h"))
    board:put(1, 1, block_class("h"))

    board:update()

    assert.are_equal(1, board._chain_count["1,2"])
  end)

  it("2 連鎖", function()
    -- X
    -- H
    -- H --> X
    -- X     X
    board:put(1, 4, block_class("x"))
    board:put(1, 3, block_class("h"))
    board:put(1, 2, block_class("h"))
    board:put(1, 1, block_class("x"))

    for i = 0, 200 do
      board:update()
    end

    assert.are_equal(2, board._chain_count["1,3"])
  end)

  it("2 連鎖 (ほかのブロックに変化したものとさらにマッチ)", function()
    -- S
    -- T --> S
    -- T     S
    board:put(1, 3, block_class("s"))
    board:put(1, 2, block_class("t"))
    board:put(1, 1, block_class("t"))

    for i = 0, 200 do
      board:update()
    end

    assert.are_equal(2, board._chain_count["1,2"])
  end)

  it("3 連鎖 (ほかのブロックに変化したものとさらにマッチ)", function()
    -- Z
    -- S     Z
    -- T --> S --> Z
    -- T     S     Z
    board:put(1, 4, block_class("z"))
    board:put(1, 3, block_class("s"))
    board:put(1, 2, block_class("t"))
    board:put(1, 1, block_class("t"))

    for i = 0, 152 do
      board:update()
    end

    assert.are_equal(3, board._chain_count["1,2"])
  end)

  -- G G G      X Y Z
  -- H     --->       --->
  -- H Y          Y        X   Z
  it("おじゃまブロック 2 連鎖", function()
    board:put(1, 3, garbage_block(3))
    board:put(1, 2, block_class("h"))
    board:put(1, 1, block_class("h"))
    board:put(2, 1, block_class("y"))

    -- HH とおじゃまブロックがマッチ
    board:update()

    -- おじゃまブロックの一番左が分解
    for i = 1, block_class.block_match_animation_frame_count do
      board:update()
    end
    assert.is_true(board:block_at(1, 3).state == "freeze")

    -- おじゃまブロックの真ん中が分解
    for i = 1, block_class.block_match_delay_per_block do
      board:update()
    end
    assert.is_true(board:block_at(2, 3).state == "freeze")

    -- おじゃまブロックの一番右が分解
    for i = 1, block_class.block_match_delay_per_block do
      board:update()
    end
    assert.is_true(board:block_at(3, 3).state == "freeze")

    -- 分解してできたブロックすべてのフリーズ解除
    for i = 1, block_class.block_match_delay_per_block do
      board:update()
    end
    board:update()

    assert.is_false(board:block_at(1, 3).state == "freeze")
    assert.is_false(board:block_at(2, 3).state == "freeze")
    assert.is_false(board:block_at(3, 3).state == "freeze")

    assert.are_equal("1,2", board:block_at(1, 3).chain_id)
    assert.are_equal("1,2", board:block_at(2, 3).chain_id)
    assert.are_equal("1,2", board:block_at(3, 3).chain_id)

    -- 下の Y とマッチするように
    -- おじゃまブロック真ん中が分解してできたブロックを Y にする
    board:block_at(2, 3).type = "y"

    -- 1 マス落下
    for i = 1, 12 do
      board:update()
    end

    -- 落下完了
    board:update()
    board:update()

    -- YY がマッチ
    board:update()
    assert.is_true(board:block_at(2, 2).state == "match")
    assert.is_true(board:block_at(2, 1).state == "match")

    -- 全部で 2 連鎖
    assert.are_equal(2, board._chain_count["1,2"])
  end)

  it("chaina_id を持つブロックが接地すると chain_id が消える", function()
    -- X
    -- H  -->
    -- H      X
    board:put(1, 4, block_class("x"))
    board:put(1, 3, block_class("h"))
    board:put(1, 2, block_class("h"))
    board:put(1, 1, block_class("t"))

    for i = 1, 84 do
      board:update()
    end

    assert.is_nil(board:block_at(1, 1).chain_id)
  end)
end)
