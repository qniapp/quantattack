control_gate = {
  new = function(self, cnot_x_x)
    assert(cnot_x_x)

    local c = quantum_gate:new("control")
    c.cnot_x_x = cnot_x_x

    return c
  end
}