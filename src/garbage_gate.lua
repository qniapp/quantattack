require("engine/core/class")

local quantum_gate = require("quantum_gate")

local garbage_gate = derived_class(quantum_gate)
garbage_gate._sprite = 57
garbage_gate._sprite_left = 56
garbage_gate._sprite_right = 58
garbage_gate._ddy = 0.98

function garbage_gate:_init(x, span)
  --#if assert
  assert(span ~= nil, "span is nil")
  --#endif

  quantum_gate._init(self, 'g', span)
end

function garbage_gate:render(screen_x, screen_y)
  for x = 0, self.span - 1 do
    local spr_id = garbage_gate._sprite
    if (x == 0) then -- 左端
      spr_id = garbage_gate._sprite_left
    end
    if (x == self.span - 1) then -- 右端
      spr_id = garbage_gate._sprite_right
    end

    local dy = 0
    if self:is_dropping() then
      dy = self._distance_dropped
    end
    spr(spr_id, screen_x + x * quantum_gate.size, screen_y + dy)
  end
end

return garbage_gate
