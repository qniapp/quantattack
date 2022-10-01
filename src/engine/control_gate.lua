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
      if self.tick_connection == nil then
        self.tick_connection = 0
        if self.connection == nil then
          self.connection = flr(rnd(2)) == 0
        end
        if self.connection then
          self.connection_duration = flr(rnd(5)) * 30
        else
          self.connection_duration = flr(rnd(5)) + 5
        end
      elseif self.tick_connection == self.connection_duration then
        self.tick_connection = nil
        self.connection = not self.connection
      else
        self.tick_connection = self.tick_connection + 1
      end    
    end

    return c
  end
}

return control_gate
