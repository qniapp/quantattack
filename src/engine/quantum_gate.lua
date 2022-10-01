require("engine/core/class")

quantum_gate = {
  size = 8,
  _types = { "h", "x", "y", "z", "s", "t" },
  _num_frames_swap = 2,
  _num_frames_match = 45,
  _dy = 2,

  random_single_gate = function(self)
    local type = self._types[flr(rnd(#self._types)) + 1]
    return self:new(type)
  end,

  new = function(_self, type)
    return {
      type = type,
      dy = 0,
      state = "idle",

      update = function(self)
        if (self.type == "?") then
          return
        end

        if is_swapping(self) then
          if self.tick_swap < quantum_gate._num_frames_swap then
            self.tick_swap = self.tick_swap + 1
          else
            self:_change_state("swap_finished")
          end
        elseif is_swap_finished(self) then
          self:_change_state("idle")
        elseif is_dropping(self) then
          if self.start_screen_y + self.dy == self.stop_screen_y then
            self:_change_state("dropped")
          end
        elseif is_dropped(self) then
          self.dy = 0
          self:_change_state("idle")
        elseif is_match(self) then
          if self.tick_match == nil then
            self.tick_match = 0
          elseif self.tick_match < quantum_gate._num_frames_match then
            self.tick_match = self.tick_match + 1
          else
            self.tick_match = nil
            self.type = self.reduce_to.type
            self:_change_state("idle")
          end
        end
      end,

      draw = function(self, screen_x, screen_y)
        if (is_i(self)) then
          return
        end
        if (self.type == "?") then
          return
        end

        local dx = 0
        if self.state == "swapping_with_right" then
          dx = self.tick_swap * (quantum_gate.size / quantum_gate._num_frames_swap)
        elseif self.state == "swapping_with_left" then
          dx = -self.tick_swap * (quantum_gate.size / quantum_gate._num_frames_swap)
        elseif self.state == "dropping" then
          self.dy = self.dy + quantum_gate._dy
          if (screen_y + self.dy > self.stop_screen_y) then
            self.dy = self.stop_screen_y - screen_y
          end
        end

        spr(self:_sprite(), screen_x + dx, screen_y + self.dy)
      end,

      _sprite = function(self)
        local _sprites = {
          h = {
            idle = 0,
            match_up = 8,
            match_middle = 24,
            match_down = 40
          },
          x = {
            idle = 1,
            match_up = 9,
            match_middle = 25,
            match_down = 41,
          },
          y = {
            idle = 2,
            match_up = 10,
            match_middle = 26,
            match_down = 42,
          },
          z = {
            idle = 3,
            match_up = 11,
            match_middle = 27,
            match_down = 43,
          },
          s = {
            idle = 4,
            match_up = 12,
            match_middle = 28,
            match_down = 44,
          },
          t = {
            idle = 5,
            match_up = 13,
            match_middle = 29,
            match_down = 45,
          },
        }
        local sprites = _sprites[self.type]

        if is_idle(self) or
            is_swapping(self) or
            is_swap_finished(self) or
            is_dropping(self) or
            is_dropped(self) then
          return sprites.idle
        elseif is_match(self) then
          local mod = self.tick_match % 12
          if mod <= 2 then
            return sprites.match_up
          elseif mod <= 5 then
            return sprites.match_middle
          elseif mod <= 8 then
            return sprites.match_down
          elseif mod <= 11 then
            return sprites.match_middle
          end
        else
          assert(false, "unknown state: " .. self.state)
        end
      end,

      replace_with = function(self, other)
        self.reduce_to = other
        self:_change_state("match")
      end,

      start_swap_with_right = function(self, swap_new_x)
        self.tick_swap = 0
        self.swap_new_x = swap_new_x
        self:_change_state("swapping_with_right")
      end,

      start_swap_with_left = function(self, swap_new_x)
        self.tick_swap = 0
        self.swap_new_x = swap_new_x
        self:_change_state("swapping_with_left")
      end,

      drop = function(self, start_screen_y, stop_screen_y)
        self.dy = 0
        self.start_screen_y = start_screen_y
        self.stop_screen_y = stop_screen_y
        self:_change_state("dropping")
      end,

      _change_state = function(self, new_state)
        self.state = new_state
      end,
    }
  end
}

return quantum_gate
