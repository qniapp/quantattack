local high_score_class = require("lib/high_score")
local menu_item = new_class()

-- TODO: 引数の整理とリファクタリング
function menu_item:_init(_target_state, _sx, _sy, _width, _height, _load_param, _label, _description, _high_score_slot)
  local _ENV = self

  label, description, sx, sy, width, height, target_state, high_score, load_param =
    _label, _description, _sx, _sy, _width, _height, _target_state, _high_score_slot and high_score_class(_high_score_slot):get() * 10, _load_param
end

return menu_item
