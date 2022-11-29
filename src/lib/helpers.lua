tile_size = 8

function ceil_rnd(num)
  return ceil(rnd(num))
end

function draw_rounded_box(x0, y0, x1, y1, border_color, fill_color)
  line(x0 + 1, y0, x1 - 1, y0, border_color)
  line(x1, y0 + 1, x1, y1 - 1, border_color)
  line(x1 - 1, y1, x0 + 1, y1, border_color)
  line(x0, y1 - 1, x0, y0 + 1, border_color)

  if fill_color then
    rectfill(x0 + 1, y0 + 1, x1 - 1, y1 - 1, fill_color)
  end
end

function print_outlined(str, x, y, color, border_color)
  for dx = -2, 2 do
    for dy = -2, 2 do
      print(str, x + dx, y + dy, 0)
    end
  end
  for dx = -1, 1 do
    for dy = -1, 1 do
      print(str, x + dx, y + dy, border_color or 12)
    end
  end

  print(str, x, y, color)
end

local function new(cls, ...)
  local self = setmetatable({}, cls)
  self:_init(...)
  return self
end

function new_class()
  local class = {}
  class.__index = class

  setmetatable(class, {
    __call = new
  })

  return class
end

function derived_class(base_class)
  local class = {}
  class.__index = class

  setmetatable(class, {
    __index = base_class,
    __call = new
  })

  return class
end

function singleton(init)
  local s = {}
  s.init = init
  s:init()
  return s
end
