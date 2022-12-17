require("lib/helpers")

local ion = new_class()

function ion:_init()
  self._x = 100
  self._y = 50
end

function ion.update(_ENV)
end

function ion.draw(_ENV)
  local angle = t()

  fillp(23130.5)
  circfill(_x, _y, 8 + 2 * sin(angle), 12)
  fillp()
  circfill(_x, _y, 6 + 2 * sin(1.5 * angle), 12)
  circfill(_x, _y, 5 + sin(2.5 * angle), 7)
end

return ion
