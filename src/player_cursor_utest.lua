require("engine/test/bustedhelper")

local player_cursor_class = require("player_cursor")
local board_class = require("board")

describe('player_cursor', function()
  local player_cursor

  before_each(function()
    player_cursor = player_cursor_class()
  end)

  describe('constructor', function()
    it('should be placed at x = 3, y = 6 by default', function()
      assert.are_equal(3, player_cursor.x)
      assert.are_equal(6, player_cursor.y)
    end)
  end)

  describe('move_left', function()
    it("should move left", function()
      player_cursor:move_left()

      assert.are_equal(2, player_cursor.x)
      assert.are_equal(6, player_cursor.y)
    end)
  end)

  describe('move_right', function()
    it("should move right", function()
      player_cursor:move_right()

      assert.are_equal(4, player_cursor.x)
      assert.are_equal(6, player_cursor.y)
    end)
  end)

  describe('move_up', function()
    it("should move up", function()
      player_cursor:move_up()

      assert.are_equal(3, player_cursor.x)
      assert.are_equal(5, player_cursor.y)
    end)
  end)

  describe('move_down', function()
    it("should move down", function()
      player_cursor:move_down()

      assert.are_equal(3, player_cursor.x)
      assert.are_equal(7, player_cursor.y)
    end)
  end)

  describe('update', function()
    it("should update", function()
      local tick = player_cursor._tick

      player_cursor:update()

      assert.are_equal(tick + 1, player_cursor._tick)
    end)
  end)

  describe("render", function()
    it("should render without errors", function()
      assert.has_no.errors(function() player_cursor:render(board_class()) end)
    end)
  end)
end)
