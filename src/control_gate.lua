local gate = require("gate")

function control_gate(other_x)
  local control = gate('control')
  control.other_x = other_x
  return control
end
