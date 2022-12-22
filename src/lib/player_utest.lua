require("engine/test/bustedhelper")

local player_class = require("lib/player")

describe('player', function()
  describe('constructor', function()
    it("creates a player with score = 0", function()
      local player = player_class()

      assert.are_equal(0, player.score)
    end)
  end)

  describe('init', function()
    it("resets score", function()
      local player = player_class()
      player.score = 1

      player:_init()

      assert.are_equal(0, player.score)
    end)
  end)
end)
