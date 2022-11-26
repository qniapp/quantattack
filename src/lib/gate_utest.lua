require("engine/test/bustedhelper")
require("lib/test_helper")
require("lib/board")

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
      assert.has_no.errors(function() gate("!") end)
    end)

    it("type が正しくない場合エラー", function()
      ---@diagnostic disable-next-line: param-type-mismatch
      assert.error(function() gate("p") end)
    end)
  end)

  describe('span', function()
    it("幅はデフォルトで 1", function()
      assert.are_equal(1, gate("i").span)
    end)

    it("幅 (span) を指定", function()
      assert.are_equal(3, gate("g", 3).span)
    end)

    it('type が "g" 以外の場合は幅を 1 以外に指定するとエラー', function()
      assert.error(function() gate("i", 2) end)
      assert.error(function() gate("h", 2) end)
      assert.error(function() gate("x", 2) end)
      assert.error(function() gate("y", 2) end)
      assert.error(function() gate("y", 2) end)
      assert.error(function() gate("z", 2) end)
      assert.error(function() gate("s", 2) end)
      assert.error(function() gate("t", 2) end)
      assert.error(function() gate("control", 2) end)
      assert.error(function() gate("cnot_x", 2) end)
      assert.error(function() gate("swap", 2) end)
      assert.error(function() gate("!", 2) end)
    end)

    it("幅は 1 未満に指定できない", function()
      ---@diagnostic disable-next-line: param-type-mismatch
      assert.error(function() gate("g", 0) end)
    end)

    it("幅は 7 以上に指定できない", function()
      ---@diagnostic disable-next-line: param-type-mismatch
      assert.error(function() gate("g", 7) end)
    end)
  end)

  describe('height', function()
    it("高さはデフォルトで 1", function()
      assert.are_equal(1, gate("i").height)
    end)

    it("高さ (height) を指定", function()
      assert.are_equal(4, gate("g", 1, 4).height)
    end)

    it('type が "g" 以外の場合は高さを 1 以外に指定するとエラー', function()
      assert.error(function() gate("i", 1, 2) end)
      assert.error(function() gate("h", 1, 2) end)
      assert.error(function() gate("x", 1, 2) end)
      assert.error(function() gate("y", 1, 2) end)
      assert.error(function() gate("y", 1, 2) end)
      assert.error(function() gate("z", 1, 2) end)
      assert.error(function() gate("s", 1, 2) end)
      assert.error(function() gate("t", 1, 2) end)
      assert.error(function() gate("control", 1, 2) end)
      assert.error(function() gate("cnot_x", 1, 2) end)
      assert.error(function() gate("swap", 1, 2) end)
      assert.error(function() gate("!", 1, 2) end)
    end)

    it("高さは 1 未満に指定できない", function()
      assert.error(function() gate("g", 1, 0) end)
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

  describe('swap_with_left', function()
    local gate

    before_each(function()
      local board = create_board()
      gate = h_gate()

      board:put(2, 1, gate)
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
      local board = create_board()
      gate = h_gate()

      board:put(1, 1, gate)
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
