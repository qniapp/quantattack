local menu_item = new_struct()

function menu_item:_init(label, target_state)
  self.label, self.target_state = label, target_state
end

return menu_item
