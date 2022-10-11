require("engine/test/bustedhelper")

local gate = require("gate")
local h_gate = require("h_gate")
local x_gate = require("x_gate")

describe('gate', function()
  it('should update', function()
    local gate = h_gate()

    assert.has_no.errors(function() gate:update() end)
  end)

  describe('render', function()
    it('should render without errors', function()
      local gate = h_gate()

      assert.has_no.errors(function() gate:render(0, 0) end)
    end)
  end)

  describe('swap_with_left', function()
    local gate

    before_each(function()
      gate = h_gate()
    end)

    it('should swap with the left gate without errors', function()
      assert.has_no.errors(function() gate:swap_with_left(1) end)
    end)

    it('should transition its state to swapping', function()
      gate:swap_with_left(1)

      assert.is_true(gate:is_swapping())
    end)
  end)

  describe('swap_with_right', function()
    local gate

    before_each(function()
      gate = h_gate()
    end)

    it('should swap with the right gate without errors', function()
      assert.has_no.errors(function() gate:swap_with_right(2) end)
    end)

    it('should transition its state to swapping', function()
      gate:swap_with_right(2)

      assert.is_true(gate:is_swapping())
    end)
  end)

  describe('drop', function()
    local gate

    before_each(function()
      gate = h_gate()
    end)

    it('should drop the gate without errors', function()
      assert.has_no.errors(function() gate:drop(1, 1) end)
    end)

    it('should transition its state to dropping', function()
      gate:drop(1, 1)

      assert.is_true(gate:is_dropping())
    end)

    it('should throw an error if start_y is out of range', function()
      assert.has_error(function() gate:drop(1, 0) end)
      assert.has_error(function() gate:drop(1, 13) end)
    end)
  end)

  it('should replace with other gate', function()
    local gate = h_gate()
    local other_gate = x_gate()

    assert.has_no.errors(function() gate:replace_with(other_gate) end)
  end)
end)
