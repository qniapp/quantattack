require("engine/test/bustedhelper")
require("board")
require("player_cursor")
require("qpu")

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
      board = create_board()
      cursor = create_player_cursor(board)
      qpu = create_qpu(cursor, false)
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

      qpu:update(board)

      assert.are_equal(6, #qpu.commands)
      assert.are_equal("left", qpu.commands[1])
      assert.are_equal("o", qpu.commands[2])
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
      board:put(2, 12, t_gate())
      board:put(1, 13, x_gate())
      board:put(2, 13, y_gate())
      cursor.x = 2
      cursor.y = 12

      qpu:update(board)

      assert.are_equal(5, #qpu.commands)
      assert.are_equal("o", qpu.commands[1])
      assert.are_equal("sleep", qpu.commands[2])
      assert.are_equal("sleep", qpu.commands[3])
      assert.are_equal("sleep", qpu.commands[4])
      assert.are_equal("sleep", qpu.commands[5])
    end)

    -- ボードが次のようになっているとき、
    -- T を左に動かしてマッチ (left, o)
    --
    --   [T  ]
    --  T X Y
    it("左に動かしてマッチ", function()
      board:put(2, 12, t_gate())
      board:put(1, 13, t_gate())
      board:put(2, 13, x_gate())
      board:put(3, 13, y_gate())
      cursor.x = 2
      cursor.y = 12

      qpu:update(board)

      assert.are_equal(6, #qpu.commands)
      assert.are_equal("left", qpu.commands[1])
      assert.are_equal("o", qpu.commands[2])
      assert.are_equal("sleep", qpu.commands[3])
      assert.are_equal("sleep", qpu.commands[4])
      assert.are_equal("sleep", qpu.commands[5])
      assert.are_equal("sleep", qpu.commands[6])
    end)

    -- ボードが次のようになっているとき、
    -- T を左に動かしてマッチ (left, o)
    --
    --  H[T  ]
    --  T X Y
    it("左に動かしてマッチ (他のゲートとの入れ替えあり)", function()
      board:put(1, 12, h_gate())
      board:put(2, 12, t_gate())
      board:put(1, 13, t_gate())
      board:put(2, 13, x_gate())
      board:put(3, 13, y_gate())
      cursor.x = 2
      cursor.y = 12

      qpu:update(board)

      assert.are_equal(6, #qpu.commands)
      assert.are_equal("left", qpu.commands[1])
      assert.are_equal("o", qpu.commands[2])
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
      board:put(2, 12, t_gate())
      board:put(1, 13, x_gate())
      board:put(2, 13, y_gate())
      board:put(3, 13, t_gate())
      cursor.x = 2
      cursor.y = 12

      qpu:update(board)

      assert.are_equal(5, #qpu.commands)
      assert.are_equal("o", qpu.commands[1])
      assert.are_equal("sleep", qpu.commands[2])
      assert.are_equal("sleep", qpu.commands[3])
      assert.are_equal("sleep", qpu.commands[4])
      assert.are_equal("sleep", qpu.commands[5])
    end)

    -- ボードが次のようになっているとき、
    -- T を右に動かしてマッチ (o)
    --
    --   [T H]
    --  X Y T
    it("右に動かしてマッチ (入れ替えあり)", function()
      board:put(2, 12, t_gate())
      board:put(3, 12, h_gate())
      board:put(1, 13, x_gate())
      board:put(2, 13, y_gate())
      board:put(3, 13, t_gate())
      cursor.x = 2
      cursor.y = 12

      qpu:update(board)

      assert.are_equal(5, #qpu.commands)
      assert.are_equal("o", qpu.commands[1])
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
      board:put(3, 12, h_gate())
      board:put(2, 13, t_gate())
      board:put(3, 13, t_gate())
      board:put(4, 13, t_gate())
      board:put(5, 13, t_gate())
      board:put(6, 13, t_gate())
      cursor.x = 2
      cursor.y = 12

      qpu:update(board)

      assert.are_equal(5, #qpu.commands)
      assert.are_equal("o", qpu.commands[1])
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
      board:put(3, 12, h_gate())
      board:put(1, 13, h_gate())
      board:put(2, 13, t_gate())
      board:put(3, 13, t_gate())
      board:put(4, 13, t_gate())
      board:put(5, 13, t_gate())
      board:put(6, 13, t_gate())
      cursor.x = 2
      cursor.y = 12

      qpu:update(board)

      assert.are_equal(5, #qpu.commands)
      assert.are_equal("o", qpu.commands[1])
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

      qpu:update(board)

      assert.are_equal(5, #qpu.commands)
      assert.are_equal("o", qpu.commands[1])
      assert.are_equal("sleep", qpu.commands[2])
      assert.are_equal("sleep", qpu.commands[3])
      assert.are_equal("sleep", qpu.commands[4])
      assert.are_equal("sleep", qpu.commands[5])
    end)
  end)
end)