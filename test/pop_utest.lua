require("engine/test/bustedhelper")
require("engine/render/color")
require("lib/effects")
require("test/test_helper")
require("lib/board")

-- QA2 と同じ消え方: 45 フレーム光ったあと、下の段から 15 フレームごとに、上を押し上げてはじける
describe('マッチしたブロックが下からはじける', function()
  local board

  local put = function(x, y, block_type)
    board:put(x, y, block_class(block_type))
  end

  local block_at = function(x, y)
    return board:block_at(x, y)
  end

  local update = function(frames)
    for _ = 1, frames do
      board:update()
    end
  end

  -- ブロックが見えるか (はじけたブロックは描かない)
  local visible = function(x, y)
    local drawn = false
    local spr_orig = _G.spr
    _G.spr = function()
      drawn = true
    end
    block_at(x, y):render(0, 0)
    _G.spr = spr_orig
    return drawn
  end

  before_each(function()
    board = board_class()
  end)

  --  ┌───┐
  --  │ T │
  --  ├───┤
  --  │ H │
  --  ├───┤
  --  │ X │
  --  ├───┤
  --  │ H │
  -- ─┴───┴─
  it("下の段から 15 フレームごとにはじけ、最後の段のあとで結果がまとめて出る", function()
    put(1, 4, 't')
    put(1, 3, 'h')
    put(1, 2, 'x')
    put(1, 1, 'h')

    -- HXH がマッチ (結果は 1 段目が Z、ほかは空き)。このフレームを 1 フレーム目と数える
    board:update()

    -- 1 段目 (いちばん下) は 45 + 15 = 60 フレーム目にはじける
    update(58)
    assert.is_true(visible(1, 1))
    update(1)
    assert.is_false(visible(1, 1))
    assert.is_true(visible(1, 2))

    -- 2 段目はその 15 フレーム後
    update(15)
    assert.is_false(visible(1, 2))
    assert.is_true(visible(1, 3))

    -- はじけたマスは、最後の段がはじけるまで埋まったまま
    assert.are.equal('h', block_at(1, 1).type)
    assert.are.equal('match', block_at(1, 1).state)

    -- 3 段目がはじけた (90 フレーム目) 次のフレームに、すべてのマスが結果になる
    update(15)
    assert.is_false(visible(1, 3))
    assert.are.equal('match', block_at(1, 1).state)
    update(1)
    assert.are.equal('z', block_at(1, 1).type)
    assert.are.equal('i', block_at(1, 2).type)
    assert.are.equal('i', block_at(1, 3).type)
  end)

  it("はじけるたびに、まだはじけていないブロックとその上をゲートごとの高さまで押し上げる", function()
    put(1, 4, 't')
    put(1, 3, 'h')
    put(1, 2, 'x')
    put(1, 1, 'h')

    board:update()

    -- 1 段目の H の番: 45 フレーム目に H (0.5 マス = 4 ドット) の高さまで押し上げる
    update(43)
    assert.are.equal(0, block_at(1, 4).jump_dy)
    update(1)
    assert.are.equal(4, block_at(1, 1).jump_dy)
    assert.are.equal(4, block_at(1, 2).jump_dy)
    assert.are.equal(4, block_at(1, 4).jump_dy)

    -- 足し合わせず、高いほうになる (X も 0.5 マス)
    update(15)
    assert.are.equal(4, block_at(1, 4).jump_dy)
  end)

  --  ┌───┐
  --  │ H │
  --  ├───┤
  --  │ T │
  --  ├───┤
  --  │ T │
  -- ─┴───┴─
  it("押し上げたブロックは、マッチが終わって 12 フレーム浮いたあと、1 フレーム 1 マスで下りる", function()
    put(1, 3, 'h')
    put(1, 2, 't')
    put(1, 1, 't')

    -- TT がマッチ (結果は 1 段目が S、2 段目が空き)
    board:update()

    -- T は 1.5 マス (12 ドット) 押し上げる
    update(44)
    assert.are.equal(12, block_at(1, 3).jump_dy)

    -- 2 段目がはじけて (75 フレーム目) 結果が出た (76 フレーム目) あと、12 フレームはその高さ
    update(88 - 45)
    assert.are.equal(12, block_at(1, 3).jump_dy)
    assert.are.equal('s', block_at(1, 1).type)
    assert.are.equal(12, block_at(1, 1).jump_dy)

    update(1)
    assert.are.equal(4, block_at(1, 1).jump_dy)
    update(1)
    assert.are.equal(0, block_at(1, 1).jump_dy)
  end)

  it("押し上げられているブロックは入れ替えられない", function()
    put(1, 3, 'h')
    put(2, 3, 'y')
    put(1, 2, 't')
    put(1, 1, 't')

    board:update()
    update(44)

    assert.is_false(board:swap(1, 3))
  end)

  --  ┌───┬───┐
  --  │ C ┼─X │
  --  ├───┼───┘
  --  │ H │
  --  ├───┤
  --  │ H │
  -- ─┴───┴─
  it("押し上げるブロックに CNOT が載っていれば、その両端の列の上も押し上げる", function()
    board:put(1, 3, block_class("control"))
    board:put(2, 3, block_class("cnot_x"))
    block_at(1, 3).other_x, block_at(2, 3).other_x = 2, 1
    put(2, 4, 'y')
    put(1, 2, 'h')
    put(1, 1, 'h')

    board:update()
    update(44)

    assert.are.equal(4, block_at(1, 3).jump_dy)
    assert.are.equal(4, block_at(2, 3).jump_dy)
    assert.are.equal(4, block_at(2, 4).jump_dy)
  end)
end)
