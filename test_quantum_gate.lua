test('quantum_gate', function(desc, it)
  desc('i', function()
    it('should create an id gate', function ()
      local gate = i_gate:new()

      return is_i(gate)
    end)
  end)

  desc('h', function()
    it('should create a hadamard gate', function ()
      local gate = h_gate:new()

      return is_h(gate)
    end)
  end)

  desc('x', function()
    it('should create an x gate', function ()
      local gate = x_gate:new()

      return is_x(gate)
    end)
  end)

  desc('y', function()
    it('should create a y gate', function ()
      local gate = y_gate:new()

      return is_y(gate)
    end)
  end)

  desc('z', function()
    it('should create a z gate', function ()
      local gate = z_gate:new()

      return is_z(gate)
    end)
  end)

  desc('s', function()
    it('should create an s gate', function ()
      local gate = s_gate:new()

      return is_s(gate)
    end)
  end)  

  desc('t', function()
    it('should create a t gate', function ()
      local gate = t_gate:new()

      return is_t(gate)
    end)
  end)

  desc('control', function()
    it('should create a control gate', function ()
      local gate = control_gate:new(1)

      return is_control(gate)
    end)
  end)  

  desc('swap', function()
    it('should create a swap gate', function ()
      local gate = swap_gate:new(1)

      return is_swap(gate)
    end)
  end)
end)