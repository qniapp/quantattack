--- ヘルパ関数

--- 1 以上 num 以下の乱数を返す
function ceil_rnd(num)
  return flr(rnd(num)) + 1
end

--- 角の丸い箱を描く
function draw_rounded_box(x0, y0, x1, y1, border_color, fill_color)
  line(x0 + 1, y0, x1 - 1, y0, border_color)
  line(x1, y0 + 1, x1, y1 - 1, border_color)
  line(x1 - 1, y1, x0 + 1, y1, border_color)
  line(x0, y1 - 1, x0, y0 + 1, border_color)

  if fill_color then
    rectfill(x0 + 1, y0 + 1, x1 - 1, y1 - 1, fill_color)
  end
end

--- アウトライン付き文字を表示
function print_outlined(str, x, y, color, border_color)
  if border_color ~= 0 then
    for dx = -2, 2 do
      for dy = -2, 2 do
        print(str, x + dx, y + dy, 0)
      end
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

--- クラスを作る
function new_class()
  local class = {}
  class.__index = class

  setmetatable(class, {
    __index = _ENV,
    __call = new
  })

  return class
end

--- 継承したクラスを返す
function derived_class(base_class)
  local class = {}
  class.__index = class

  setmetatable(class, {
    __index = base_class,
    __call = new
  })

  return class
end

--- カートを呼び出す
function jump(name, breadcrumb, param)
  load(name .. ".p8", breadcrumb, param)
  load("#" .. name, breadcrumb, param)
end

--- unpack & split
function unpack_split(...)
  return unpack(split(...))
end

function score_string(score)
  return score .. (score == 0 and "" or "0")
end

--- map 関数
function transform(t, func)
  local transformed_t = {}
  for key, value in pairs(t) do
    transformed_t[key] = func(value)
  end
  return transformed_t
end
