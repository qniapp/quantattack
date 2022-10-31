require("engine/test/bustedhelper")
require("player")

describe('player', function()
  describe('constructor', function()
    it("creates a player with steps = 0, score = 0", function()
      local player = create_player()

      assert.are_equal(0, player.steps)
      assert.are_equal(0, player.score)
    end)
  end)

  describe('init', function()
    it("initializes steps = 0, score = 0", function()
      local player = create_player()
      player.steps = 1
      player.score = 1

      player:init()

      assert.are_equal(0, player.steps)
      assert.are_equal(0, player.score)
    end)
  end)
end)
