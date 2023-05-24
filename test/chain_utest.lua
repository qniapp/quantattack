require("engine/test/bustedhelper")
require("engine/render/color")
require("lib/effects")
require("test/test_helper")
require("lib/board")

describe('連鎖 (chain)', function()
  local board

  local put = function(x, y, block_or_block_type, other_x)
    if type(block_or_block_type) == "string" then
      board:put(x, y, block_class(block_or_block_type))
    elseif type(block_or_block_type) == "table" then
      board:put(x, y, block_or_block_type)
    else
      assert(false, "invalid block")
    end
    board:block_at(x, y).other_x = other_x
  end

  local block_at = function(x, y)
    return board:block_at(x, y)
  end

  local chain_id_at = function(x, y)
    return board:block_at(x, y).chain_id
  end

  before_each(function()
    board = board_class()
  end)

  it("マッチしたブロックとその上にあるブロックすべてに chain_id が付く", function()
    --  ┌───┐
    --  │ T │
    --  ├───┤
    --  │ X │
    --  ├───┤
    --  │ H │
    --  ├───┤
    --  │ H │
    -- ─┴───┴─
    put(1, 4, 't')
    put(1, 3, 'x')
    put(1, 2, 'h')
    put(1, 1, 'h')

    board:update()

    assert.are.equal("1,2", chain_id_at(1, 4))
    assert.are.equal("1,2", chain_id_at(1, 3))
    assert.are.equal("1,2", chain_id_at(1, 2))
    assert.are.equal("1,2", chain_id_at(1, 1))
  end)

  it("chain_id が付いたブロックは、着地すると chain_id が消える", function()
    --  ┌───┐
    --  │ T │
    --  ├───┤
    --  │ X │
    --  ├───┤
    --  │ H │
    --  ├───┤
    --  │ H │
    -- ─┴───┴─
    put(1, 4, 't')
    put(1, 3, 'x')
    put(1, 2, 'h')
    put(1, 1, 'h')

    repeat
      board:update()
    until block_at(1, 1).type == "x" and block_at(1, 1).state == "idle"

    --  ┌───┐
    --  │ T │
    --  ├───┤
    --  │ X │
    --  └───┘

    board:update() -- 着地

    --  ┌───┐
    --  │ T │
    --  ├───┤
    --  │ X │
    -- ─┴───┴─

    assert.is_nil(chain_id_at(1, 1))
    assert.is_nil(chain_id_at(1, 2))
  end)

  it("ブロックがマッチすると、board._chain_count が 1 になる", function()
    --  ┌───┐
    --  │ H │
    --  ├───┤
    --  │ H │
    -- ─┴───┴─
    put(1, 2, 'h')
    put(1, 1, 'h')

    board:update()

    assert.are.equal(1, board._chain_count["1,2"])
  end)

  it("2 連鎖", function()
    --  ┌───┐
    --  │ X │
    --  ├───┤
    --  │ H │
    --  ├───┤
    --  │ H │
    --  ├───┤
    --  │ X │
    -- ─┴───┴─

    put(1, 4, 'x')
    put(1, 3, 'h')
    put(1, 2, 'h')
    put(1, 1, 'x')

    -- HH がマッチ
    board:update()
    assert.are.equal("match", block_at(1, 2).state)
    assert.are.equal("match", block_at(1, 3).state)

    repeat
      board:update()
    until block_at(1, 2).type == 'i'

    repeat
      board:update()
    until block_at(1, 1).state == "match"

    assert.are.equal(2, board._chain_count["1,3"])
  end)

  it("2 連鎖 (ほかのブロックに変化したものとさらにマッチ)", function()
    --  ┌───┐
    --  │ S │
    --  ├───┤
    --  │ T │
    --  ├───┤
    --  │ T │
    -- ─┴───┴─
    put(1, 3, 's')
    put(1, 2, 't')
    put(1, 1, 't')

    repeat
      board:update()
    until block_at(1, 1).type == "z"

    --  ┌───┐
    --  │ Z │
    -- ─┴───┴─

    assert.are.equal(2, board._chain_count["1,2"])
  end)

  it("3 連鎖 (ほかのブロックに変化したものとさらにマッチ)", function()
    --  ┌───┐
    --  │ Z │
    --  ├───┤
    --  │ S │
    --  ├───┤
    --  │ T │
    --  ├───┤
    --  │ T │
    -- ─┴───┴─
    put(1, 4, 'z')
    put(1, 3, 's')
    put(1, 2, 't')
    put(1, 1, 't')

    repeat
      board:update()
    until block_at(1, 1).type == 'i'

    assert.are.equal(3, board._chain_count["1,2"])
  end)

  -- G G G      Y Y Y
  --   H   --->       --->
  --   H Y          Y        Y Y

  -- ┌───────────┐
  -- │           │
  -- └───┬───┬───┘
  --     │ H │
  --     ├───┼───┐
  --     │ H │ Y │
  --     └───┴───┘
  it("おじゃまブロック 2 連鎖", function()
    put(1, 3, garbage_block(3))
    put(2, 2, 'h')
    put(2, 1, 'h')
    put(3, 1, 'y')

    -- HH とおじゃまブロックがマッチ
    board:update()

    -- おじゃまブロックすべてが分解しフリーズ解除
    for i = 1, block_class.block_match_animation_frame_count + block_class.block_match_delay_per_block * 3 + 1 do
      board:update()
    end

    assert.are.equal("2,2", block_at(1, 3).chain_id)
    assert.are.equal("2,2", block_at(2, 3).chain_id)
    assert.are.equal("2,2", block_at(3, 3).chain_id)

    -- 下の Y とマッチするように
    -- おじゃまブロックが分解してできたブロックをすべて Y にする
    block_at(1, 3).type = "y"
    block_at(2, 3).type = "y"
    block_at(3, 3).type = "y"

    -- ┌───┬───┬───┐
    -- │ Y │ Y │ Y │
    -- └───┴───┴───┘
    --
    --         ┌───┐
    --         │ Y │
    --         └───┘

    -- 3 列目の YY がマッチするまで進める
    repeat
      board:update()
    until block_at(3, 1).state == "match"

    --         ┌───┐
    --         │ Y*│
    -- ┌───┬───┼───┤
    -- │ Y │ Y │ Y*│
    -- └───┴───┴───┘

    -- 全部で 2 連鎖
    assert.are.equal(2, board._chain_count["2,2"])

    assert.are.equal('y', block_at(1, 1).type)
    assert.are.equal('y', block_at(2, 1).type)
    assert.are.equal('y', block_at(3, 1).type)
    assert.are.equal('y', block_at(3, 2).type)
    assert.are.equal('match', block_at(3, 1).state)
    assert.are.equal('match', block_at(3, 2).state)
  end)

  -- ┌───────────────┐
  -- │               │
  -- │               │
  -- │               │
  -- └───┬───┬───────┘
  --     │ H │
  --     ├───┼───┐   ┌───┐
  --     │ H │ Y │   │ X │
  --     └───┴───┘   └───┘
  it("おじゃまブロック 3 連鎖", function()
    put(1, 3, garbage_block(4, 2))
    put(2, 2, 'h')
    put(2, 1, 'h')
    put(3, 1, 'y')
    put(5, 1, 'x')

    -- HH とおじゃまブロックがマッチ
    board:update()

    -- おじゃまブロックすべてが分解しフリーズ解除
    for i = 1, block_class.block_match_animation_frame_count + block_class.block_match_delay_per_block * 8 + 1 do
      board:update()
    end

    -- おじゃまブロックの下段すべてに chain_id がセット
    assert.are.equal("2,2", block_at(1, 3).chain_id)
    assert.are.equal("2,2", block_at(2, 3).chain_id)
    assert.are.equal("2,2", block_at(3, 3).chain_id)
    assert.are.equal("2,2", block_at(4, 3).chain_id)

    -- 下の Y とマッチするように
    -- おじゃまブロック下段が分解してできたブロックをすべて Y にする
    block_at(1, 3).type = "y"
    block_at(2, 3).type = "y"
    block_at(3, 3).type = "y"
    block_at(4, 3).type = "y"

    -- ┌───────────────┐
    -- │               │
    -- ├───┬───┬───┬───┤
    -- │ Y │ Y │ Y │ Y │
    -- └───┴───┴───┴───┘
    --
    --         ┌───┐   ┌───┐
    --         │ Y │   │ X │
    --         └───┘   └───┘

    -- YY がマッチするまで進める
    repeat
      board:update()
    until block_at(3, 1).state == "match"

    -- ┌───────────────┐
    -- │               │
    -- ├───┬───┬───┬───┤
    -- │ Y*│ Y*│ Y*│ Y*│
    -- └───┴───┼───┼───┼───┐
    --         │ Y*│   │ X │
    --         └───┘   └───┘
    --
    -- ┌───────────────┐
    -- │               │
    -- └───────┬───┬───┘
    --         │ Y*│
    -- ┌───┬───┼───┼───┬───┐
    -- │ Y │ Y │ Y*│ Y │ X │
    -- └───┴───┴───┴───┴───┘

    assert.is_true(block_at(3, 2).state == "match")
    assert.is_true(block_at(3, 1).state == "match")

    -- ここで 2 連鎖
    assert.are.equal(2, board._chain_count["2,2"])

    -- おじゃまブロック上段すべてが分解しフリーズ解除
    for i = 1, block_class.block_match_animation_frame_count + block_class.block_match_delay_per_block * 4 + 1 do
      board:update()
    end

    -- 下の X とマッチするように
    -- おじゃまブロック下段が分解してできたブロックをすべて X にする
    block_at(1, 3).type = "x"
    block_at(2, 3).type = "x"
    block_at(3, 3).type = "x"
    block_at(4, 3).type = "x"

    -- ┌───┬───┬───┬───┐
    -- │ X │ X │ X │ X │
    -- └───┴───┴───┴───┘
    --
    -- ┌───┬───┐   ┌───┬───┐
    -- │ Y │ Y │   │ Y │ X │
    -- └───┴───┘   └───┴───┘

    assert.are.equal("2,2", block_at(1, 3).chain_id)
    assert.are.equal("2,2", block_at(2, 3).chain_id)
    assert.are.equal("2,2", block_at(3, 3).chain_id)
    assert.are.equal("2,2", block_at(4, 3).chain_id)

    board:swap(4, 1)

    repeat
      board:update()
    until block_at(4, 1).type == 'x' and block_at(4, 1).state == "match"

    -- ┌───┬───┐   ┌───┐
    -- │ X │ X │   │ X*│
    -- ├───┼───┼───┼───┼───┐
    -- │ Y │ Y │ X │ X*│ Y │
    -- └───┴───┴───┴───┴───┘

    -- ここで 3 連鎖
    assert.are.equal(3, board._chain_count["2,2"])

    -- 一行目のブロック
    assert.are.equal('y', block_at(1, 1).type)
    assert.are.equal('y', block_at(2, 1).type)
    assert.are.equal('x', block_at(3, 1).type)
    assert.are.equal('x', block_at(4, 1).type)
    assert.are.equal('y', block_at(5, 1).type)

    -- 二行目のブロック
    assert.are.equal('x', block_at(1, 2).type)
    assert.are.equal('x', block_at(2, 2).type)
    assert.are.equal('x', block_at(4, 2).type)
  end)

  -- g g g g g g
  -- g g g g g g
  --   X       Y
  -- # X # # # #
  it("おじゃまブロックに chain_id を付ける", function()
    put(1, 3, garbage_block(6, 2))
    put(2, 2, 'x')
    put(6, 2, 'y')
    put(1, 1, '#')
    put(2, 1, 'x')
    put(3, 1, '#')
    put(4, 1, '#')
    put(5, 1, '#')
    put(6, 1, '#')

    -- XX とおじゃまブロックがマッチ
    board:update()

    -- おじゃまブロックすべてが分解しフリーズ解除
    for i = 1, block_class.block_match_animation_frame_count + block_class.block_match_delay_per_block * 8 + 1 do
      board:update()
    end

    -- おじゃまブロックの下段すべてに chain_id がセット
    assert.are.equal("2,2", block_at(1, 3).chain_id)
    assert.are.equal("2,2", block_at(2, 3).chain_id)
    assert.are.equal("2,2", block_at(3, 3).chain_id)
    assert.are.equal("2,2", block_at(4, 3).chain_id)
    assert.are.equal("2,2", block_at(5, 3).chain_id)
    assert.are.equal("2,2", block_at(6, 3).chain_id)

    -- 下の Y とマッチするように
    -- おじゃまブロック下段が分解してできたブロックの種類を適切にセット
    block_at(1, 3).type = "z"
    block_at(2, 3).type = "z"
    block_at(3, 3).type = "z"
    block_at(4, 3).type = "y"
    block_at(5, 3).type = "z"
    block_at(6, 3).type = "z"

    board:swap(5, 2)

    -- swap が完了するまで進める
    repeat
      board:update()
    until block_at(5, 2).state ~= "swap"

    board:swap(4, 2)

    -- swap が完了するまで進める
    repeat
      board:update()
    until block_at(4, 2).state ~= "swap"

    -- YY がマッチするまで進める
    repeat
      board:update()
    until block_at(4, 2).state == "match"

    -- ここで 2 連鎖
    assert.are.equal(2, board._chain_count["2,2"])

    -- おじゃまブロックの下段が落ちるまで待つ
    repeat
      board:update()
    until block_at(1, 2).type == "z"

    -- おじゃまブロックの上段が分解しフリーズ状態になるまで待つ
    repeat
      board:update()
    until block_at(6, 4).state == "freeze"

    -- おじゃまブロック上段が分解してできたブロックの種類を適切にセット
    block_at(1, 4).type = "x"
    block_at(2, 4).type = "x"
    block_at(3, 4).type = "x"
    block_at(4, 4).type = "x"
    block_at(5, 4).type = "x"
    block_at(6, 4).type = "x"

    -- おじゃまブロックの上段が落ちるまで待つ
    repeat
      board:update()
    until block_at(2, 2).type == 'x' and block_at(2, 2).state == "idle"
    board:update()

    -- 落ちてきたおじゃまブロックの上段の chain_id が nil になる
    assert.is_nil(block_at(1, 3).chain_id)
    assert.is_nil(block_at(2, 2).chain_id)
    assert.is_nil(block_at(3, 3).chain_id)
    assert.is_nil(block_at(4, 2).chain_id)
    assert.is_nil(block_at(5, 3).chain_id)
    assert.is_nil(block_at(6, 3).chain_id)
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

    assert.is_nil(block_at(1, 1).chain_id)
  end)
end)
