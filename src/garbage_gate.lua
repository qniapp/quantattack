require("engine/core/class")

local quantum_gate = require("quantum_gate")

local garbage_gate = derived_class(quantum_gate)
garbage_gate._sprite = 57
garbage_gate._sprite_left = 56
garbage_gate._sprite_right = 58
garbage_gate._ddy = 0.98

function garbage_gate:_init(span, x, board)
  assert(span ~= nil, "span is nil")
  assert(board ~= nil, "board is nil")

  local start_screen_y = board:screen_y(1)
  local stop_screen_y = board:screen_y(board:gate_top_y(x, x + span - 1) - 1)

  quantum_gate._init(self, 'g')
  self.span = span
  self._state = "fall"
  self.x = x
  self.y = start_screen_y
  self.stop_screen_y = stop_screen_y
  self._gate_top_y = stop_screen_y + quantum_gate.size
  self._sink_y = stop_screen_y + quantum_gate.size * 2
  self._dy = 16
end

function garbage_gate:update()
  self:_update_y()
  self:_update_state()
  self:_update_dy()
end

function garbage_gate:_update_y()
  self.y_prev = self.y
  self.y = self.y + self._dy
end

function garbage_gate:_update_state()
  if self._state ~= "bounce" then
    if self._dy < 0.1 then
      self._state = "bounce"
      self._dy = -7
    end

    if self.y > self._gate_top_y and self._dy > 0 then
      if (self.y > self._sink_y) then
        self.y = self._sink_y
      end
      self._dy = self._dy * 0.2

      if (self._state == "fall") then
        self._state = "hit gate"
        sfx(1)
      else
        self._state = "sink"
      end
    end
  else
    -- bounce
    if self.y > self.stop_screen_y and self._dy > 0 then
      self.y = self.stop_screen_y
      self._dy = -self._dy * 0.6
    end
  end

  if (self.y == self.stop_screen_y and
      self.y == self.y_prev) then
    self._state = "idle"
  end
end

function garbage_gate:_update_dy()
  if self._state ~= "bounce" then
    return
  end
  self._dy = self._dy + garbage_gate._ddy
end

function garbage_gate:effect_dy()
  if self._state == "sink" or self._state == "bounce" then
    return self.y - self.stop_screen_y
  else
    return 0
  end
end

-- TODO: state == "drop" との違いは？
-- もし違いがなければ、quantum_gate:is_dropping() に置き換える
function garbage_gate:is_fall()
  return self._state == "fall"
end

function garbage_gate:render(screen_x, screen_y)
  for x = 0, self.span - 1 do
    local spr_id = garbage_gate._sprite
    if (x == 0) then
      spr_id = garbage_gate._sprite_left
    end
    if (x == self.span - 1) then
      spr_id = garbage_gate._sprite_right
    end

    if screen_y then
      spr(spr_id, screen_x + x * quantum_gate.size, screen_y)
    elseif self._state == "fall" then
      spr(spr_id, screen_x + x * quantum_gate.size, self.y)
    end
  end
end

return garbage_gate
