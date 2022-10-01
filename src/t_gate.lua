t_gate = {
  new = function(self)
    local t = quantum_gate:new("t")
    t._sprites = {
      idle = 5,
      dropped = 21,
      jumping = 53,
      falling = 37,
      match_up = 13,
      match_middle = 29,
      match_down = 45,
    }

    return t
  end
}

return t_gate
