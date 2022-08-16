garbage_unitary_match = {
  new = function(self, width)
    local gate = quantum_gate:new("garbage_unitary_match")

    gate._state = "idle"
    gate._width = width
    gate._sprites = {
      idle = 70,
      dropped = 16,
      jumping = 48,
      falling = 32,
      match_up = 70,
      match_middle = 70,
      match_down = 70
    }

    return gate
  end
}