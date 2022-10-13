require("engine/core/class")

local gate = require("gate")

local garbage_gate = derived_class(gate)

function garbage_gate:_init(span)
  --#if assert
  assert(span ~= nil, "span is nil")
  --#endif

  gate._init(self, 'g', span)
  self._sprite_middle = 83
  self._sprite_left = 82
  self._sprite_right = 84
end

return garbage_gate
