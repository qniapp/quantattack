local menu_item = new_class()

function menu_item:_init(_label, _description, _sx, _sy, _width, _height, _target_state, _high_score, _load_param)
  local _ENV = self

  label, description, sx, sy, width, height, target_state, high_score, load_param =
    _label, _description, _sx, _sy, _width, _height, _target_state, _high_score, _load_param
end

return menu_item
