require("engine/test/bustedhelper")
require("board")
require("gate")

describe('gate', function()
  describe('render', function()
    it('should render without errors', function()
      local board = create_board()
      local gate = h_gate()

      board:put(1, 1, gate)

      assert.has_no.errors(function() gate:render(board) end)
    end)
  end)

  describe('swap_with_left', function()
    local gate

    before_each(function()
      gate = h_gate()
    end)

    it('should swap with the left gate without errors', function()
      assert.has_no.errors(function() gate:swap_with_left() end)
    end)

    it('should transition its state to swapping', function()
      gate:swap_with_left()

      assert.is_true(gate:is_swapping())
    end)
  end)

  describe('swap_with_right', function()
    local gate

    before_each(function()
      gate = h_gate()
    end)

    it('should swap with the right gate without errors', function()
      assert.has_no.errors(function() gate:swap_with_right() end)
    end)

    it('should transition its state to swapping', function()
      gate:swap_with_right()

      assert.is_true(gate:is_swapping())
    end)
  end)

  describe('drop', function()
    local gate

    before_each(function()
      gate = h_gate()
    end)

    it('should drop the gate without errors', function()
      assert.has_no.errors(function() gate:fall() end)
    end)

    it('should transition its state to falling', function()
      gate:fall()

      assert.is_true(gate:is_falling())
    end)
  end)

  it('should replace with other gate', function()
    local gate = h_gate()
    local other_gate = x_gate()

    assert.has_no.errors(function() gate:replace_with(other_gate) end)
  end)
end)
