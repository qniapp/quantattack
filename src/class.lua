local function new(cls, ...)
  local self = setmetatable({}, cls)
  self:_init(...)
  return self
end

local function concat(lhs, rhs)
  return stringify(lhs)..stringify(rhs)
end

function new_class()
  local class = {}
  class.__index = class
  class.__concat = concat

  setmetatable(class, {
    __call = new
  })

  return class
end

function derived_class(base_class)
  local class = {}
  class.__index = class
  class.__concat = concat

  setmetatable(class, {
    __index = base_class,
    __call = new
  })

  return class
end

function singleton(init)
  local s = {}
  setmetatable(s, {
    __concat = concat
  })
  s.init = init
  s:init()
  return s
end
