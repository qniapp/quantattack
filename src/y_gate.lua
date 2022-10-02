local quantum_gate = require("quantum_gate")

y_gate = {
  new = function(self)
    local y = quantum_gate("y")
    y._sprites = {
      idle = 2,
      dropped = 18,
      jumping = 50,
      falling = 34,
      match_up = 10,
      match_middle = 26,
      match_down = 42,
    }

    return y
  end
}

return y_gate
