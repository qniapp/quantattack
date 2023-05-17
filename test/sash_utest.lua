require("engine/test/bustedhelper")
require("engine/render/color")
require("test/test_helper")
require("lib/helpers")

local sash = require("lib/sash")

describe('sash', function()
  before_each(function ()
    sash.current = nil
  end)

  after_each(function ()
    sash.current = nil
  end)

  describe('current', function()
    it('current は nil', function()
      assert.is_nil(sash.current)
    end)
  end)

  describe('create', function()
    before_each(function()
      sash:create('sash', colors.white, colors.red)
    end)

    describe('current', function ()
      it('current をセット`', function()
        assert.is_not_nil(sash.current)
      end)

      it('text プロパティを持つ', function()
        assert.are.equal('sash', sash.current.text)
      end)

      it('text_color プロパティを持つ', function()
        assert.are.equal(colors.white, sash.current.text_color)
      end)

      it('background_color プロパティを持つ', function()
        assert.are.equal(colors.red, sash.current.background_color)
      end)

      it('文字列がスクリーン外', function()
        assert.are.equal(-16, sash.current.text_x)
      end)

      it('背景なし', function ()
        assert.are.equal(0, sash.current.background_height)
      end)

      it('状態が :slidein', function()
        assert.are.equal(':slidein', sash.current.state)
      end)
    end)
  end)

  describe('update', function()
    it('text_x を更新', function ()
      sash:create('sash', 0, 0)

      sash:update()

      assert.are.equal(-16 + 5, sash.current.text_x)
    end)

    it('何度か update すると中央でストップ', function ()
      sash:create('sash', 0, 0)

      while (sash.current.text_x < sash.current.text_center_x) do
        sash:update()
      end

      assert.are.equal(':stop', sash.current.state)
    end)

    it('画面右端から消えると :finished 状態になる', function ()
      sash:create('sash', 0, 0)

      while (sash.current.text_x <= 127) do
        pico8.frames = pico8.frames + 1
        sash:update()
      end

      assert.are.equal(':finished', sash.current.state)
    end)
  end)

  describe('render', function()
    describe('current がない場合', function()
      it('エラーなく描画できる', function()
        assert.has_no.errors(function ()
          sash:render()
        end)
      end)
    end)

    describe('current がある場合', function()
      before_each(function()
        sash:create('sash', 0, 0)
      end)

      it('エラーなく描画できる', function()
        assert.has_no.errors(function ()
          sash:render()
        end)
      end)
    end)
  end)
end)
