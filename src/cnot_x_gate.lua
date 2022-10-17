local gate = require("gate")

function cnot_x_gate(other_x)
  local cnot_x = gate('cnot_x', nil, 'X')
  cnot_x.other_x = other_x
  return cnot_x
end
