require("engine/test/bustedhelper")

local cursor_class = require("lib/cursor")

describe('cursor', function()
  local cursor

  before_each(function()
    cursor = cursor_class()
  end)

  describe('constructor', function()
    it('should be placed at x = 3, y = 6 by default', function()
      assert.are_equal(3, cursor.x)
      assert.are_equal(11, cursor.y)
    end)
  end)

  describe('move_left', function()
    it("should move left", function()
      cursor:move_left()

      assert.are_equal(2, cursor.x)
      assert.are_equal(11, cursor.y)
    end)

    it("should not move any further to the left when reaching the left edge", function()
      cursor:move_left() -- x = 2
      cursor:move_left() -- x = 1

      cursor:move_left()

      assert.are_equal(1, cursor.x)
      assert.are_equal(11, cursor.y)
    end)
  end)

  describe('move_right', function()
    it("should move right", function()
      cursor:move_right(6)

      assert.are_equal(4, cursor.x)
      assert.are_equal(11, cursor.y)
    end)

    it("should not move any further to the right when reaching the right edge", function()
      cursor:move_right(6) -- x = 4
      cursor:move_right(6) -- x = 5

      cursor:move_right(6)

      assert.are_equal(5, cursor.x)
      assert.are_equal(11, cursor.y)
    end)
  end)

  describe('move_up', function()
    it("should move up", function()
      cursor:move_up()

      assert.are_equal(3, cursor.x)
      assert.are_equal(10, cursor.y)
    end)

    it("should not move any upper when reaching the dead line", function()
      cursor:move_up() -- y = 10
      cursor:move_up() -- y = 9
      cursor:move_up() -- y = 8
      cursor:move_up() -- y = 7

      cursor:move_up()

      assert.are_equal(3, cursor.x)
      assert.are_equal(7, cursor.y)
    end)
  end)

  describe('move_down', function()
    it("should move down", function()
      cursor:move_down(17)

      assert.are_equal(3, cursor.x)
      assert.are_equal(12, cursor.y)
    end)

    it("should not move any further down when reaching the bottom", function()
      cursor:move_down(17) -- y = 7
      cursor:move_down(17) -- y = 8
      cursor:move_down(17) -- y = 9
      cursor:move_down(17) -- y = 10
      cursor:move_down(17) -- y = 11
      cursor:move_down(17) -- y = 12
      cursor:move_down(17) -- y = 13
      cursor:move_down(17) -- y = 14
      cursor:move_down(17) -- y = 15
      cursor:move_down(17) -- y = 16
      cursor:move_down(17) -- y = 17

      cursor:move_down(17)

      assert.are_equal(3, cursor.x)
      assert.are_equal(17, cursor.y)
    end)
  end)

  describe('update', function()
    it("should increment its tick", function()
      local tick = cursor._tick

      cursor:update()

      assert.are_equal(tick + 1, cursor._tick)
    end)
  end)
end)
