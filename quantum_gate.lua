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
        if (self.before_update) self:before_update()

        if is_idle(self) then
          return
        elseif is_swapping(self) then
          if self.tick_swap == nil then
            self.tick_swap = 0
          elseif self.tick_swap < quantum_gate._num_frames_swap then
            self.tick_swap += 1
          else
            self.tick_swap = nil
            self:_change_state("idle")
          end
        elseif is_match(self) then
          if self.tick_match == nil then
            self.tick_match = 0
          elseif self.tick_match < quantum_gate._num_frames_match then
            self.tick_match += 1
          else
            self.tick_match = nil
            self:_change_state("disappear")
          end
        elseif is_dropped(self) then
          if self.tick_drop == nil then
            self.tick_drop = 0
          else
            self.tick_drop += 1
            if self.tick_drop == 12 then
               self.tick_drop = nil
               self:_change_state("idle")
            end
          end
        elseif is_disappearing(self) then
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
        if (is_i(self)) return

        if (self.draw_setup) self:draw_setup()

        if is_match(self) and (not is_match_type_i(self)) then
          pal(colors.lavender, colors.white)
        end

        if is_disappearing(self) then
          if is_match_type_i(self) then
            pal(colors.white, colors.light_grey)
          else
            pal(colors.white, colors.pink)
          end
        end

        spr(self:_sprite(), x, y)

        pal(colors.white, colors.white)
        pal(colors.lavender, colors.lavender)

        if (self.draw_teardown) self:draw_teardown()
      end,

      replace_with = function(self, other, match_type, delay_puff, delay_disappear)
        assert(is_reducible(self))
        assert(match_type)
        assert(delay_puff)
        assert(delay_disappear)

        self._reduce_to = other
        if is_swap(other) then
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

      -- private

      _change_state = function(self, new_state)
        assert(new_state == "idle" or
               new_state == "swapping_with_left" or new_state == "swapping_with_right" or
               new_state == "dropped" or
               new_state == "match" or
               new_state == "disappear")

        if new_state == "idle" then
          assert(is_swapping(self) or is_dropped(self) or is_match(self) or is_disappearing(self))
        elseif new_state == "swapping_with_left" then
          assert(is_idle(self)or is_dropped(self))
        elseif new_state == "swapping_with_right" then
          assert(is_idle(self) or is_dropped(self))
        elseif new_state == "dropped" then
          assert(is_idle(self)or is_dropped(self))
        elseif new_state == "match" then
          assert(is_reducible(self))
        end

        self._state = new_state
      end,

      _sprite = function(self)
        if is_idle(self) then
          return self._sprites.idle
        elseif is_swapping(self) then
          return self._sprites.idle
        elseif is_match(self) then
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
        elseif is_dropped(self) then
          if self.tick_drop < 5 then
            return self._sprites.dropped
          elseif self.tick_drop < 7 then
            return self._sprites.jumping
          elseif self.tick_drop < 11 then
            return self._sprites.falling
          end        
          return self._sprites.dropped
        elseif is_disappearing(self) then
          return self._sprites.idle
        else
          assert(false, "we should never get here")
        end
      end
    }
  end,
}