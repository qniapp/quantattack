require("lib/helpers")

local effect_set = new_class()

function effect_set:_init()
  self.all = {}
end

function effect_set:_add(f)
  local _ENV = setmetatable({}, { __index = _ENV })
  f(_ENV)
  add(self.all, _ENV)
end

function effect_set:update_all()
  if self.slow and #self.all > 0 then
    flip()
  end

  foreach(self.all, function(each)
    self._update(each, self)
  end)
end

function effect_set:render_all()
  foreach(self.all, self._render)
end

return effect_set
