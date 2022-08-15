garbage_unitary = {
  new = function(self, width)
    self._width = width
    self.dx = 0
    return self
  end,

  next = function(self)
    if self.dx == 0 then
      self.dx += 1
      return garbage_unitary_left:new()
    elseif self.dx < self._width then
      self.dx += 1
      return garbage_unitary_body:new()
    else
      return nil
    end
  end,
}

garbage_unitary_left = {
  new = function(self)
    local g = quantum_gate:new("garbage_unitary_left")

    g._width = width
    g._sprites = {
      idle = 67,
      dropped = 67,
      jumping = 48,
      falling = 32,
      match_up = 8,
      match_middle = 24,
      match_down = 40
    }

    return g
  end
}

garbage_unitary_body = {
  new = function(self)
    local g = quantum_gate:new("garbage_unitary_body")

    g._width = width
    g._sprites = {
      idle = 68,
      dropped = 67,
      jumping = 48,
      falling = 32,
      match_up = 8,
      match_middle = 24,
      match_down = 40
    }

    return g
  end
}

garbage_unitary_right = {
  new = function(self)
    local g = quantum_gate:new("garbage_unitary_right")
    g._sprites = {
      idle = 67,
      dropped = 67,
      jumping = 48,
      falling = 32,
      match_up = 8,
      match_middle = 24,
      match_down = 40
    }

    return g
  end
}