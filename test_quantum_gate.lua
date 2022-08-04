test('quantum_gate', function(desc, it)
  desc('i', function()
    it('should create an id gate', function ()
      local gate = quantum_gate:i()

      return gate:is_i()
    end)
  end)

  desc('h', function()
    it('should create a hadamard gate', function ()
      local gate = quantum_gate:h()

      return gate:is_h()
    end)
  end)

  desc('x', function()
    it('should create an x gate', function ()
      local gate = quantum_gate:x()

      return gate:is_x()
    end)
  end)

  desc('y', function()
    it('should create a y gate', function ()
      local gate = quantum_gate:y()

      return gate:is_y()
    end)
  end)

  desc('z', function()
    it('should create a z gate', function ()
      local gate = quantum_gate:z()

      return gate:is_z()
    end)
  end)

  desc('s', function()
    it('should create an s gate', function ()
      local gate = quantum_gate:s()

      return gate:is_s()
    end)
  end)  

  desc('t', function()
    it('should create a t gate', function ()
      local gate = quantum_gate:t()

      return gate:is_t()
    end)
  end)

  desc('control', function()
    it('should create a control gate', function ()
      local gate = quantum_gate:control(1)

      return gate:is_control()
    end)
  end)  

  desc('swap', function()
    it('should create a swap gate', function ()
      local gate = quantum_gate:swap(1)

      return gate:is_swap()
    end)
  end)
end)