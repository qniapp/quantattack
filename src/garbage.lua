require("engine/core/class")

local quantum_gate = require("quantum_gate")

garbage = {
  new = function(_self, width, board)
    local random_x = flr(rnd(board.cols - width + 1)) + 1
    local start_y = board:screen_y(1)
    local stop_y = board:screen_y(board:gate_top_y(random_x, random_x + width - 1) - 1)

    return {
      type = "g",
      width = width,
      x = random_x,
      y = start_y,
      state = "fall",
      stop_y = stop_y,
      _spr = 57,
      _spr_left = 56,
      _spr_right = 58,
      _gate_top_y = stop_y + quantum_gate.size,
      _sink_y = stop_y + quantum_gate.size * 2,
      _dy = 16,
      _ddy = 0.98,

      update = function(self)
        self:_update_y()
        self:_update_state()
        self:_update_dy()
      end,

      draw = function(self, screen_x, screen_y)
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
          elseif self.state == "fall" then
            spr(spr_id, screen_x + x * quantum_gate.size, self.y)
          end
        end
      end,

      dy = function(self)
        if self.state == "sink" or self.state == "bounce" then
          return self.y - self.stop_y
        else
          return 0
        end
      end,

      _update_y = function(self)
        self.y_prev = self.y
        self.y = self.y + self._dy
      end,

      _update_state = function(self)
        if self.state ~= "bounce" then
          if self._dy < 0.1 then
            self:_change_state("bounce")
            self._dy = -7
          end

          if self.y > self._gate_top_y and self._dy > 0 then
            if (self.y > self._sink_y) then
              self.y = self._sink_y
            end
            self._dy = self._dy * 0.2

            if (self.state == "fall") then
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
      end,

      _change_state = function(self, new_state)
        self.state = new_state
      end,

      _update_dy = function(self)
        if (self.state ~= "bounce") then
          return
        end
        self._dy = self._dy + self._ddy
      end,
    }
  end,
}

return garbage
