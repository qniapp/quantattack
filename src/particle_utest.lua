require("engine/test/bustedhelper")
require("particle")

describe('particle', function()
  before_each(function()
    for i = 1, 100 do
      update_particles()
    end
  end)

  describe('create', function()
    it("creates a particle", function()
      create_particle(1, 1, 1, 1, 7, 5, 1, 1, 1, 1, 10)
      create_particle(2, 2, 2, 2, 8, 11, 1, 1, 1, 1, 20)

      assert.are_equal(2, #all_particles)

      assert.are_equal(1, all_particles[1]._x)
      assert.are_equal(1, all_particles[1]._y)
      assert.are_equal(1, all_particles[1]._radius)
      assert.are_equal(colors["white"], all_particles[1]._color)
      assert.are_equal(colors["dark_gray"], all_particles[1]._color_fade)
      assert.are_equal(0, all_particles[1]._tick)

      assert.are_equal(2, all_particles[2]._x)
      assert.are_equal(2, all_particles[2]._y)
      assert.are_equal(2, all_particles[2]._radius)
      assert.are_equal(colors["red"], all_particles[2]._color)
      assert.are_equal(colors["green"], all_particles[2]._color_fade)
      assert.are_equal(0, all_particles[2]._tick)
    end)
  end)

  describe('update', function()
    it("updates all partciles", function()
      create_particle(1, 1, 1, 1, 7, 5, 1, 1, 1, 1, 20)

      assert.are_equal(1, #all_particles)

      update_particles()

      assert.are_equal(1, all_particles[1]._tick)
    end)
  end)

  describe('render', function()
    it("renders all particles", function()
      create_particle(1, 1, 1, 1, 7, 5, 1, 1, 1, 1, 20)

      assert.has_no.errors(function()
        render_particles()
      end)
    end)
  end)
end)
