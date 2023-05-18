require("engine/test/bustedhelper")
require("engine/render/color")
require("test/test_helper")
require("lib/helpers")
require("lib/effects")

describe('sash', function()
  describe('create', function()
    before_each(function()
      sash:create('sash,7,8')
    end)

    describe('all', function ()
      it('text プロパティを持つ', function()
        assert.are.equal('sash', sash.all[1].text)
      end)

      it('text_color プロパティを持つ', function()
        assert.are.equal(colors.white, tonum(sash.all[1].text_color))
      end)

      it('background_color プロパティを持つ', function()
        assert.are.equal(colors.red, tonum(sash.all[1].background_color))
      end)

      it('文字列がスクリーン外', function()
        assert.are.equal(-16, sash.all[1].text_x)
      end)

      it('背景なし', function ()
        assert.are.equal(0, sash.all[1].background_height)
      end)

      it('状態が :slidein', function()
        assert.are.equal(':slidein', sash.all[1].state)
      end)
    end)
  end)

  describe('update_all', function()
    it('text_x を更新', function ()
      sash:create('sash,0,0')

      sash:update_all()

      assert.are.equal(-16 + 5, sash.all[1].text_x)
    end)

    it('何度か update すると中央でストップ', function ()
      sash:create('sash,0,0')

      while (sash.all[1].text_x < sash.all[1].text_center_x) do
        sash:update_all()
      end

      assert.are.equal(':stop', sash.all[1].state)
    end)

    it('画面右端から消えると :finished 状態になる', function ()
      sash:create('sash,0,0')

      while (sash.all[1].text_x <= 127) do
        pico8.frames = pico8.frames + 1
        sash:update_all()
      end

      assert.are.equal(':finished', sash.all[1].state)
    end)
  end)

  describe('render_all', function()
    describe('sash がない場合', function()
      it('エラーなく描画できる', function()
        assert.has_no.errors(function ()
          sash:render_all()
        end)
      end)
    end)

    describe('sash がある場合', function()
      before_each(function()
        sash:create('sash,0,0')
      end)

      it('エラーなく描画できる', function()
        assert.has_no.errors(function ()
          sash:render_all()
        end)
      end)
    end)
  end)
end)
