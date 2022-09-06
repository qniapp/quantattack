-- test helpers
test_board = nil

function put(x, y, gate)
  test_board:put(x, y, gate)
end

function assert_reduction(x, y, expected)
  return test_board:gate_at(x, y)._reduce_to._type == expected
end

function reduce()
  test_board:reduce()
end

function drop()
  test_board:drop_gates()
end

test('board', function(desc,it)
  desc('reduce', function ()
    --
    --  h  reduce
    --  h  ----->  i
    --
    it('should reduce hh', function ()
      test_board = board:new()
      put(1, 11, h_gate:new())
      put(1, 12, h_gate:new())

      reduce()

      return assert_reduction(1, 11, 'i'),
             assert_reduction(1, 12, 'i')
    end)

    --  x  reduce
    --  x  ----->  i
    --
    it('should reduce xx', function ()
      test_board = board:new()
      put(1, 11, x_gate:new())
      put(1, 12, x_gate:new())

      reduce()

      return assert_reduction(1, 11, 'i'),
             assert_reduction(1, 12, 'i')
    end)

    --  y  reduce
    --  y  ----->  i
    --
    it('should reduce yy', function ()
      test_board = board:new()
      put(1, 11, y_gate:new())
      put(1, 12, y_gate:new())

      reduce()

      return assert_reduction(1, 11, 'i'),
             assert_reduction(1, 12, 'i')
    end)

    --  z  reduce
    --  z  ----->  i
    --
    it('should reduce zz', function ()
      test_board = board:new()
      put(1, 11, z_gate:new())
      put(1, 12, z_gate:new())

      reduce()

      return assert_reduction(1, 11, 'i'),
             assert_reduction(1, 12, 'i')
    end)

    --  z  reduce
    --  x  ----->  y
    --
    it('should reduce zx', function ()
      test_board = board:new()
      put(1, 11, z_gate:new())
      put(1, 12, x_gate:new())

      reduce()

      return assert_reduction(1, 11, 'i'),
             assert_reduction(1, 12, 'y')
    end)

    --  x  reduce
    --  z  ----->  y
    --
    it('should reduce xz', function ()
      test_board = board:new()
      put(1, 11, x_gate:new())
      put(1, 12, z_gate:new())

      reduce()

      return assert_reduction(1, 11, 'i'),
             assert_reduction(1, 12, 'y')
    end)

    --  s  reduce
    --  s  ----->  z
    --
    it('should reduce ss', function ()
      test_board = board:new()
      put(1, 11, s_gate:new())
      put(1, 12, s_gate:new())

      reduce()

      return assert_reduction(1, 11, 'i'),
             assert_reduction(1, 12, 'z')
    end)

    --  t  reduce
    --  t  ----->  s
    --
    it('should reduce tt', function ()
      test_board = board:new()
      put(1, 11, t_gate:new())
      put(1, 12, t_gate:new())

      reduce()

      return assert_reduction(1, 11, 'i'),
             assert_reduction(1, 12, 's')
    end)

    --  s-s  reduce
    --  s-s  ----->  i-i
    --
    it('should reduce swap pairs in the same columns', function ()
      test_board = board:new()
      put(1, 11, swap_gate:new(3))
      put(3, 11, swap_gate:new(1))
      put(1, 12, swap_gate:new(3))
      put(3, 12, swap_gate:new(1))

      reduce()

      return assert_reduction(1, 11, 'i'),
             assert_reduction(3, 11, 'i'),
             assert_reduction(1, 12, 'i'),
             assert_reduction(3, 12, 'i')
    end)

    --  h
    --  x  reduce
    --  h  ----->  z
    --
    it('should reduce hxh', function ()
      test_board = board:new()
      put(1, 10, h_gate:new())
      put(1, 11, x_gate:new())
      put(1, 12, h_gate:new())

      reduce()

      return assert_reduction(1, 10, 'i'),
             assert_reduction(1, 11, 'i'),
             assert_reduction(1, 12, 'z')
    end)

    --  h
    --  z  reduce
    --  h  ----->  x
    --
    it('should reduce hzh', function ()
      test_board = board:new()
      put(1, 10, h_gate:new())
      put(1, 11, z_gate:new())
      put(1, 12, h_gate:new())

      reduce()

      return assert_reduction(1, 10, 'i'),
             assert_reduction(1, 11, 'i'),
             assert_reduction(1, 12, 'x')
    end)

    --  s
    --  z  reduce
    --  s  ----->  z
    --
    it('should reduce szs', function ()
      test_board = board:new()
      put(1, 10, s_gate:new())
      put(1, 11, z_gate:new())
      put(1, 12, s_gate:new())

      reduce()

      return assert_reduction(1, 10, 'i'),
             assert_reduction(1, 11, 'i'),
             assert_reduction(1, 12, 'z')
    end)

    --  c-x  reduce
    --  c-x  ----->  i i
    --
    it('should reduce cnot x2', function ()
      test_board = board:new()
      put(1, 11, control_gate:new(3))
      put(3, 11, cnot_x_gate:new(1))
      put(1, 12, control_gate:new(3))
      put(3, 12, cnot_x_gate:new(1))

      reduce()

      return assert_reduction(1, 11, 'i'), assert_reduction(3, 11, 'i'),
             assert_reduction(1, 12, 'i'), assert_reduction(3, 12, 'i')
    end)

    --  c-x
    --  x-c  reduce
    --  c-x  ----->  s-s
    --
    it('should reduce cnotx3', function ()
      test_board = board:new()
      put(1, 10, control_gate:new(3))
      put(3, 10, cnot_x_gate:new(1))
      put(1, 11, cnot_x_gate:new(3))
      put(3, 11, control_gate:new(1))
      put(1, 12, control_gate:new(3))
      put(3, 12, cnot_x_gate:new(1))

      reduce()

      return assert_reduction(1, 10, 'i'), assert_reduction(3, 10, 'i'),
             assert_reduction(1, 11, 'i'), assert_reduction(3, 11, 'i'),
             assert_reduction(1, 12, 'swap'), assert_reduction(3, 12, 'swap')
    end)

    -- h h  reduce
    -- c-x  ----->  x-c
    -- h h             
    it('should reduce hh cx hh', function ()
      test_board = board:new()
      put(1, 10, h_gate:new())
      put(3, 10, h_gate:new())
      put(1, 11, control_gate:new(3))
      put(3, 11, cnot_x_gate:new(1))
      put(1, 12, h_gate:new())
      put(3, 12, h_gate:new())

      reduce()

      return assert_reduction(1, 10, 'i'), assert_reduction(3, 10, 'i'),
             assert_reduction(1, 11, 'cnot_x'), assert_reduction(3, 11, 'control'),
             assert_reduction(1, 12, 'i'), assert_reduction(3, 12, 'i')
    end)

    -- x x  reduce
    -- c-x  ----->  c-x
    -- x               
    it('should reduce xx cx x', function ()
      test_board = board:new()
      put(1, 10, x_gate:new())
      put(3, 10, x_gate:new())
      put(1, 11, control_gate:new(3))
      put(3, 11, cnot_x_gate:new(1))
      put(1, 12, x_gate:new())

      reduce()

      return assert_reduction(1, 10, 'i'), assert_reduction(3, 10, 'i'),
             assert_reduction(1, 11, 'control'), assert_reduction(3, 11, 'cnot_x'),
             assert_reduction(1, 12, 'i')
    end)  

    -- z z  reduce
    -- c-x  ----->  c-x
    --   z              
    it('should reduce zz cx z', function ()
      test_board = board:new()
      put(1, 10, z_gate:new())
      put(3, 10, z_gate:new())
      put(1, 11, control_gate:new(3))
      put(3, 11, cnot_x_gate:new(1))
      put(3, 12, z_gate:new())

      reduce()

      return assert_reduction(1, 10, 'i'), assert_reduction(3, 10, 'i'),
             assert_reduction(1, 11, 'control'), assert_reduction(3, 11, 'cnot_x'),
             assert_reduction(3, 12, 'i')
    end)

    -- x    reduce
    -- x-c  ----->  x-c
    -- x             
    it('should reduce x xc x', function ()
      test_board = board:new()
      put(1, 10, x_gate:new())
      put(1, 11, cnot_x_gate:new(3))
      put(3, 11, control_gate:new(1))
      put(1, 12, x_gate:new())

      reduce()

      return assert_reduction(1, 10, 'i'),
             assert_reduction(1, 11, 'cnot_x'), assert_reduction(3, 11, 'control'),
             assert_reduction(1, 12, 'i')
    end)  

    -- z    reduce
    -- c-x  ----->  c-x
    -- z             
    it('should reduce z cx z', function ()
      test_board = board:new()
      put(1, 10, z_gate:new())
      put(1, 11, control_gate:new(3))
      put(3, 11, cnot_x_gate:new(1))
      put(1, 12, z_gate:new())

      reduce()

      return assert_reduction(1, 10, 'i'),
             assert_reduction(1, 11, 'control'), assert_reduction(3, 11, 'cnot_x'),
             assert_reduction(1, 12, 'i')
    end)       
  end)

  desc('drop_gates', function ()
    --  x  drop_gates
    --     --------->  x
    --  _              _
    --
    it('should drop gates', function ()
      test_board = board:new()
      put(1, 10, x_gate:new())

      drop()

      return is_x(test_board:gate_at(1, 12))
    end)

    --     drop_gates
    --  x  --------->  x
    --  _              _
    --
    it('should stop dropping gate when it reaches the ground', function ()
      test_board = board:new()
      put(1, test_board.rows, x_gate:new())

      drop()

      return is_x(test_board:gate_at(1, test_board.rows))
    end)

    --  x    drop_gates  
    --       --------->  x
    -- c-x              c-x
    it('should drop gate until it stops at cnot', function ()
      test_board = board:new()
      put(2, 1, x_gate:new())
      put(1, test_board.rows, control_gate:new(3))
      put(3, test_board.rows, cnot_x_gate:new(1))

      drop()

      return is_x(test_board:gate_at(2, test_board.rows - 1))
    end)

    --  x    drop_gates  
    --       --------->  x
    -- s-s              s-s
    it('should drop gate until it stops at swap', function ()
      test_board = board:new()
      put(2, 1, x_gate:new())
      put(1, test_board.rows, swap_gate:new(3))
      put(3, test_board.rows, swap_gate:new(1))

      drop()

      return is_x(test_board:gate_at(2, test_board.rows - 1))
    end)

    --  x   drop_gates  
    --      --------->   x
    -- ggg              ggg
    it('should drop gate until it stops at garbage unitary', function ()
      test_board = board:new()
      put(2, 1, x_gate:new())
      put(1, test_board.rows, garbage_unitary:new(3))

      drop()

      return is_x(test_board:gate_at(2, test_board.rows - 1))
    end)

    -- c-x  drop_gates
    --      --------->  c-x
    -- _x_              _x_
    it('should drop cnot pair until it stops at another gate', function ()
      test_board = board:new()
      put(1, 1, control_gate:new(3))
      put(3, 1, cnot_x_gate:new(1))
      put(2, test_board.rows, x_gate:new())

      drop()

      return is_control(test_board:gate_at(1, test_board.rows - 1)),
             is_cnot_x(test_board:gate_at(3, test_board.rows - 1))
    end)

    -- s-s  drop_gates
    --      --------->  s-s
    -- _x_              _x_
    it('should drop swap pair until it stops at another gate', function ()
      test_board = board:new()
      put(1, 1, swap_gate:new(3))
      put(3, 1, swap_gate:new(1))
      put(2, test_board.rows, x_gate:new())

      drop()

      return is_swap(test_board:gate_at(1, test_board.rows - 1)),
             is_swap(test_board:gate_at(3, test_board.rows - 1))
    end)
  end)  
end)
