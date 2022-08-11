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
      local board = board:new()
      local result = true

      for x = 1, board.cols do
        for y = 1, board.rows_plus_next_rows do
          result = result and board:gate_at(x, y):is_i()
        end
      end

      return result
    end)      
  end)

  desc('reduce', function ()
    --
    --  h  reduce
    --  h  ----->  i
    --
    it('should reduce hh', function ()
      local board = board:new()
      board:put(1, 11, h_gate:new())
      board:put(1, 12, h_gate:new())

      board:reduce()

      return board:gate_at(1, 11)._reduce_to == "i",
             board:gate_at(1, 12)._reduce_to == "i"
    end)

    --  x  reduce
    --  x  ----->  i
    --
    it('should reduce xx', function ()
      local board = board:new()
      board:put(1, 11, x_gate:new())
      board:put(1, 12, x_gate:new())

      board:reduce()

      return board:gate_at(1, 11)._reduce_to == "i",
             board:gate_at(1, 12)._reduce_to == "i"
    end)

    --  y  reduce
    --  y  ----->  i
    --
    it('should reduce yy', function ()
      local board = board:new()
      board:put(1, 11, y_gate:new())
      board:put(1, 12, y_gate:new())

      board:reduce()

      return board:gate_at(1, 11)._reduce_to == "i",
             board:gate_at(1, 12)._reduce_to == "i"
    end)

    --  z  reduce
    --  z  ----->  i
    --
    it('should reduce zz', function ()
      local board = board:new()
      board:put(1, 11, quantum_gate:z())
      board:put(1, 12, quantum_gate:z())

      board:reduce()

      return board:gate_at(1, 11)._reduce_to == "i",
             board:gate_at(1, 12)._reduce_to == "i"
    end)

    --  z  reduce
    --  x  ----->  y
    --
    it('should reduce zx', function ()
      local board = board:new()
      board:put(1, 11, quantum_gate:z())
      board:put(1, 12, x_gate:new())

      board:reduce()

      return board:gate_at(1, 11)._reduce_to == "i",
             board:gate_at(1, 12)._reduce_to == "y"
    end)

    --  x  reduce
    --  z  ----->  y
    --
    it('should reduce xz', function ()
      local board = board:new()
      board:put(1, 11, x_gate:new())
      board:put(1, 12, quantum_gate:z())

      board:reduce()

      return board:gate_at(1, 11)._reduce_to == "i",
             board:gate_at(1, 12)._reduce_to == "y"
    end)

    --  s  reduce
    --  s  ----->  z
    --
    it('should reduce ss', function ()
      local board = board:new()
      board:put(1, 11, quantum_gate:s())
      board:put(1, 12, quantum_gate:s())

      board:reduce()

      return board:gate_at(1, 11)._reduce_to == "i",
             board:gate_at(1, 12)._reduce_to == "z"
    end)

    --  t  reduce
    --  t  ----->  s
    --
    it('should reduce tt', function ()
      local board = board:new()
      board:put(1, 11, quantum_gate:t())
      board:put(1, 12, quantum_gate:t())

      board:reduce()

      return board:gate_at(1, 11)._reduce_to == "i",
             board:gate_at(1, 12)._reduce_to == "s"
    end)

    --  s-s  reduce
    --  s-s  ----->  i-i
    --
    it('should reduce swap pairs in the same columns', function ()
      local board = board:new()
      board:put(1, 11, quantum_gate:swap(3))
      board:put(3, 11, quantum_gate:swap(1))
      board:put(1, 12, quantum_gate:swap(3))
      board:put(3, 12, quantum_gate:swap(1))

      board:reduce()

      return board:gate_at(1, 11)._reduce_to == "i",
             board:gate_at(3, 11)._reduce_to == "i",
             board:gate_at(1, 12)._reduce_to == "i",
             board:gate_at(3, 12)._reduce_to == "i"
    end)

    --  h
    --  x  reduce
    --  h  ----->  z
    --
    it('should reduce hxh', function ()
      local board = board:new()
      board:put(1, 10, h_gate:new())
      board:put(1, 11, x_gate:new())
      board:put(1, 12, h_gate:new())

      board:reduce()

      return board:gate_at(1, 10)._reduce_to == "i",
             board:gate_at(1, 11)._reduce_to == "i",
             board:gate_at(1, 12)._reduce_to == "z"
    end)

    --  h
    --  z  reduce
    --  h  ----->  x
    --
    it('should reduce hzh', function ()
      local board = board:new()
      board:put(1, 10, h_gate:new())
      board:put(1, 11, quantum_gate:z())
      board:put(1, 12, h_gate:new())

      board:reduce()

      return board:gate_at(1, 10)._reduce_to == "i",
             board:gate_at(1, 11)._reduce_to == "i",
             board:gate_at(1, 12)._reduce_to == "x"
    end)

    --  s
    --  z  reduce
    --  s  ----->  z
    --
    it('should reduce szs', function ()
      local board = board:new()
      board:put(1, 10, quantum_gate:s())
      board:put(1, 11, quantum_gate:z())
      board:put(1, 12, quantum_gate:s())

      board:reduce()

      return board:gate_at(1, 10)._reduce_to == "i",
             board:gate_at(1, 11)._reduce_to == "i",
             board:gate_at(1, 12)._reduce_to == "z"
    end)

    --  c-x  reduce
    --  c-x  ----->  i i
    --
    it('should reduce cnot x2', function ()
      local board = board:new()
      board:put(1, 11, quantum_gate:control(3))
      board:put(3, 11, x_gate:new(1))
      board:put(1, 12, quantum_gate:control(3))
      board:put(3, 12, x_gate:new(1))

      board:reduce()

      return board:gate_at(1, 11)._reduce_to == "i", board:gate_at(3, 11)._reduce_to == "i",      
             board:gate_at(1, 12)._reduce_to == "i", board:gate_at(3, 12)._reduce_to == "i"
    end)

    --  x-c  reduce
    --  x-c  ----->  i i
    --
    it('should reduce cnot x2', function ()
      local board = board:new()
      board:put(1, 11, x_gate:new(3))
      board:put(3, 11, quantum_gate:control(1))
      board:put(1, 12, x_gate:new(3))
      board:put(3, 12, quantum_gate:control(1))

      board:reduce()

      return board:gate_at(1, 11)._reduce_to == "i", board:gate_at(3, 11)._reduce_to == "i",      
             board:gate_at(1, 12)._reduce_to == "i", board:gate_at(3, 12)._reduce_to == "i"
    end)    

    --  c-x
    --  x-c  reduce
    --  c-x  ----->  s-s
    --
    it('should reduce cnotx3', function ()
      local board = board:new()
      board:put(1, 10, quantum_gate:control(3))
      board:put(3, 10, x_gate:new(1))
      board:put(1, 11, x_gate:new(3))
      board:put(3, 11, quantum_gate:control(1))
      board:put(1, 12, quantum_gate:control(3))
      board:put(3, 12, x_gate:new(1))

      board:reduce()

      return board:gate_at(1, 10)._reduce_to == "i", board:gate_at(3, 10)._reduce_to == "i",      
             board:gate_at(1, 11)._reduce_to == "i", board:gate_at(3, 11)._reduce_to == "i",
             board:gate_at(1, 12)._reduce_to == "swap", board:gate_at(3, 12)._reduce_to == "swap"
    end)

    -- h h  reduce
    -- c-x  ----->
    -- h h          x-c   
    it('should reduce hh cx hh', function ()
      local board = board:new()
      board:put(1, 10, h_gate:new())
      board:put(3, 10, h_gate:new())
      board:put(1, 11, quantum_gate:control(3))
      board:put(3, 11, x_gate:new(1))
      board:put(1, 12, h_gate:new())
      board:put(3, 12, h_gate:new())

      board:reduce()

      return board:gate_at(1, 10)._reduce_to == "i", board:gate_at(3, 10)._reduce_to == "i",
             board:gate_at(1, 11)._reduce_to == "i", board:gate_at(3, 11)._reduce_to == "i",
             board:gate_at(1, 12)._reduce_to == "x", board:gate_at(3, 12)._reduce_to == "control"
    end)                   

    -- h h  reduce
    -- x-c  ----->
    -- h h          c-x
    it('should reduce hh xc hh', function ()
      local board = board:new()
      board:put(1, 10, h_gate:new())
      board:put(3, 10, h_gate:new())
      board:put(1, 11, x_gate:new(3))
      board:put(3, 11, quantum_gate:control(1))
      board:put(1, 12, h_gate:new())
      board:put(3, 12, h_gate:new())

      board:reduce()

      return board:gate_at(1, 10)._reduce_to == "i", board:gate_at(3, 10)._reduce_to == "i",
             board:gate_at(1, 11)._reduce_to == "i", board:gate_at(3, 11)._reduce_to == "i",
             board:gate_at(1, 12)._reduce_to == "control", board:gate_at(3, 12)._reduce_to == "x"
    end)        
  end)

  desc('drop_gates', function ()
    --  x  drop_gates
    --     --------->  x
    --  _              _
    --
    it('should drop gates', function ()
      local board = board:new()
      board:put(1, 10, x_gate:new())

      board:drop_gates()

      return board:gate_at(1, 12):is_x()
    end)

    --     drop_gates
    --  x  --------->  x
    --  _              _
    --
    it('should stop dropping gate when it reaches the ground', function ()
      local board = board:new()
      board:put(1, board.rows, x_gate:new())

      board:drop_gates()

      return board:gate_at(1, board.rows):is_x()
    end)

    --  x    drop_gates  
    --       --------->  x
    -- c-x              c-x
    it('should drop gate until it stops at cnot', function ()
      local board = board:new()
      board:put(2, 1, x_gate:new())
      board:put(1, board.rows, quantum_gate:control(3))
      board:put(3, board.rows, x_gate:new(1))

      board:drop_gates()

      return board:gate_at(2, board.rows - 1):is_x()
    end)

    --  x    drop_gates  
    --       --------->  x
    -- s-s              s-s
    it('should drop gate until it stops at swap', function ()
      local board = board:new()
      board:put(2, 1, x_gate:new())
      board:put(1, board.rows, quantum_gate:swap(3))
      board:put(3, board.rows, quantum_gate:swap(1))

      board:drop_gates()

      return board:gate_at(2, board.rows - 1):is_x()
    end)

    -- c-x  drop_gates
    --      --------->  c-x
    -- _x_              _x_
    it('should drop cnot pair until it stops at another gate', function ()
      local board = board:new()
      board:put(1, 1, quantum_gate:control(3))
      board:put(3, 1, x_gate:new(1))
      board:put(2, board.rows, x_gate:new())

      board:drop_gates()

      return board:gate_at(1, board.rows - 1):is_control(),
             board:gate_at(3, board.rows - 1):is_cnot_x()
    end)

    -- s-s  drop_gates
    --      --------->  s-s
    -- _x_              _x_
    it('should drop swap pair until it stops at another gate', function ()
      local board = board:new()
      board:put(1, 1, quantum_gate:swap(3))
      board:put(3, 1, quantum_gate:swap(1))
      board:put(2, board.rows, x_gate:new())

      board:drop_gates()

      return board:gate_at(1, board.rows - 1):is_swap(),
             board:gate_at(3, board.rows - 1):is_swap()
    end)
  end)  
end)
