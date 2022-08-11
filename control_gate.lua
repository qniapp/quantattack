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

    return c
  end
}