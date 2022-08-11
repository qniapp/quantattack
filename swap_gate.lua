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

    return swap
  end
}