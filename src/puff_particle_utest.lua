require("engine/test/bustedhelper")

local puff_particle = require("puff_particle")

describe('puff_particle', function()
  describe('constructor', function()
    it("x, y, color を指定してパーティクルを作ることができる", function()
      assert.has_no.errors(function()
        puff_particle(1, 1, 1)
      end)
    end)
  end)

  describe('.update', function()
    it("すべてのパーティクル状態を更新する", function()
      puff_particle(1, 1, 1)

      assert.has_no.errors(function()
        puff_particle.update()
      end)
    end)
  end)

  describe('.render', function()
    it("すべてのパーティクルを描画する", function()
      puff_particle(1, 1, 1)

      assert.has_no.errors(function()
        puff_particle.render()
      end)
    end)
  end)
end)
