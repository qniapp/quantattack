
test('board', function(desc,it)
  desc('cols', function()
    it('should be 6', function()
      return board:new().cols == 6
    end)
  end)

  desc('rows', function()
    it('should be 13', function()
      return board:new().rows_plus_next_rows == 13
    end)
  end)

  desc('rows_plus_next_rows', function()
    it('should be 12', function()
      return board:new().rows == 12
    end)
  end)

  desc("top", function()
    it('should be 0 by default', function()
      return board:new().top == 0
    end)
  end)

  desc("left", function()
    it('should be 0 by default', function()
      return board:new().left == 0
    end)
  end)

  desc('new', function ()
    it('should be initialized with id gates', function ()
      local player_board = board:new()
      local result = true

      for x = 1, player_board.cols do
        for y = 1, player_board.rows_plus_next_rows do
          result = result and player_board:gate_at(x, y):is_i()
        end
      end

      return result
    end)      
  end)

  desc('drop_gates', function ()
    --
    --  x  drop_gates
    --     --------->  x
    --  _              _
    --
    it('should drop gates', function ()
      local player_board = board:new()
      player_board:put(1, 10, quantum_gate:x())

      player_board:drop_gates()

      return player_board:gate_at(1, 12):is_x()
    end)

    --
    --     drop_gates
    --  x  --------->  x
    --  _              _
    --
    it('should stop dropping gate when it reaches the ground', function ()
      local player_board = board:new()
      player_board:put(1, player_board.rows, quantum_gate:x())

      player_board:drop_gates()

      return player_board:gate_at(1, player_board.rows):is_x()
    end)

    --  x    drop_gates  
    --       --------->  x
    -- c-x              c-x
    it('should drop gate until it stops at cnot', function ()
      local player_board = board:new()
      player_board:put(2, 1, quantum_gate:x())
      player_board:put(1, player_board.rows, quantum_gate:control(3))
      player_board:put(3, player_board.rows, quantum_gate:x(1))

      player_board:drop_gates()

      return player_board:gate_at(2, player_board.rows - 1):is_x()
    end)

    --  x    drop_gates  
    --       --------->  x
    -- s-s              s-s
    it('should drop gate until it stops at swap', function ()
      local player_board = board:new()
      player_board:put(2, 1, quantum_gate:x())
      player_board:put(1, player_board.rows, quantum_gate:swap(3))
      player_board:put(3, player_board.rows, quantum_gate:swap(1))

      player_board:drop_gates()

      return player_board:gate_at(2, player_board.rows - 1):is_x()
    end)

    -- c-x  drop_gates
    --      --------->  c-x
    -- _x_              _x_
    it('should drop cnot pair until it stops at another gate', function ()
      local player_board = board:new()
      player_board:put(1, 1, quantum_gate:control(3))
      player_board:put(3, 1, quantum_gate:x(1))
      player_board:put(2, player_board.rows, quantum_gate:x())

      player_board:drop_gates()

      return player_board:gate_at(1, player_board.rows - 1):is_control(),
             player_board:gate_at(3, player_board.rows - 1):is_cnot_x()
    end)

    -- s-s  drop_gates
    --      --------->  s-s
    -- _x_              _x_
    it('should drop swap pair until it stops at another gate', function ()
      local player_board = board:new()
      player_board:put(1, 1, quantum_gate:swap(3))
      player_board:put(3, 1, quantum_gate:swap(1))
      player_board:put(2, player_board.rows, quantum_gate:x())

      player_board:drop_gates()

      return player_board:gate_at(1, player_board.rows - 1):is_swap(),
             player_board:gate_at(3, player_board.rows - 1):is_swap()
    end)
  end)  
end)
