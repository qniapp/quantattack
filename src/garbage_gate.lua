require("engine/core/class")

local quantum_gate = require("quantum_gate")

local garbage_gate = derived_class(quantum_gate)
garbage_gate._sprite = 57
garbage_gate._sprite_left = 56
garbage_gate._sprite_right = 58
garbage_gate._ddy = 0.98

function garbage_gate:_init(span, x)
  assert(span ~= nil, "span is nil")

  -- local start_screen_y = board:screen_y(1)
  -- local stop_screen_y = board:screen_y(board:gate_top_y(x, x + span - 1) - 1)

  quantum_gate._init(self, 'g')
  self.span = span
  self:drop(x, 1)

  -- self._start_screen_y = start_screen_y
  -- self._stop_screen_y = stop_screen_y
  -- self._gate_top_y = stop_screen_y + quantum_gate.size
  -- self._sink_y = stop_screen_y + quantum_gate.size * 2
  -- self._dy = 16
end

function garbage_gate:update(board)
  if self:is_dropping() then
    local screen_y = board:screen_y(self.start_y) + self._distance_dropped
    local next_screen_y = screen_y + quantum_gate._dy
    local next_y = board:y(next_screen_y)

    local droppable = true
    for x = self.x, self.x + self.span - 1 do
      if not board:is_empty(x, next_y) then
        droppable = false
      end
    end

    if next_y <= board.rows and droppable then
      self._distance_dropped = self._distance_dropped + quantum_gate._dy
    else
      self._distance_dropped = 0
      self.y = board:y(screen_y)
      self._state = "dropped"
    end
  end
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

function garbage_gate:_update_y()
  self.y_prev = self._start_screen_y
  self._start_screen_y = self._start_screen_y + self._dy
end

function garbage_gate:_update_state()
  if self._state ~= "bounce" then
    if self._dy < 0.1 then
      self._state = "bounce"
      self._dy = -7
    end

    if self._start_screen_y > self._gate_top_y and self._dy > 0 then
      if (self._start_screen_y > self._sink_y) then
        self._start_screen_y = self._sink_y
      end
      self._dy = self._dy * 0.2

      if self:is_dropping() then
        self._state = "hit gate"
        sfx(1)
      else
        self._state = "sink"
      end
    end
  else
    -- bounce
    if self._start_screen_y > self._stop_screen_y and self._dy > 0 then
      self._start_screen_y = self._stop_screen_y
      self._dy = -self._dy * 0.6
    end
  end

  if (self._start_screen_y == self._stop_screen_y and
      self._start_screen_y == self.y_prev) then
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
    return self._start_screen_y - self._stop_screen_y
  else
    return 0
  end
end

return garbage_gate
