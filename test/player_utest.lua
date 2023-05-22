require("engine/test/bustedhelper")
require("lib/player")

describe('player', function()
  local player

  before_each(function()
    player = player_class()
  end)

  describe('constructor', function()
    it("creates a player with score = 0", function()
      assert.are.equal(0, player.score)
    end)
  end)

  describe('init', function()
    it("resets score", function()
      player.score = 1 >> 16

      player:init()

      assert.are.equal(0, player.score)
    end)
  end)
end)
