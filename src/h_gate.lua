local quantum_gate = require("quantum_gate")

h_gate = {
  new = function(self)
    local h = quantum_gate("h")
    h._sprites = {
      idle = 0,
      dropped = 16,
      jumping = 48,
      falling = 32,
      match_up = 8,
      match_middle = 24,
      match_down = 40
    }

    return h
  end
}

return h_gate
