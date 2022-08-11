z_gate = {
  new = function(self)
    local z = quantum_gate:new("z")
    z._sprites = {
      idle = 3,
      dropped = 19,
      jumping = 51,
      falling = 35,
      match_up = 11,
      match_middle = 27,
      match_down = 43,
    }

    return z
  end
}