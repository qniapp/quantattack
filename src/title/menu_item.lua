local menu_item = new_class()

function menu_item:_init(label, description, sx, sy, width, height, target_state, high_score)
  self.label, self.description, self.sx, self.sy, self.width, self.height, self.target_state, self.high_score =
    label, description, sx, sy, width, height, target_state, high_score
end

return menu_item
