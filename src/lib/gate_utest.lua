require("engine/test/bustedhelper")
require("lib/test_helper")
require("lib/board")

local gate = require("lib/gate")

describe('gate', function()
  describe('type', function()
    it("type を指定", function()
      local g = gate("i")

      assert.are_equal("i", g.type)
    end)

    it("すべての type のゲートを作る", function()
      assert.has_no.errors(function() gate("i") end)
      assert.has_no.errors(function() gate("h") end)
      assert.has_no.errors(function() gate("x") end)
      assert.has_no.errors(function() gate("y") end)
      assert.has_no.errors(function() gate("z") end)
      assert.has_no.errors(function() gate("s") end)
      assert.has_no.errors(function() gate("t") end)
      assert.has_no.errors(function() gate("control") end)
      assert.has_no.errors(function() gate("cnot_x") end)
      assert.has_no.errors(function() gate("swap") end)
      assert.has_no.errors(function() gate("g") end)
      assert.has_no.errors(function() gate("?") end)
    end)
  end)

  describe('span', function()
    it("幅はデフォルトで 1", function()
      assert.are_equal(1, gate("i").span)
    end)

    it("幅 (span) を指定", function()
      assert.are_equal(3, gate("g", 3).span)
    end)
  end)

  describe('height', function()
    it("高さはデフォルトで 1", function()
      assert.are_equal(1, gate("i").height)
    end)

    it("高さ (height) を指定", function()
      assert.are_equal(4, gate("g", 1, 4).height)
    end)
  end)

  describe('render', function()
    it('should render without errors', function()
      local board = create_board()
      local gate = h_gate()

      board:put(1, 1, gate)

      assert.has_no.errors(function() gate:render(board:screen_x(1), board:screen_y(1)) end)
    end)
  end)

  describe('swap_with("left")', function()
    local gate

    before_each(function()
      local board = create_board()
      gate = h_gate()

      board:put(2, 1, gate)
    end)

    it('should swap with the left gate without errors', function()
      assert.has_no.errors(function() gate:swap_with("left") end)
    end)

    it('should transition its state to swapping', function()
      gate:swap_with("left")

      assert.is_true(gate:is_swapping())
    end)
  end)

  describe('swap_with("right")', function()
    local gate

    before_each(function()
      local board = create_board()
      gate = h_gate()

      board:put(1, 1, gate)
    end)

    it('should swap with the right gate without errors', function()
      assert.has_no.errors(function() gate:swap_with("right") end)
    end)

    it('should transition its state to swapping', function()
      gate:swap_with("right")

      assert.is_true(gate:is_swapping())
    end)
  end)

  describe('drop', function()
    local gate

    before_each(function()
      local board = create_board()
      gate = h_gate()

      board:put(1, 1, gate)
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
    local board = create_board()
    local gate = h_gate()
    local other_gate = x_gate()
    board:put(1, 1, gate)

    gate:replace_with(other_gate)

    assert.are_equal(other_gate, gate.new_gate)
  end)
end)
