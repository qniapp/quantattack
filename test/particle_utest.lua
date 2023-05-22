require("engine/test/bustedhelper")
require("lib/helpers")
require("lib/effects")
require("lib/board")

describe('particle', function()
  before_each(function()
    for i = 1, 100 do
      particles:update_all()
    end
  end)

  describe('create', function()
    it("creates a particle", function()
      particles:create({ 1, 1 }, "1,1,7,5,1,1,1,1,10")
      particles:create({ 2, 2 }, "2,2,8,11,1,1,1,1,20")

      assert.are.equal(2, #particles.all)

      assert.are.equal(1, particles.all[1]._x)
      assert.are.equal(1, particles.all[1]._y)
      assert.are.equal(1, tonum(particles.all[1]._radius))
      assert.are.equal(colors["white"], tonum(particles.all[1]._color))
      assert.are.equal(colors["dark_gray"], tonum(particles.all[1]._color_fade))
      assert.are.equal(0, particles.all[1]._tick)

      assert.are.equal(2, particles.all[2]._x)
      assert.are.equal(2, particles.all[2]._y)
      assert.are.equal(2, tonum(particles.all[2]._radius))
      assert.are.equal(colors["red"], tonum(particles.all[2]._color))
      assert.are.equal(colors["green"], tonum(particles.all[2]._color_fade))
      assert.are.equal(0, particles.all[2]._tick)
    end)
  end)

  describe('update', function()
    it("updates all partciles", function()
      particles:create({ 1, 1 }, "1,1,7,5,1,1,1,1,20")

      assert.are.equal(1, #particles.all)

      particles:update_all()

      assert.are.equal(1, particles.all[1]._tick)
    end)
  end)

  describe('render', function()
    it("renders all particles", function()
      particles:create({ 1, 1 }, "1,1,7,5,1,1,1,1,20")

      assert.has_no.errors(function()
        particles:render_all()
      end)
    end)
  end)
end)
