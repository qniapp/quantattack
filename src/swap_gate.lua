local gate = require("gate")

function swap_gate(other_x)
  local swap = gate('swap', nil, 'S')
  swap.other_x = other_x

  return swap
end
