require("engine/core/class")

local quantum_gate = require("quantum_gate")
local garbage_gate = derived_class(quantum_gate)

function garbage_gate:_init(width, board)
  assert(width ~= nil, "width is nil")
  assert(board ~= nil, "board is nil")

  local random_x = flr(rnd(board.cols - width + 1)) + 1
  local start_y = board:screen_y(1)
  local stop_y = board:screen_y(board:gate_top_y(random_x, random_x + width - 1) - 1)

  quantum_gate._init(self, 'g')
  self.width = width
  self._state = "fall"
  self.x = random_x
  self.y = start_y
  self.stop_y = stop_y

  -- TODO: すべての garbage_gate インスタンスに共通するプロパティは
  -- garbage_gate.foo として定義する
  self._spr = 57
  self._spr_left = 56
  self._spr_right = 58
  self._gate_top_y = stop_y + quantum_gate.size
  self._sink_y = stop_y + quantum_gate.size * 2
  self._dy = 16
  self._ddy = 0.98
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
      self:_change_state("bounce")
      self._dy = -7
    end

    if self.y > self._gate_top_y and self._dy > 0 then
      if (self.y > self._sink_y) then
        self.y = self._sink_y
      end
      self._dy = self._dy * 0.2

      if (self._state == "fall") then
        self:_change_state("hit gate")
        sfx(1)
      else
        self:_change_state("sink")
      end
    end
  else
    -- bounce
    if self.y > self.stop_y and self._dy > 0 then
      self.y = self.stop_y
      self._dy = -self._dy * 0.6
    end
  end

  if (self.y == self.stop_y and
      self.y == self.y_prev) then
    self:_change_state("idle")
  end
end

function garbage_gate:_update_dy()
  if (self._state ~= "bounce") then
    return
  end
  self._dy = self._dy + self._ddy
end

function garbage_gate:effect_dy()
  if self._state == "sink" or self._state == "bounce" then
    return self.y - self.stop_y
  else
    return 0
  end
end

-- いらないので self._state = new_state とベタに書く
function garbage_gate:_change_state(new_state)
  self._state = new_state
end

-- TODO: state == "drop" との違いは？
-- もし違いがなければ、quantum_gate:is_dropping() に置き換える
function garbage_gate:is_fall()
  return self._state == "fall"
end

function garbage_gate:render(screen_x, screen_y)
  for x = 0, self.width - 1 do
    local spr_id = self._spr
    if (x == 0) then
      spr_id = self._spr_left
    end
    if (x == self.width - 1) then
      spr_id = self._spr_right
    end

    if screen_y then
      spr(spr_id, screen_x + x * quantum_gate.size, screen_y)
    elseif self._state == "fall" then
      spr(spr_id, screen_x + x * quantum_gate.size, self.y)
    end
  end
end

return garbage_gate
