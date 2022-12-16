require("engine/test/bustedhelper")
require("engine/render/color")
require("lib/test_helper")
require("lib/qpu")

local board_class = require("lib/board")
local cursor_class = require("lib/cursor")

describe('qpu', function()
  describe('create_qpu', function()
    it("creates a qpu with steps = 0, score = 0", function()
      local qpu = create_qpu()

      assert.are_equal(0, qpu.steps)
      assert.are_equal(0, qpu.score)
    end)
  end)

  describe('init', function()
    it("initializes steps = 0, score = 0", function()
      local qpu = create_qpu()
      qpu.steps = 1
      qpu.score = 1

      qpu:init()

      assert.are_equal(0, qpu.steps)
      assert.are_equal(0, qpu.score)
    end)
  end)

  describe('update', function()
    local board
    local cursor
    local qpu

    before_each(function()
      board = board_class()
      cursor = cursor_class(board)
      qpu = create_qpu(cursor, board)
      qpu.sleep = false
      qpu.raise = false
    end)

    -- ボードが次のようになっているとき、
    -- T を左に落とす (left, o)
    --
    --   [T  ]
    --  _ X Y
    it("左に落とす", function()
      board:put(2, 12, t_gate())
      board:put(2, 13, x_gate())
      board:put(3, 13, y_gate())
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
      board:put(2, 16, t_gate())
      board:put(1, 17, x_gate())
      board:put(2, 17, y_gate())
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
    it("左壁ぎわのゲートを右に落とす", function()
      board:put(1, 16, t_gate())
      board:put(1, 17, x_gate())
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
      board:put(5, 16, t_gate())
      board:put(4, 17, t_gate())
      board:put(5, 17, x_gate())
      board:put(6, 17, y_gate())
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
    it("左に動かしてマッチ (他のゲートとの入れ替えあり)", function()
      board:put(1, 16, h_gate())
      board:put(2, 16, t_gate())
      board:put(1, 17, t_gate())
      board:put(2, 17, x_gate())
      board:put(3, 17, y_gate())
      board:put(4, 17, y_gate())
      board:put(5, 17, y_gate())
      board:put(6, 17, y_gate())
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
      board:put(2, 16, t_gate())
      board:put(1, 17, x_gate())
      board:put(2, 17, y_gate())
      board:put(3, 17, t_gate())
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
      board:put(5, 16, t_gate())
      board:put(6, 17, h_gate())
      board:put(1, 17, x_gate())
      board:put(2, 17, x_gate())
      board:put(3, 17, x_gate())
      board:put(4, 17, x_gate())
      board:put(5, 17, y_gate())
      board:put(6, 17, t_gate())
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
      board:put(3, 16, h_gate())
      board:put(2, 17, t_gate())
      board:put(3, 17, t_gate())
      board:put(4, 17, t_gate())
      board:put(5, 17, t_gate())
      board:put(6, 17, t_gate())
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
      board:put(3, 16, h_gate())
      board:put(1, 17, h_gate())
      board:put(2, 17, t_gate())
      board:put(3, 17, t_gate())
      board:put(4, 17, t_gate())
      board:put(5, 17, t_gate())
      board:put(6, 17, t_gate())
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
      board:put(1, 12, h_gate())
      board:put(2, 12, garbage_gate(5, 1))
      board:put(2, 13, h_gate())
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
      board:put(1, 17, cnot_x_gate(3))
      board:put(3, 17, control_gate(1))
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
      board:put(1, 17, control_gate(3))
      board:put(3, 17, cnot_x_gate(1))
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
      board:put(5, 16, cnot_x_gate(6))
      board:put(6, 16, control_gate(5))
      board:put(4, 17, cnot_x_gate(5))
      board:put(5, 17, control_gate(4))
      board:put(6, 17, t_gate())
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
