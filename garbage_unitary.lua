garbage_unitary = {
  new = function(self, width)
    assert(3 <= width)
    assert(width <= 6)

    return {
      _type = "garbage_unitary",
      _width = width,
      _state = "idle",

      update = function(self)  
      end,

      draw = function(self, screen_x, screen_y)
        spr(67, screen_x, screen_y)

        for dx = 1, self._width - 2 do
          spr(68, screen_x + quantum_gate.size * dx, screen_y)
        end

        spr(69, screen_x + quantum_gate.size * (self._width - 1), screen_y)
      end,

      dropped = function(self)
      end,
    }
  end,
}
