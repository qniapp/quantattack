cnot_x_gate = {
  new = function(self, cnot_c_x)
    assert(cnot_c_x)

    local cnot_x = quantum_gate:new("cnot_x")
    cnot_x.cnot_c_x = cnot_c_x
    cnot_x._sprites = {
      idle = 1,
      dropped = 17,
      jumping = 49,
      falling = 33,
      match_up = 9,
      match_middle = 25,
      match_down = 41,
    }

    return cnot_x
  end
}