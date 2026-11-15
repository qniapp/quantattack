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

    -- 1 段目の H の番: 45 フレーム目に H (0.5 マス = 4 ドット、jump_dy は 1/3 ドット単位で 12) の高さまで押し上げる
    update(43)
    assert.are.equal(0, block_at(1, 4).jump_dy)
    update(1)
    assert.are.equal(12, block_at(1, 1).jump_dy)
    assert.are.equal(12, block_at(1, 2).jump_dy)
    assert.are.equal(12, block_at(1, 4).jump_dy)

    -- 2 段目の X の番には、さらに X (0.5 マス) の高さだけ押し上げる
    update(14)
    assert.are.equal(12, block_at(1, 4).jump_dy)
    update(1)
    assert.are.equal(24, block_at(1, 2).jump_dy)
    assert.are.equal(24, block_at(1, 3).jump_dy)
    assert.are.equal(24, block_at(1, 4).jump_dy)
    -- はじけた 1 段目はそれ以上押し上げない
    assert.are.equal(12, block_at(1, 1).jump_dy)

    -- 3 段目の H の番には、さらに H (0.5 マス)
    update(15)
    assert.are.equal(36, block_at(1, 3).jump_dy)
    assert.are.equal(36, block_at(1, 4).jump_dy)
  end)

  --  ┌───┐
  --  │ H │
  --  ├───┤
  --  │ T │
  --  ├───┤
  --  │ T │
  -- ─┴───┴─
  it("押し上げたブロックは、マッチが終わって 12 フレーム浮いたあと、QA2 と同じ秒速 5 マスで下りる", function()
    put(1, 3, 'h')
    put(1, 2, 't')
    put(1, 1, 't')

    -- TT がマッチ (結果は 1 段目が S、2 段目が空き)
    board:update()

    -- T は 1.5 マス (12 ドット、jump_dy で 36) ずつ、T がはじけるたびに押し上げる
    update(44)
    assert.are.equal(36, block_at(1, 3).jump_dy)
    update(15)
    assert.are.equal(72, block_at(1, 3).jump_dy)

    -- 2 段目がはじけて (75 フレーム目) 結果が出た (76 フレーム目) あと、12 フレームはその高さ
    update(88 - 60)
    assert.are.equal(72, block_at(1, 3).jump_dy)
    assert.are.equal('s', block_at(1, 1).type)
    assert.are.equal(36, block_at(1, 1).jump_dy)

    -- 1.5 マス (12 ドット) を 1 フレーム 2/3 ドット (jump_dy で 2) ずつ、ちょうど 18 フレームで下りる
    update(17)
    assert.is_true(block_at(1, 1).jump_dy > 0)
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

    assert.are.equal(12, block_at(1, 3).jump_dy)
    assert.are.equal(12, block_at(2, 3).jump_dy)
    assert.are.equal(12, block_at(2, 4).jump_dy)
  end)

  --  ┌───────────┐
  --  │ C ──┼── X │  ← 真ん中の列だけが HH の上
  --  └───┬───┬───┘
  --      │ H │
  --      ├───┤
  --      │ H │
  -- ─────┴───┴───
  it("CNOT の真ん中の列を押し上げても、両端とその上を押し上げる", function()
    board:put(1, 3, block_class("control"))
    board:put(3, 3, block_class("cnot_x"))
    block_at(1, 3).other_x, block_at(3, 3).other_x = 3, 1
    put(1, 4, 'y')
    put(3, 4, 'z')
    put(1, 1, 's')
    put(3, 1, 's')
    put(1, 2, 'x')
    put(3, 2, 'y')
    put(2, 2, 'h')
    put(2, 1, 'h')

    board:update()
    update(44)

    assert.are.equal(12, block_at(1, 3).jump_dy)
    assert.are.equal(12, block_at(3, 3).jump_dy)
    assert.are.equal(12, block_at(1, 4).jump_dy)
    assert.are.equal(12, block_at(3, 4).jump_dy)
    assert.are.equal(0, block_at(1, 2).jump_dy)
  end)

  --  ┌───┐
  --  │ T │              4 段目
  --  ├───┼───┐
  --  │ X ┼─X │          3 段目 (SWAP)
  --  └───┼───┼───┐
  --      │ X ┼─X │      2 段目 (SWAP)
  --  ┌───┼───┼───┤
  --  │ H │ Y │ T │      1 段目
  -- ─┴───┴───┴───┴─
  it("SWAP をたどる簡約でも、いちばん上のゲートまで下から順にはじける", function()
    put(1, 4, 't')
    board:put(1, 3, block_class("swap"))
    board:put(2, 3, block_class("swap"))
    block_at(1, 3).other_x, block_at(2, 3).other_x = 2, 1
    board:put(2, 2, block_class("swap"))
    board:put(3, 2, block_class("swap"))
    block_at(2, 2).other_x, block_at(3, 2).other_x = 3, 2
    put(1, 1, 'h')
    put(2, 1, 'y')
    put(3, 1, 't')
    put(1, 2, 's')

    board:update()

    -- T と T が簡約される (SWAP は残る)。上の T が 4 段目、下の T が 1 段目
    assert.are.equal('match', block_at(3, 1).state)
    assert.are.equal('match', block_at(1, 4).state)
    assert.are.equal(4, block_at(1, 4)._match_group.rows)
    assert.are.equal(4, block_at(1, 4)._match_index)
    assert.are.equal(1, block_at(3, 1)._match_index)

    -- 1 段目の T は 60 フレーム目、4 段目の T は 105 フレーム目にはじけ、その次のフレームに結果が出る
    update(59)
    assert.is_false(visible(3, 1))
    assert.is_true(visible(1, 4))
    update(44)
    assert.is_true(visible(1, 4))
    update(1)
    assert.is_false(visible(1, 4))
    assert.are.equal('match', block_at(1, 4).state)
    update(1)
    assert.are_not.equal('match', block_at(1, 4).state)
  end)

  --  ┌───┬───┬───┐
  --  │ X ┼───┼─X │  ← 両端が別々のマッチの上
  --  ├───┼───┼───┤
  --  │ H │ Y │ Z │
  --  ├───┼───┼───┤
  --  │ H │ S │ Z │
  -- ─┴───┴───┴───┴─
  it("別々のマッチが同じフレームに同じブロックを押し上げると、両方の高さを足す", function()
    board:put(1, 3, block_class("swap"))
    board:put(3, 3, block_class("swap"))
    block_at(1, 3).other_x, block_at(3, 3).other_x = 3, 1
    put(1, 2, 'h')
    put(1, 1, 'h')
    put(2, 2, 'y')
    put(2, 1, 's')
    put(3, 2, 'z')
    put(3, 1, 'z')

    -- 同時消しなので game がいる
    board:update({})
    update(44)

    -- H H も Z Z も 0.5 マス (12)
    assert.are.equal(24, block_at(1, 3).jump_dy)
    assert.are.equal(24, block_at(3, 3).jump_dy)
  end)

  it("落ちている途中のブロックを入れ替えても、そのまま下り続ける", function()
    put(1, 2, 'h')

    -- ホバー 12 フレームのあと、1 段目に移って下りはじめる
    update(15)
    assert.are.equal('h', block_at(1, 1).type)
    local fall_dy = block_at(1, 1).fall_dy
    assert.is_true(fall_dy < 0)

    assert.is_true(board:swap(1, 1))
    update(1)
    assert.are.equal(fall_dy + 2, block_at(1, 1).fall_dy)
  end)

  --  ┌───────────┐
  --  │     G     │  4 段目
  --  └───────────┘
  --                 3 段目 (空き)
  --  ┌───┐
  --  │ H │          2 段目
  -- ─┴───┴─────────
  it("おじゃまブロックは、下で下りているブロックにめり込まない", function()
    -- すきまをあけて落ちる場合と、すぐ上に載っていっしょに落ちだす場合
    for _, garbage_y in pairs({ 4, 3 }) do
      board = board_class()
      board:put(1, garbage_y, garbage_block(3))
      put(1, 2, 'h')

      for _ = 1, 40 do
        board:update()
        local h, g = block_at(1, 1), board:block_at(1, 2)
        if h.type == 'h' and g.type == 'g' then
          -- すぐ上のマスにいるとき、下のブロックより下には描かない
          assert.is_true(g.fall_dy <= h.fall_dy)
        end
      end
    end
  end)
end)
