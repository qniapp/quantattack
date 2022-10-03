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

  it('should draw', function()
    local gate = quantum_gate('h')

    assert.has_no.errors(function() gate:draw(0, 0) end)
  end)

  it('should replace with other gate', function()
    local gate = quantum_gate('h')
    local other_gate = quantum_gate('x')

    assert.has_no.errors(function() gate:replace_with(other_gate) end)
  end)

  it('should start swap with right gate', function()
    local gate = quantum_gate('h')

    assert.has_no.errors(function() gate:swap_with_right() end)
  end)

  it('should start swap with left gate', function()
    local gate = quantum_gate('h')

    assert.has_no.errors(function() gate:swap_with_left() end)
  end)
end)
