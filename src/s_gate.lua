local quantum_gate = require("quantum_gate")

s_gate = {
  new = function(self)
    local s = quantum_gate("s")
    s._sprites = {
      idle = 4,
      dropped = 20,
      jumping = 52,
      falling = 36,
      match_up = 12,
      match_middle = 28,
      match_down = 44,
    }

    return s
  end
}

return s_gate
