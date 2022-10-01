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

    return swap
  end
}

return swap_gate
