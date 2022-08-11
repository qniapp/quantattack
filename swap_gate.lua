swap_gate = {
  new = function(self, other_x)
    assert(other_x)

    local swap = quantum_gate:new("swap")
    swap.other_x = other_x
    swap._sprites = {
      idle = 7,
      dropped = 23,
      jumping = 55,
      falling = 39,
      match_up = 15,
      match_middle = 31,
      match_down = 47,
    }

    swap.before_update = function(self)
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

    return swap
  end
}