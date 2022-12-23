require("engine/test/bustedhelper")
require("engine/render/color")
require("lib/test_helper")

local board_class = require("lib/board")
local block = require("lib/block")

describe('連鎖 (chain)', function()
  local board

  before_each(function()
    board = board_class()
  end)

  it("ブロックがマッチすると、マッチしたブロックとその上にあるブロックすべてに chain_id が付く"
    , function()
    -- Y <-
    -- X <-
    -- H
    -- H
    board:put(1, 14, block("y"))
    board:put(1, 15, block("x"))
    board:put(1, 16, block("h"))
    board:put(1, 17, block("h"))

    board:update()

    assert.is_not_nil(board.blocks[1][14].chain_id)
    assert.is_not_nil(board.blocks[1][15].chain_id)
    assert.is_not_nil(board.blocks[1][16].chain_id)
    assert.is_not_nil(board.blocks[1][17].chain_id)
  end)

  it("chain_id が付いたブロックは、着地すると chain_id が消える", function()
    -- Y
    -- X
    -- H ---> Y
    -- H      X
    board:put(1, 14, block("y"))
    board:put(1, 15, block("x"))
    board:put(1, 16, block("h"))
    board:put(1, 17, block("h"))

    repeat
      board:update()
    until board.blocks[1][17].type == "x" and board.blocks[1][17]:is_idle()

    board:update()

    assert.is_nil(board.blocks[1][16].chain_id)
    assert.is_nil(board.blocks[1][17].chain_id)
  end)

  it("ブロックがマッチすると、board._chain_count が 1 になる", function()
    -- H
    -- H
    board:put(1, 15, block("h"))
    board:put(1, 16, block("h"))

    board:update()

    assert.are_equal(1, board._chain_count["1,15"])
  end)

  it("2 連鎖", function()
    -- X
    -- H
    -- H --> X
    -- X     X
    board:put(1, 14, block("x"))
    board:put(1, 15, block("h"))
    board:put(1, 16, block("h"))
    board:put(1, 17, block("x"))

    for i = 0, 83 do
      board:update()
    end

    assert.are_equal(2, board._chain_count["1,15"])
  end)

  it("2 連鎖 (ほかのブロックに変化したものとさらにマッチ)", function()
    -- S
    -- T --> S
    -- T     S
    board:put(1, 15, s_block())
    board:put(1, 16, t_block())
    board:put(1, 17, t_block())

    for i = 0, 82 do
      board:update()
    end

    assert.are_equal(2, board._chain_count["1,16"])
  end)

  it("3 連鎖 (ほかのブロックに変化したものとさらにマッチ)", function()
    -- Z
    -- S     Z
    -- T --> S --> Z
    -- T     S     Z
    board:put(1, 14, block("z"))
    board:put(1, 15, s_block())
    board:put(1, 16, t_block())
    board:put(1, 17, t_block())

    for i = 0, 152 do
      board:update()
    end

    assert.are_equal(3, board._chain_count["1,16"])
  end)

  -- G G G      X Y Z
  -- H     --->       --->
  -- H Y          Y        X   Z
  it("おじゃまブロック 2 連鎖", function()
    board:put(1, 15, garbage_block(3))
    board:put(1, 16, block("h"))
    board:put(1, 17, block("h"))
    board:put(2, 17, block("y"))

    -- HH とおじゃまブロックがマッチ
    board:update()

    -- おじゃまブロックの一番左が分解
    for i = 1, block.block_match_animation_frame_count do
      board:update()
    end
    assert.is_true(board.blocks[1][15]:is_freeze())

    -- おじゃまブロックの真ん中が分解
    for i = 1, block.block_match_delay_per_block do
      board:update()
    end
    assert.is_true(board.blocks[2][15]:is_freeze())

    -- おじゃまブロックの一番右が分解
    for i = 1, block.block_match_delay_per_block do
      board:update()
    end
    assert.is_true(board.blocks[3][15]:is_freeze())

    -- 分解してできたブロックすべてのフリーズ解除
    for i = 1, block.block_match_delay_per_block do
      board:update()
    end
    board:update()

    assert.is_false(board.blocks[1][15]:is_freeze())
    assert.is_false(board.blocks[2][15]:is_freeze())
    assert.is_false(board.blocks[3][15]:is_freeze())

    assert.are_equal("1,16", board.blocks[1][15].chain_id)
    assert.are_equal("1,16", board.blocks[2][15].chain_id)
    assert.are_equal("1,16", board.blocks[3][15].chain_id)

    -- 下の Y とマッチするように
    -- おじゃまブロック真ん中が分解してできたブロックを Y にする
    board.blocks[2][15].type = "y"

    -- 1 マス落下
    for i = 1, 4 do
      board:update()
    end

    -- 落下完了
    board:update()

    -- YY がマッチ
    board:update()
    assert.is_true(board.blocks[2][16]:is_match())
    assert.is_true(board.blocks[2][17]:is_match())

    -- 全部で 2 連鎖
    assert.are_equal(2, board._chain_count["1,16"])
  end)

  it("chaina_id を持つブロックが接地すると chain_id が消える", function()
    -- X
    -- H  -->
    -- H      X
    board:put(1, 14, block("x"))
    board:put(1, 15, block("h"))
    board:put(1, 16, block("h"))
    board:put(1, 17, t_block())

    for i = 1, 84 do
      board:update()
    end

    assert.is_nil(board.blocks[1][17].chain_id)
  end)
end)
