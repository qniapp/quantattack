swap_gate = {
  new = function(self, other_x)
    assert(other_x)

    local swap = quantum_gate:new("swap")
    swap.other_x = other_x

    return swap
  end
}