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

    -- HXH がマッチ (QA2 と同じく結果はいちばん上の 3 段目が Z、ほかは空き)。このフレームを 1 フレーム目と数える
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
    assert.are.equal('i', block_at(1, 1).type)
    assert.are.equal('i', block_at(1, 2).type)
    assert.are.equal('z', block_at(1, 3).type)
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

    -- TT がマッチ (QA2 と同じく結果は上の 2 段目が S、1 段目が空き)
    board:update()

    -- T は 1.5 マス (12 ドット、jump_dy で 36) ずつ、T がはじけるたびに押し上げる
    update(44)
    assert.are.equal(36, block_at(1, 3).jump_dy)
    update(15)
    assert.are.equal(72, block_at(1, 3).jump_dy)

    -- 2 段目がはじけて (75 フレーム目) 結果が出た (76 フレーム目) あと、12 フレームはその高さ
    update(88 - 60)
    assert.are.equal(72, block_at(1, 3).jump_dy)
    assert.are.equal('s', block_at(1, 2).type)
    assert.are.equal(72, block_at(1, 2).jump_dy)

    -- S と H は空いた 1 段目へ 1 マス落ち、着地するまでは押し上げた高さのまま
    local s = block_at(1, 2)
    repeat
      board:update()
      assert.are.equal(72, s.jump_dy)
    until s.y == 1 and s.state == 'idle'

    -- 着地してから、3 マス (jump_dy で 72) を 1 フレーム 2 ずつ、ちょうど 36 フレームで下りる
    update(35)
    assert.is_true(block_at(1, 1).jump_dy > 0)
    update(1)
    assert.are.equal(0, block_at(1, 1).jump_dy)
    assert.are.equal(0, block_at(1, 2).jump_dy)
  end)

  it("押し上げられて浮いているブロックは、下りきるまでマッチできるブロックから外れる", function()
    put(1, 3, 'x')
    put(1, 2, 'h')
    put(1, 1, 'h')

    board:update()
    assert.are.equal(block_at(1, 3), board.reducible_blocks[3][1])

    -- 45 フレーム目に押し上げられる
    update(44)
    assert.is_nil(board.reducible_blocks[3][1])
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

  --        Y           H      6 段目
  --        C ───────── X      5 段目 (長い CNOT)
  --  X     S     Z     T     X     4 段目
  --  X ───────── X           3 段目 (長い SWAP)
  --  H                         2 段目
  --  H                         1 段目
  it("長い SWAP とその上の長い CNOT を、載っているブロックごと押し上げる", function()
    board:put(1, 3, block_class("swap"))
    board:put(4, 3, block_class("swap"))
    block_at(1, 3).other_x, block_at(4, 3).other_x = 4, 1
    board:put(2, 5, block_class("control"))
    board:put(5, 5, block_class("cnot_x"))
    block_at(2, 5).other_x, block_at(5, 5).other_x = 5, 2
    for x, t in pairs({ 'x', 's', 'z', 't', 'x' }) do
      put(x, 4, t)
    end
    put(2, 6, 'y')
    put(5, 6, 'h')
    for x = 2, 6 do
      put(x, 1, 'y')
      put(x, 2, 's')
    end
    put(1, 2, 'h')
    put(1, 1, 'h')

    board:update()
    update(59)

    -- H H で 0.5 マス (12) ずつ 2 回
    for _, xy in pairs({ { 1, 3 }, { 4, 3 }, { 1, 4 }, { 4, 4 }, { 2, 5 }, { 5, 5 }, { 2, 6 }, { 5, 6 } }) do
      assert.are.equal(24, block_at(xy[1], xy[2]).jump_dy)
    end
    -- CNOT の右の端の下の X は SWAP の上にはないので押し上げない
    assert.are.equal(0, block_at(5, 4).jump_dy)
  end)

  --  ┌───────────┐
  --  │     G     │  4 段目
  --  ├───┬───┬───┘
  --  │ Z │   │ Y │  3 段目 (真ん中は空き)
  --  ├───┼───┼───┤
  --  │ S │ H │ T │
  --  ├───┼───┼───┤
  --  │ T │ H │ S │
  -- ─┴───┴───┴───┴─
  it("QA2 と同じく、マッチの上にすきまがあれば、その上のおじゃまブロックは押し上げない", function()
    board:put(1, 4, garbage_block(3))
    put(1, 3, 'z')
    put(3, 3, 'y')
    put(1, 2, 's')
    put(2, 2, 'h')
    put(3, 2, 't')
    put(1, 1, 't')
    put(2, 1, 'h')
    put(3, 1, 's')

    board:update()
    update(59)

    assert.are.equal(24, block_at(2, 2).jump_dy)
    assert.are.equal(0, block_at(1, 4).jump_dy)
  end)

  --          ┌───┐
  --          │ Y │  4 段目
  --  ┌───────┴───┤
  --  │     G     │  3 段目 (下の HH のマッチで分解が始まる)
  --  ├───┬───┬───┤
  --  │ H │ S │ T │
  --  ├───┼───┼───┤
  --  │ H │ T │ S │
  -- ─┴───┴───┴───┴─
  it("分解中のおじゃまブロックを下から押し上げると、分解した列だけでなく全体が押し上がる", function()
    board:put(1, 3, garbage_block(3))
    put(3, 4, 'y')
    put(1, 2, 'h')
    put(2, 2, 's')
    put(3, 2, 't')
    put(1, 1, 'h')
    put(2, 1, 't')
    put(3, 1, 's')

    -- 45 と 60 フレーム目に H が 1 段ずつ押し上げる (12 + 12)。60 フレーム目のおじゃまブロックは
    -- 1 マス目と 2 マス目がゲートになり、3 マス目はまだ分解中
    board:update()
    update(59)

    assert.are.equal('match', block_at(3, 3).state)
    for x = 1, 3 do
      assert.are.equal(24, block_at(x, 3).jump_dy)
    end
    assert.are.equal(24, block_at(3, 4).jump_dy)
  end)

  --  ┌───────────┐
  --  │     G     │  5 段目
  --  └───┬───┬───┤
  --      │ Z │ X │  4 段目 (1 列目はすきま)
  --  ┌───┼───┼───┤
  --  │ Y │ X │ Z │
  --  ├───┼───┼───┤
  --  │ T │ H │ S │
  --  ├───┼───┼───┤
  --  │ T │ S │ H │
  -- ─┴───┴───┴───┴─
  it("すきまの上のおじゃまブロックは、押し上げられたブロックが届いたらその上に載る高さまで押し上げられ、貫通されない", function()
    board:put(1, 5, garbage_block(3))
    put(2, 4, 'z')
    put(3, 4, 'x')
    put(1, 3, 'y')
    put(2, 3, 'x')
    put(3, 3, 'z')
    put(1, 2, 't')
    put(2, 2, 'h')
    put(3, 2, 's')
    put(1, 1, 't')
    put(2, 1, 's')
    put(3, 1, 'h')
    local y, g = block_at(1, 3), board:block_at(1, 5)

    -- 45 フレーム目: T (1.5 マス、jump_dy で 36) で Y が押し上げられ、すきま 1 マス (24) をこえた
    -- 12 だけおじゃまブロックも押し上げられる
    board:update()
    update(43)
    assert.are.equal(0, g.jump_dy)
    update(1)
    assert.are.equal(36, y.jump_dy)
    assert.are.equal(12, g.jump_dy)
    -- 60 フレーム目: もう 1 段の T で Y は 72、おじゃまブロックは 48
    update(15)
    assert.are.equal(72, y.jump_dy)
    assert.are.equal(48, g.jump_dy)

    -- すきまの上のおじゃまブロックは、下りるときもその下のブロックにめり込まない
    for _ = 1, 200 do
      board:update()
      assert.is_true(g.y * 24 + g.jump_dy - g.fall_dy >= (y.y + 1) * 24 + y.jump_dy - y.fall_dy)
    end
    assert.are.equal(5, g.y)
    assert.are.equal(0, g.jump_dy)
  end)

  --  ┌───────────┐
  --  │     G     │  4 段目
  --  └───┬───┬───┤
  --      │ Z │ X │  3 段目 (1 列目はすきま)
  --  ┌───┼───┼───┤
  --  │ H │ T │ S │
  --  ├───┼───┼───┤
  --  │ H │ S │ T │
  -- ─┴───┴───┴───┴─
  it("押し上げられたブロックが届かなければ、すきまの上のおじゃまブロックは押し上げられない", function()
    board:put(1, 4, garbage_block(3))
    put(2, 3, 'z')
    put(3, 3, 'x')
    put(1, 2, 'h')
    put(2, 2, 't')
    put(3, 2, 's')
    put(1, 1, 'h')
    put(2, 1, 's')
    put(3, 1, 't')

    -- H H は 0.5 マスずつで、すきま 1 マスに届かない
    board:update()
    update(89)
    assert.are.equal(0, board:block_at(1, 4).jump_dy)
  end)

  --  ┌───┬───┐
  --  │ X ┼─X │  9 段目 (SWAP、下が空いているので落ちてくる)
  --  └───┴───┘
  --               4 から 8 段目 (空き)
  --      ┌───┐
  --      │ Y │  3 段目
  --  ┌───┼───┤
  --  │ S │ T │
  --  ├───┼───┤
  --  │ X │ T │
  -- ─┴───┴───┴─
  -- 落ちてくる場合と、すきまをあけて止まっている場合 (SWAP は左の端の列に支えがある)
  it("SWAP の右の端は、その下で押し上げられたブロックに貫通されない", function()
    for _, swap_y in pairs({ 9, 5 }) do
      board = board_class()
      board:put(1, swap_y, block_class("swap"))
      board:put(3, swap_y, block_class("swap"))
      block_at(1, swap_y).other_x, block_at(3, swap_y).other_x = 3, 1
      for y, t in pairs({ 'x', 's', 'z', 'h' }) do
        put(1, y, t)
      end
      put(3, 3, 'y')
      put(3, 2, 't')
      put(2, 2, 'x')
      put(3, 1, 't')
      put(2, 1, 'z')
      local y, right, pushed = block_at(3, 3), block_at(3, swap_y), false

      -- T T で Y が 3 マス押し上げられ、すきま 1 マスの上の SWAP の右の端に届く
      for _ = 1, 200 do
        board:update()
        pushed = pushed or right.jump_dy > 0
        assert.is_true(right.y * 24 + right.jump_dy - right.fall_dy >= (y.y + 1) * 24 + y.jump_dy - y.fall_dy)
      end
      assert.is_true(pushed)
      assert.are.equal(0, right.jump_dy)
    end
  end)

  it("押し上げられたまま着地した SWAP は、両端がそろって下りる", function()
    -- 落ちている SWAP の下で T T がマッチし、押し上げられたまま (浮いているあいだに) 着地する
    board:put(1, 6, block_class("swap"))
    board:put(2, 6, block_class("swap"))
    block_at(1, 6).other_x, block_at(2, 6).other_x = 2, 1
    put(1, 2, 't')
    put(2, 2, 'y')
    put(1, 1, 't')
    put(2, 1, 'z')
    local left, right, landed = block_at(1, 6), block_at(2, 6), false

    for _ = 1, 200 do
      board:update()
      landed = landed or left.state == "idle" and left.jump_dy > 0
      assert.are.equal(left.y, right.y)
      assert.are.equal(left.jump_dy, right.jump_dy)
    end
    assert.is_true(landed)
  end)

  it("タイトルのデモのように幅の広い盤面でも、右の列のブロックが落ちる", function()
    board = board_class(nil, 0, 16)
    put(16, 2, 'h')

    update(40)

    assert.are.equal('h', block_at(16, 1).type)
    assert.are.equal('idle', block_at(16, 1).state)
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
