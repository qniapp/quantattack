require("engine/test/bustedhelper")
require("engine/render/color")
require("lib/test_helper")
require("lib/qpu")

local board_class = require("lib/board")
local cursor_class = require("lib/cursor")

describe('qpu', function()
  describe('create_qpu', function()
    it("creates a qpu with score = 0", function()
      local qpu = create_qpu()

      assert.are_equal(0, qpu.score)
    end)
  end)

  describe('init', function()
    it("resets score", function()
      local qpu = create_qpu()
      qpu.score = 1

      qpu:init()

      assert.are_equal(0, qpu.score)
    end)
  end)

  describe('update', function()
    local board
    local cursor
    local qpu

    before_each(function()
      cursor = cursor_class()
      board = board_class(cursor)
      qpu = create_qpu(board)
      qpu.sleep = false
      qpu.raise = false
    end)

    -- ボードが次のようになっているとき、
    -- T を左に落とす (left, o)
    --
    --   [T  ]
    --  _ X Y
    it("左に落とす", function()
      board:put(2, 12, t_block())
      board:put(2, 13, x_block())
      board:put(3, 13, y_block())
      cursor.x = 2
      cursor.y = 12

      qpu:update()

      assert.are_equal(6, #qpu.commands)
      assert.are_equal("left", qpu.commands[1])
      assert.are_equal("x", qpu.commands[2])
      assert.are_equal("sleep", qpu.commands[3])
      assert.are_equal("sleep", qpu.commands[4])
      assert.are_equal("sleep", qpu.commands[5])
      assert.are_equal("sleep", qpu.commands[6])
    end)

    -- ボードが次のようになっているとき、
    -- T を右に落とす (o)
    --
    --   [T  ]
    --  X Y
    it("右に落とす", function()
      board:put(2, 16, t_block())
      board:put(1, 17, x_block())
      board:put(2, 17, y_block())
      cursor.x = 2
      cursor.y = 16

      qpu:update()

      assert.are_equal(5, #qpu.commands)
      assert.are_equal("x", qpu.commands[1])
      assert.are_equal("sleep", qpu.commands[2])
      assert.are_equal("sleep", qpu.commands[3])
      assert.are_equal("sleep", qpu.commands[4])
      assert.are_equal("sleep", qpu.commands[5])
    end)

    -- ボードが次のようになっているとき、
    -- T を右に落とす (o)
    --
    -- [T  ]
    --  X
    it("左壁ぎわのブロックを右に落とす", function()
      board:put(1, 16, t_block())
      board:put(1, 17, x_block())
      cursor.x = 1
      cursor.y = 16

      qpu:update()

      assert.are_equal(5, #qpu.commands)
      assert.are_equal("x", qpu.commands[1])
      assert.are_equal("sleep", qpu.commands[2])
      assert.are_equal("sleep", qpu.commands[3])
      assert.are_equal("sleep", qpu.commands[4])
      assert.are_equal("sleep", qpu.commands[5])
    end)

    -- ボードが次のようになっているとき、
    -- T を左に動かしてマッチ (left, o)
    --
    --         [T  ]
    --  _ _ _ T X Y
    it("左に動かしてマッチ", function()
      board:put(5, 16, t_block())
      board:put(4, 17, t_block())
      board:put(5, 17, x_block())
      board:put(6, 17, y_block())
      cursor.x = 5
      cursor.y = 16

      qpu:update()

      assert.are_equal(6, #qpu.commands)
      assert.are_equal("left", qpu.commands[1])
      assert.are_equal("x", qpu.commands[2])
      assert.are_equal("sleep", qpu.commands[3])
      assert.are_equal("sleep", qpu.commands[4])
      assert.are_equal("sleep", qpu.commands[5])
      assert.are_equal("sleep", qpu.commands[6])
    end)

    -- ボードが次のようになっているとき、
    -- T を左に動かしてマッチ (left, o)
    --
    --  H[T  ]
    --  T X Y Y Y Y
    it("左に動かしてマッチ (他のブロックとの入れ替えあり)", function()
      board:put(1, 16, h_block())
      board:put(2, 16, t_block())
      board:put(1, 17, t_block())
      board:put(2, 17, x_block())
      board:put(3, 17, y_block())
      board:put(4, 17, y_block())
      board:put(5, 17, y_block())
      board:put(6, 17, y_block())
      cursor.x = 2
      cursor.y = 16

      qpu:update()

      assert.are_equal(6, #qpu.commands)
      assert.are_equal("left", qpu.commands[1])
      assert.are_equal("x", qpu.commands[2])
      assert.are_equal("sleep", qpu.commands[3])
      assert.are_equal("sleep", qpu.commands[4])
      assert.are_equal("sleep", qpu.commands[5])
      assert.are_equal("sleep", qpu.commands[6])
    end)

    -- ボードが次のようになっているとき、
    -- T を右に動かしてマッチ (o)
    --
    --   [T  ]
    --  X Y T
    it("右に動かしてマッチ", function()
      board:put(2, 16, t_block())
      board:put(1, 17, x_block())
      board:put(2, 17, y_block())
      board:put(3, 17, t_block())
      cursor.x = 2
      cursor.y = 16

      qpu:update()

      assert.are_equal(5, #qpu.commands)
      assert.are_equal("x", qpu.commands[1])
      assert.are_equal("sleep", qpu.commands[2])
      assert.are_equal("sleep", qpu.commands[3])
      assert.are_equal("sleep", qpu.commands[4])
      assert.are_equal("sleep", qpu.commands[5])
    end)

    -- ボードが次のようになっているとき、
    -- T を右に動かしてマッチ (o)
    --
    --         [T H]
    --  _ _ _ X Y T
    it("右に動かしてマッチ (入れ替えあり)", function()
      board:put(5, 16, t_block())
      board:put(6, 17, h_block())
      board:put(1, 17, x_block())
      board:put(2, 17, x_block())
      board:put(3, 17, x_block())
      board:put(4, 17, x_block())
      board:put(5, 17, y_block())
      board:put(6, 17, t_block())
      cursor.x = 5
      cursor.y = 16

      qpu:update()

      assert.are_equal(5, #qpu.commands)
      assert.are_equal("x", qpu.commands[1])
      assert.are_equal("sleep", qpu.commands[2])
      assert.are_equal("sleep", qpu.commands[3])
      assert.are_equal("sleep", qpu.commands[4])
      assert.are_equal("sleep", qpu.commands[5])
    end)

    -- ボードが次のようになっているとき、
    -- H を左に 1 マス動かす (o)
    --
    --   [  H]
    --    T T T T T
    it("左に 1 マス動かす", function()
      board:put(3, 16, h_block())
      board:put(2, 17, t_block())
      board:put(3, 17, t_block())
      board:put(4, 17, t_block())
      board:put(5, 17, t_block())
      board:put(6, 17, t_block())
      cursor.x = 2
      cursor.y = 16

      qpu:update()

      assert.are_equal(5, #qpu.commands)
      assert.are_equal("x", qpu.commands[1])
      assert.are_equal("sleep", qpu.commands[2])
      assert.are_equal("sleep", qpu.commands[3])
      assert.are_equal("sleep", qpu.commands[4])
      assert.are_equal("sleep", qpu.commands[5])
    end)

    -- ボードが次のようになっているとき、
    -- H を左に 1 マス動かす (o)
    --
    --   [  H]
    --  H T T T T T
    it("左に 1 マス動かす", function()
      board:put(3, 16, h_block())
      board:put(1, 17, h_block())
      board:put(2, 17, t_block())
      board:put(3, 17, t_block())
      board:put(4, 17, t_block())
      board:put(5, 17, t_block())
      board:put(6, 17, t_block())
      cursor.x = 2
      cursor.y = 16

      qpu:update()

      assert.are_equal(5, #qpu.commands)
      assert.are_equal("x", qpu.commands[1])
      assert.are_equal("sleep", qpu.commands[2])
      assert.are_equal("sleep", qpu.commands[3])
      assert.are_equal("sleep", qpu.commands[4])
      assert.are_equal("sleep", qpu.commands[5])
    end)

    -- ボードが次のようになっているとき、
    -- H を左に 1 マス動かす (o)
    --
    --  H g g g g g
    -- [  H]
    it("左に 1 マス動かしてマッチ", function()
      board:put(1, 12, h_block())
      board:put(2, 12, garbage_block(5, 1))
      board:put(2, 13, h_block())
      cursor.x = 1
      cursor.y = 13

      qpu:update()

      assert.are_equal(5, #qpu.commands)
      assert.are_equal("x", qpu.commands[1])
      assert.are_equal("sleep", qpu.commands[2])
      assert.are_equal("sleep", qpu.commands[3])
      assert.are_equal("sleep", qpu.commands[4])
      assert.are_equal("sleep", qpu.commands[5])
    end)

    -- [X-]-C
    it("CNOT を X 側から縮める", function()
      board:put(1, 17, cnot_x_block(3))
      board:put(3, 17, control_block(1))
      cursor.x = 1
      cursor.y = 17

      qpu:update()

      assert.are_equal(5, #qpu.commands)
      assert.are_equal("x", qpu.commands[1])
      assert.are_equal("sleep", qpu.commands[2])
      assert.are_equal("sleep", qpu.commands[3])
      assert.are_equal("sleep", qpu.commands[4])
      assert.are_equal("sleep", qpu.commands[5])
    end)

    -- [C-]-X
    it("CNOT を C 側から縮める", function()
      board:put(1, 17, control_block(3))
      board:put(3, 17, cnot_x_block(1))
      cursor.x = 1
      cursor.y = 17

      qpu:update()

      assert.are_equal(5, #qpu.commands)
      assert.are_equal("x", qpu.commands[1])
      assert.are_equal("sleep", qpu.commands[2])
      assert.are_equal("sleep", qpu.commands[3])
      assert.are_equal("sleep", qpu.commands[4])
      assert.are_equal("sleep", qpu.commands[5])
    end)

    -- [  X]-C
    --  X-C  ■
    it("ずれた CNOT を消す", function()
      board:put(5, 16, cnot_x_block(6))
      board:put(6, 16, control_block(5))
      board:put(4, 17, cnot_x_block(5))
      board:put(5, 17, control_block(4))
      board:put(6, 17, t_block())
      cursor.x = 4
      cursor.y = 16

      qpu:update()

      assert.are_equal(5, #qpu.commands)
      assert.are_equal("x", qpu.commands[1])
      assert.are_equal("sleep", qpu.commands[2])
      assert.are_equal("sleep", qpu.commands[3])
      assert.are_equal("sleep", qpu.commands[4])
      assert.are_equal("sleep", qpu.commands[5])
    end)
  end)
end)
