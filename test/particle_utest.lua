require("engine/test/bustedhelper")
require("lib/effect_set")

describe('particle', function()
  before_each(function()
    for i = 1, 100 do
      particles:update_all()
    end
  end)

  describe('create', function()
    it("creates a particle", function()
      particles:_create(1, 1, 1, 1, 7, 5, 1, 1, 1, 1, 10)
      particles:_create(2, 2, 2, 2, 8, 11, 1, 1, 1, 1, 20)

      assert.are_equal(2, #particles.all)

      assert.are_equal(1, particles.all[1]._x)
      assert.are_equal(1, particles.all[1]._y)
      assert.are_equal(1, particles.all[1]._radius)
      assert.are_equal(colors["white"], particles.all[1]._color)
      assert.are_equal(colors["dark_gray"], particles.all[1]._color_fade)
      assert.are_equal(0, particles.all[1]._tick)

      assert.are_equal(2, particles.all[2]._x)
      assert.are_equal(2, particles.all[2]._y)
      assert.are_equal(2, particles.all[2]._radius)
      assert.are_equal(colors["red"], particles.all[2]._color)
      assert.are_equal(colors["green"], particles.all[2]._color_fade)
      assert.are_equal(0, particles.all[2]._tick)
    end)
  end)

  describe('update', function()
    it("updates all partciles", function()
      particles:_create(1, 1, 1, 1, 7, 5, 1, 1, 1, 1, 20)

      assert.are_equal(1, #particles.all)

      particles:update_all()

      assert.are_equal(1, particles.all[1]._tick)
    end)
  end)

  describe('render', function()
    it("renders all particles", function()
      particles:_create(1, 1, 1, 1, 7, 5, 1, 1, 1, 1, 20)

      assert.has_no.errors(function()
        particles:render_all()
      end)
    end)
  end)
end)
