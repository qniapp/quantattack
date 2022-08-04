
quantum_gate = {
  size = 8,

  _types = {"h", "x", "y", "z", "s", "t", "control", "swap", "i"},
  _sprites = {
    ["idle"] = {
      ["h"] = 0,
      ["x"] = 1,
      ["y"] = 2,
      ["z"] = 3,
      ["s"] = 4,
      ["t"] = 5,
      ["control"] = 6,
      ["swap"] = 7,
    },
    ["dropped"] = {
      ["h"] = 16,
      ["x"] = 17,
      ["y"] = 18,
      ["z"] = 19,
      ["s"] = 20,
      ["t"] = 21,
      ["control"] = 22,
      ["swap"] = 23,
    },
    ["jumping"] = {
      ["h"] = 48,
      ["x"] = 49,
      ["y"] = 50,
      ["z"] = 51,
      ["s"] = 52,
      ["t"] = 53,
      ["control"] = 54,
      ["swap"] = 55,
    },
    ["falling"] = {
      ["h"] = 32,
      ["x"] = 33,
      ["y"] = 34,
      ["z"] = 35,
      ["s"] = 36,
      ["t"] = 37,
      ["control"] = 38,
      ["swap"] = 39,
    },    
    ["match_up"] = {
      ["h"] = 8,
      ["x"] = 9,
      ["y"] = 10,
      ["z"] = 11,
      ["s"] = 12,
      ["t"] = 13,
      ["control"] = 14,
      ["swap"] = 15,
    },
    ["match_middle"] = {
      ["h"] = 24,
      ["x"] = 25,
      ["y"] = 26,
      ["z"] = 27,
      ["s"] = 28,
      ["t"] = 29,
      ["control"] = 30,
      ["swap"] = 31,
    },     
    ["match_down"] = {
      ["h"] = 40,
      ["x"] = 41,
      ["y"] = 42,
      ["z"] = 43,
      ["s"] = 44,
      ["t"] = 45,
      ["control"] = 46,
      ["swap"] = 47,
    },    
  },

  _num_frames_swap = 4,
  _num_frames_match = 60,

  h = function(self)
    return self:new("h")
  end,

  x = function(self, cnot_c_x)
    local x = self:new("x")
    x.cnot_c_x = cnot_c_x
    return x
  end,

  y = function(self)
    return self:new("y")
  end,

  z = function(self)
    return self:new("z")
  end,

  s = function(self)
    return self:new("s")
  end,

  t = function(self)
    return self:new("t")
  end,

  control = function(self, cnot_x_x)
    assert(cnot_x_x)

    local c = self:new("control")
    c.cnot_x_x = cnot_x_x
    return c
  end,

  swap = function(self, other_x)
    assert(other_x)

    local swap = self:new("swap")
    swap.other_x = other_x
    return swap
  end,

  i = function(self)
    return self:new("i")
  end,

  random = function(self)
    return self:new(self._types[flr(rnd(#self._types)) + 1])
  end,

  new = function(self, type)
    return {
      _type = type,
      replace_with_type = nil,
      _state = "idle",

      draw = function(self, x, y)
        if self:is_i() then return end

        if self:is_cnot_x() then
          pal(colors.light_grey, colors.brown)
          pal(colors.dark_blue, colors.light_grey)
        end

        spr(self:_sprite(), x, y)

        pal(colors.light_grey, colors.light_grey)
        pal(colors.dark_blue, colors.dark_blue)
      end,

      replace_with = function(self, other, puff_delay, disappearance_delay)
        assert(not self:is_i())
        assert(other._type)

        if self._state ~= "idle" and self._state ~= "dropped" then
          return
        end

        self.replace_with_type = other._type
        self.other_x = other.other_x -- swap
        self.puff_delay = puff_delay
        self.disappearance_delay = disappearance_delay
        self.tick_match = 0
        self:_change_state("match")
      end,

      dropped = function(self)
        self:_change_state("dropped")
      end,

      swap_with_left = function(self)
        self:_change_state("swapping_with_left")
      end,

      swap_with_right = function(self)
        self:_change_state("swapping_with_right")
      end,

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
            self:_change_state("idle")
          end
        elseif self:is_match() then
          sfx(4)
          
          if self.tick_match < quantum_gate._num_frames_match then
            self.tick_match += 1
          else
            self.tick_match = nil
            self.tick_disappearance = 0
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

          if self.tick_disappearance == self.puff_delay then
            self._type = self.replace_with_type
            self.replace_with_type = nil
            self.puff = true            
          end

          if self.tick_disappearance == self.disappearance_delay then
            self.puff = nil
            self.tick_disappearance = nil
            self:_change_state("idle")
            return
          end

          self.tick_disappearance += 1
        else
          assert(false, "we should never get here")
        end
      end,

      is_idle = function(self)
        return self._state == "idle"
      end,

      is_reducible = function(self)
        return self:is_idle() or self:is_dropped()
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

      to_puff = function(self)
        return self.puff == true
      end,

      is_h = function(self)
        return self._type == "h"
      end,

      is_x = function(self)
        return self._type == "x" and self.cnot_c_x == nil
      end,

      is_cnot_x = function(self)
        return self._type == "x" and self.cnot_c_x ~= nil
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
          assert(self:is_idle())
        elseif new_state == "match" then
          assert(self:is_reducible())
        end

        self._state = new_state
      end,

      _sprite = function(self)
        if self:is_idle() then
          return quantum_gate._sprites.idle[self._type]
        elseif self:is_swapping() then
          return quantum_gate._sprites.idle[self._type]
        elseif self:is_match() then
          local icon = self.tick_match % 12
          if icon == 0 or icon == 1 or icon == 2 then
            return quantum_gate._sprites.match_up[self._type]
          elseif icon == 3 or icon == 4 or icon == 5 then
            return quantum_gate._sprites.match_middle[self._type]
          elseif icon == 6 or icon == 7 or icon == 8 then
            return quantum_gate._sprites.match_down[self._type]
          elseif icon == 9 or icon == 10 or icon == 11 then
            return quantum_gate._sprites.match_middle[self._type]
          end
        elseif self:is_dropped() then
          if self.tick_drop < 5 then
            return quantum_gate._sprites.dropped[self._type]
          elseif self.tick_drop < 7 then
            return quantum_gate._sprites.jumping[self._type]
          elseif self.tick_drop < 11 then
            return quantum_gate._sprites.falling[self._type]
          end        
          return quantum_gate._sprites.dropped[self._type]
        elseif self:is_disappearing() then
          return quantum_gate._sprites.idle[self._type]
        else
          assert(false, "we should never get here")
        end
      end
    }
  end,
}