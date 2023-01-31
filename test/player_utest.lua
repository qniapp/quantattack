require("engine/test/bustedhelper")
require("lib/board")

describe('player', function()
  local player

  before_each(function()
    player = player_class()
  end)

  describe('constructor', function()
    it("creates a player with score = 0", function()
      assert.are_equal(0, player.score)
    end)
  end)

  describe('init', function()
    it("resets score", function()
      player.score = 1

      player:init()

      assert.are_equal(0, player.score)
    end)
  end)
end)
