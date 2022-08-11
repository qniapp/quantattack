control_gate = {
  new = function(self, cnot_x_x)
    assert(cnot_x_x)

    local c = quantum_gate:new("control")
    c.cnot_x_x = cnot_x_x
    c._sprites = {
      idle = 6,
      dropped = 22,
      jumping = 54,
      falling = 38,
      match_up = 14,
      match_middle = 30,
      match_down = 46
    }

    c.before_update = function(self)
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

    return c
  end
}