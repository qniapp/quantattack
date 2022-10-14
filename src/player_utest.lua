require("engine/test/bustedhelper")

local player_class = require("player")

describe('player', function()
  describe('constructor', function()
    it("初期状態は steps = 0, score = 0", function()
      local player = player_class()

      assert.are_equal(0, player.steps)
      assert.are_equal(0, player.score)
    end)
  end)

  describe('init', function()
    it("steps = 0, score = 0 に初期化する", function()
      local player = player_class()
      player.steps = 1
      player.score = 1

      player:init()

      assert.are_equal(0, player.steps)
      assert.are_equal(0, player.score)
    end)
  end)
end)
