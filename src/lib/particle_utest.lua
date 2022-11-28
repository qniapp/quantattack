require("engine/test/bustedhelper")
local particle = require("lib/particle")

describe('particle #solo', function()
  before_each(function()
    for i = 1, 100 do
      particle:update()
    end
  end)

  describe('create', function()
    it("creates a particle", function()
      particle:create(1, 1, 1, 1, 7, 5, 1, 1, 1, 1, 10)
      particle:create(2, 2, 2, 2, 8, 11, 1, 1, 1, 1, 20)

      assert.are_equal(2, #particle.all)

      assert.are_equal(1, particle.all[1]._x)
      assert.are_equal(1, particle.all[1]._y)
      assert.are_equal(1, particle.all[1]._radius)
      assert.are_equal(colors["white"], particle.all[1]._color)
      assert.are_equal(colors["dark_gray"], particle.all[1]._color_fade)
      assert.are_equal(0, particle.all[1]._tick)

      assert.are_equal(2, particle.all[2]._x)
      assert.are_equal(2, particle.all[2]._y)
      assert.are_equal(2, particle.all[2]._radius)
      assert.are_equal(colors["red"], particle.all[2]._color)
      assert.are_equal(colors["green"], particle.all[2]._color_fade)
      assert.are_equal(0, particle.all[2]._tick)
    end)
  end)

  describe('update', function()
    it("updates all partciles", function()
      particle:create(1, 1, 1, 1, 7, 5, 1, 1, 1, 1, 20)

      assert.are_equal(1, #particle.all)

      particle:update()

      assert.are_equal(1, particle.all[1]._tick)
    end)
  end)

  describe('render', function()
    it("renders all particles", function()
      particle:create(1, 1, 1, 1, 7, 5, 1, 1, 1, 1, 20)

      assert.has_no.errors(function()
        particle:render_all()
      end)
    end)
  end)
end)
