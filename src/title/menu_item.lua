local menu_item = new_class()

function menu_item:_init(label, target_state)
  self.label, self.target_state = label, target_state
end

return menu_item
