require("engine/test/bustedhelper")
require("board")
require("player_cursor")
require("qpu")

describe('qpu #solo', function()
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
    -- ボードが次のようになっているとき、
    -- T を左に落とす (left, o)
    --
    --   [T  ]
    --  _ X Y
    it("左に落とす", function()
      local board = create_board()
      local cursor = create_player_cursor(board)
      local qpu = create_qpu(cursor, false)

      board:put(2, 12, t_gate())
      board:put(2, 13, x_gate())
      board:put(3, 13, y_gate())
      cursor.x = 2
      cursor.y = 12

      qpu:update(board)

      assert.are_equal(2, #qpu.commands)
      assert.are_equal("left", qpu.commands[1])
      assert.are_equal("o", qpu.commands[2])
    end)

    -- ボードが次のようになっているとき、
    -- T を右に落とす (o)
    --
    --   [T  ]
    --  X Y
    it("右に落とす", function()
      local board = create_board()
      local cursor = create_player_cursor(board)
      local qpu = create_qpu(cursor, false)

      board:put(2, 12, t_gate())
      board:put(1, 13, x_gate())
      board:put(2, 13, y_gate())
      cursor.x = 2
      cursor.y = 12

      qpu:update(board)

      assert.are_equal(1, #qpu.commands)
      assert.are_equal("o", qpu.commands[1])
    end)

    -- ボードが次のようになっているとき、
    -- T を左に動かしてマッチ (left, o)
    --
    --   [T  ]
    --  T X Y
    it("左に動かしてマッチ", function()
      local board = create_board()
      local cursor = create_player_cursor(board)
      local qpu = create_qpu(cursor, false)

      board:put(2, 12, t_gate())
      board:put(1, 13, t_gate())
      board:put(2, 13, x_gate())
      board:put(3, 13, y_gate())
      cursor.x = 2
      cursor.y = 12

      qpu:update(board)

      assert.are_equal(2, #qpu.commands)
      assert.are_equal("left", qpu.commands[1])
      assert.are_equal("o", qpu.commands[2])
    end)

    -- ボードが次のようになっているとき、
    -- T を左に動かしてマッチ (left, o)
    --
    --  H[T  ]
    --  T X Y
    it("左に動かしてマッチ (他のゲートとの入れ替えあり)", function()
      local board = create_board()
      local cursor = create_player_cursor(board)
      local qpu = create_qpu(cursor, false)

      board:put(1, 12, h_gate())
      board:put(2, 12, t_gate())
      board:put(1, 13, t_gate())
      board:put(2, 13, x_gate())
      board:put(3, 13, y_gate())
      cursor.x = 2
      cursor.y = 12

      qpu:update(board)

      assert.are_equal(2, #qpu.commands)
      assert.are_equal("left", qpu.commands[1])
      assert.are_equal("o", qpu.commands[2])
    end)

    -- ボードが次のようになっているとき、
    -- T を右に動かしてマッチ (o)
    --
    --   [T  ]
    --  X Y T
    it("右に動かしてマッチ", function()
      local board = create_board()
      local cursor = create_player_cursor(board)
      local qpu = create_qpu(cursor, false)

      board:put(2, 12, t_gate())
      board:put(1, 13, x_gate())
      board:put(2, 13, y_gate())
      board:put(3, 13, t_gate())
      cursor.x = 2
      cursor.y = 12

      qpu:update(board)

      assert.are_equal(1, #qpu.commands)
      assert.are_equal("o", qpu.commands[1])
    end)

    -- ボードが次のようになっているとき、
    -- T を右に動かしてマッチ (o)
    --
    --   [T H]
    --  X Y T
    it("右に動かしてマッチ (入れ替えあり)", function()
      local board = create_board()
      local cursor = create_player_cursor(board)
      local qpu = create_qpu(cursor, false)

      board:put(2, 12, t_gate())
      board:put(3, 12, h_gate())
      board:put(1, 13, x_gate())
      board:put(2, 13, y_gate())
      board:put(3, 13, t_gate())
      cursor.x = 2
      cursor.y = 12

      qpu:update(board)

      assert.are_equal(1, #qpu.commands)
      assert.are_equal("o", qpu.commands[1])
    end)
  end)
end)
