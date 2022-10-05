require("engine/test/bustedhelper")

local quantum_gate = require("quantum_gate")

describe('quantum_gate', function()
  describe('random_single_gate', function()
    it('should create a random gate', function()
      local gate = quantum_gate.random_single_gate()

      -- TODO: gate.type が { "h", "x", "y", "z", "s", "t" } の中の 1 つになることを assert する
      assert.truthy(gate.type)
    end)
  end)

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

  describe('swap_with_left', function()
    it('should swap with the left gate without errors', function()
      local gate = quantum_gate('h')

      assert.has_no.errors(function() gate:swap_with_left(1) end)
    end)

    it('should transition its state to swapping_with_left', function()
      local gate = quantum_gate('h')

      gate:swap_with_left(1)

      assert.is_true(gate:is_swapping_with_left())
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

    it('should transition its state to swapping_with_right', function()
      local gate = quantum_gate('h')

      gate:swap_with_right(2)

      assert.is_true(gate:is_swapping_with_right())
    end)

    it('should set new_x_after_swap', function()
      local gate = quantum_gate('h')

      gate:swap_with_right(2)

      assert.are.equals(2, gate.new_x_after_swap)
    end)
  end)

  it('should replace with other gate', function()
    local gate = quantum_gate('h')
    local other_gate = quantum_gate('x')

    assert.has_no.errors(function() gate:replace_with(other_gate) end)
  end)
end)
