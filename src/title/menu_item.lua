local menu_item = new_class()

function menu_item:_init(label, description, sx, target_state, high_score)
  self.label, self.description, self.sx, self.sy, self.target_state, self.high_score = label, description, sx, 48, target_state, high_score
end

return menu_item
