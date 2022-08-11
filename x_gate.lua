x_gate = {
  new = function(self, cnot_c_x)
    local x = quantum_gate:new("x")
    x.cnot_c_x = cnot_c_x
    x._sprites = {
      idle = 1,
      dropped = 17,
      jumping = 49,
      falling = 33,
      match_up = 9,
      match_middle = 25,
      match_down = 41,
    }

    return x
  end
}