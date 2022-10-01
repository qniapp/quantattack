cnot_x_gate = {
  new = function(self, cnot_c_x)
    assert(cnot_c_x)

    local cnot_x = quantum_gate:new("cnot_x")
    cnot_x.cnot_c_x = cnot_c_x
    cnot_x._sprites = {
      idle = 1,
      dropped = 17,
      jumping = 49,
      falling = 33,
      match_up = 9,
      match_middle = 25,
      match_down = 41,
    }

    cnot_x.draw_setup = function(self)
      if (is_match(self)) then
        return
      end

      pal(colors.blue, colors.orange)
      pal(colors.light_grey, colors.brown)
    end

    cnot_x.draw_teardown = function(self)
      pal(colors.blue, colors.blue)
      pal(colors.light_grey, colors.light_grey)
    end

    return cnot_x
  end
}

return cnot_x_gate
