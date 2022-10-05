require("engine/test/bustedhelper")

local quantum_gate = require("quantum_gate")

describe('quantum_gate', function()
  it('should update', function()
    local gate = quantum_gate('h')

    assert.has_no.errors(function() gate:update() end)
  end)

  describe('render', function()
    it('should render without errors', function()
      local gate = quantum_gate('h')

      assert.has_no.errors(function() gate:render(0, 0) end)
    end)
  end)

  describe('is_swappable', function()
    it('should return true if the gate is idle', function()
      local gate = quantum_gate('h')

      assert.is_true(gate:is_swappable())
    end)

    it('should return true if the state is swap_finished', function()
      local gate = quantum_gate('h')
      gate.state = 'swap_finished'

      assert.is_true(gate:is_swappable())
    end)
  end)

  describe('swap_with_left', function()
    it('should swap with the left gate without errors', function()
      local gate = quantum_gate('h')

      assert.has_no.errors(function() gate:swap_with_left(1) end)
    end)

    it('should transition its state to swapping', function()
      local gate = quantum_gate('h')

      gate:swap_with_left(1)

      assert.is_true(gate:is_swapping())
    end)

    it('should set new_x_after_swap', function()
      local gate = quantum_gate('h')

      gate:swap_with_left(1)

      assert.are.equals(1, gate.new_x_after_swap)
    end)
  end)

  describe('swap_with_right', function()
    it('should swap with the right gate without errors', function()
      local gate = quantum_gate('h')

      assert.has_no.errors(function() gate:swap_with_right(2) end)
    end)

    it('should transition its state to swapping', function()
      local gate = quantum_gate('h')

      gate:swap_with_right(2)

      assert.is_true(gate:is_swapping())
    end)

    it('should set new_x_after_swap', function()
      local gate = quantum_gate('h')

      gate:swap_with_right(2)

      assert.are.equals(2, gate.new_x_after_swap)
    end)
  end)

  describe('drop', function()
    it('should drop the gate without errors', function()
      local gate = quantum_gate('h')

      assert.has_no.errors(function() gate:drop() end)
    end)
  end)

  it('should replace with other gate', function()
    local gate = quantum_gate('h')
    local other_gate = quantum_gate('x')

    assert.has_no.errors(function() gate:replace_with(other_gate) end)
  end)
end)
