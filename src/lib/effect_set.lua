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

function effect_set:render_all()
  self:_foreach(self.render)
end

function effect_set:_foreach(f)
  foreach(self.all, f)
end

return effect_set
