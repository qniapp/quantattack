require("engine/test/bustedhelper")
require("qpu")

describe('qpu #solo', function()
  describe('create_qpu', function()
    it("creates a qpu with steps = 0, score = 0", function()
      local qpu = create_qpu()

      assert.are_equal(0, qpu.steps)
      assert.are_equal(0, qpu.score)
    end)
  end)

  describe('init', function()
    it("initializes steps = 0, score = 0", function()
      local qpu = create_qpu()
      qpu.steps = 1
      qpu.score = 1

      qpu:init()

      assert.are_equal(0, qpu.steps)
      assert.are_equal(0, qpu.score)
    end)
  end)
end)
