local effect_set = singleton(function(self)
  self.all = {}
end)

function effect_set:_foreach(f)
  foreach(self.all, f)
end

return effect_set
