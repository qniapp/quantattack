require("engine/core/class")

local gate = require("gate")

local garbage_gate = derived_class(gate)

function garbage_gate:_init(x, span)
  --#if assert
  assert(span ~= nil, "span is nil")
  --#endif

  gate._init(self, 'g', span)
  self._sprite_middle = 57
  self._sprite_left = 56
  self._sprite_right = 58
end

return garbage_gate
