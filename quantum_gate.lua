quantum_gate = {
  size = 8,

  _num_frames_swap = 4,
  _num_frames_match = 45,

  new = function(self, type)
    return {
      _type = type,
      _reduce_to = nil,
      _state = "idle",

      update = function(self)
        -- gate specific updates
        if self:is_control() or self:is_swap() then
          if self.tick_laser == nil then
            self.tick_laser = 0
            if self.laser == nil then
              self.laser = flr(rnd(2)) == 0
            end
            if self.laser then
              self.laser_duration = flr(rnd(5)) * 30
            else
              self.laser_duration = flr(rnd(5)) + 5
            end
          elseif self.tick_laser == self.laser_duration then
            self.tick_laser = nil
            self.laser = not self.laser
          else
            self.tick_laser += 1
          end
        end

        if self:is_idle() then
          return
        elseif self:is_swapping() then
          if self.tick_swap == nil then
            self.tick_swap = 0
          elseif self.tick_swap < quantum_gate._num_frames_swap then
            self.tick_swap += 1
          else
            self.tick_swap = nil
            self:_change_state("idle")
          end
        elseif self:is_match() then
          if self.tick_match == nil then
            self.tick_match = 0
          elseif self.tick_match < quantum_gate._num_frames_match then
            self.tick_match += 1
          else
            self.tick_match = nil
            self:_change_state("disappear")
          end
        elseif self:is_dropped() then
          if self.tick_drop == nil then
            self.tick_drop = 0
          else
            self.tick_drop += 1
            if self.tick_drop == 12 then
               self.tick_drop = nil
               self:_change_state("idle")
            end
          end
        elseif self:is_disappearing() then
          self.puff = false

          if self.tick_disappear == nil then
            self.tick_disappear = 0
          end

          if self.tick_disappear == self.delay_puff then
            self._type = self._reduce_to._type
            self._sprites = self._reduce_to._sprites
            self._reduce_to = nil
            self.puff = true            
          end

          if self.tick_disappear > self.delay_puff then
            self.puff = false
          end

          if self.tick_disappear == self.delay_disappear then
            self.tick_disappear = nil
            self:_change_state("idle")
            return
          end

          self.tick_disappear += 1
        else
          assert(false, "we should never get here")
        end
      end,

      draw = function(self, x, y)
        if (self:is_i()) return

        if self:is_cnot_x() and (not self:is_match()) then
          pal(colors.blue, colors.orange)
          pal(colors.light_grey, colors.brown)
        end

        if self:is_match() and (not self:is_match_type_i()) then
          pal(colors.lavender, colors.white)
        end

        if self:is_disappearing() then
          if self:is_match_type_i() then
            pal(colors.white, colors.light_grey)
          else
            pal(colors.white, colors.pink)
          end
        end

        spr(self:_sprite(), x, y)

        pal(colors.white, colors.white)
        pal(colors.blue, colors.blue)
        pal(colors.light_grey, colors.light_grey)
        pal(colors.lavender, colors.lavender)
      end,

      replace_with = function(self, other, match_type, delay_puff, delay_disappear)
        assert(self:is_reducible())
        assert(match_type)
        assert(delay_puff)
        assert(delay_disappear)

        self._reduce_to = other
        if other:is_swap() then
          self.other_x = other.other_x -- swap
        end
        self.match_type = match_type
        self.delay_puff = delay_puff
        self.delay_disappear = delay_disappear

        self:_change_state("match")
      end,

      dropped = function(self)
        self:_change_state("dropped")
      end,

      start_swap_with_left = function(self, swap_new_x)
        self.swap_new_x = swap_new_x
        self:_change_state("swapping_with_left")
      end,

      start_swap_with_right = function(self, swap_new_x)
        self.swap_new_x = swap_new_x
        self:_change_state("swapping_with_right")
      end,

      -- gate states

      is_idle = function(self)
        return self._state == "idle"
      end,

      is_reducible = function(self)
        return (not self:is_i()) and (not self:is_busy())
      end,

      is_swapping = function(self)
        return self:is_swapping_with_left() or self:is_swapping_with_right()
      end,

      is_swapping_with_left = function(self)
        return self._state == "swapping_with_left"
      end,

      is_swapping_with_right = function(self)
        return self._state == "swapping_with_right"
      end,

      is_match = function(self)
        return self._state == "match"
      end,

      is_dropped = function(self)
        return self._state == "dropped"
      end,

      is_disappearing = function(self)
        return self._state == "disappear"
      end,

      is_busy = function(self)
        return not (self:is_idle() or self:is_dropped())
      end,

      -- gate types

      is_h = function(self)
        return self._type == "h"
      end,

      is_x = function(self)
        return self._type == "x" and self.cnot_c_x == nil
      end,

      is_cnot_x = function(self)
        return self._type == "x" and self.cnot_c_x != nil
      end,

      is_y = function(self)
        return self._type == "y"
      end,

      is_z = function(self)
        return self._type == "z"
      end,

      is_s = function(self)
        return self._type == "s"
      end,

      is_t = function(self)
        return self._type == "t"
      end,

      is_control = function(self)
        return self._type == "control"
      end,

      is_swap = function(self)
        return self._type == "swap"
      end,

      is_i = function(self)      
        return self._type == "i"
      end,

      is_match_type_i = function(self)
        return self.match_type == "hh" or self.match_type == "xx" or self.match_type == "yy" or self.match_type == "zz" or self.match_type == "swap swap"
      end,

      -- private

      _change_state = function(self, new_state)
        assert(new_state == "idle" or
               new_state == "swapping_with_left" or new_state == "swapping_with_right" or
               new_state == "dropped" or
               new_state == "match" or
               new_state == "disappear")

        if new_state == "idle" then
          assert(self:is_swapping() or self:is_dropped() or self:is_match() or self:is_disappearing())
        elseif new_state == "swapping_with_left" then
          assert(self:is_idle() or self:is_dropped())
        elseif new_state == "swapping_with_right" then
          assert(self:is_idle() or self:is_dropped())
        elseif new_state == "dropped" then
          assert(self:is_idle() or self:is_dropped())
        elseif new_state == "match" then
          assert(self:is_reducible())
        end

        self._state = new_state
      end,

      _sprite = function(self)
        if self:is_idle() then
          return self._sprites.idle
        elseif self:is_swapping() then
          return self._sprites.idle
        elseif self:is_match() then
          local icon = self.tick_match % 12
          if icon == 0 or icon == 1 or icon == 2 then
            return self._sprites.match_up
          elseif icon == 3 or icon == 4 or icon == 5 then
            return self._sprites.match_middle
          elseif icon == 6 or icon == 7 or icon == 8 then
            return self._sprites.match_down
          elseif icon == 9 or icon == 10 or icon == 11 then
            return self._sprites.match_middle
          end
        elseif self:is_dropped() then
          if self.tick_drop < 5 then
            return self._sprites.dropped
          elseif self.tick_drop < 7 then
            return self._sprites.jumping
          elseif self.tick_drop < 11 then
            return self._sprites.falling
          end        
          return self._sprites.dropped
        elseif self:is_disappearing() then
          return self._sprites.idle
        else
          assert(false, "we should never get here")
        end
      end
    }
  end,
}