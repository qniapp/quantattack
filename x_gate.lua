x_gate = {
  new = function(self, cnot_c_x)
    local x = quantum_gate:new("x")
    x.cnot_c_x = cnot_c_x
    return x
  end
}