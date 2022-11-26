require("engine/test/bustedhelper")
local menu_item = require("title/menu_item")

describe('menu_item', function()
  describe('init', function()
    it('should set label and target state', function()
      local item = menu_item("in-game", ':ingame')

      assert.are_same({ "in-game", ':ingame' }, { item.label, item.target_state })
    end)
  end)
end)
