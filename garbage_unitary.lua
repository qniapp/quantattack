garbage_unitary = {
  new = function(self, width)
    return {
      _type = "garbage",
      _state = "idle",
      _width = width,

      update = function(self)
      end,

      draw = function(self, screen_x, screen_y)
        spr(67, screen_x, screen_y)

        for garbage_body_index = 1, self._width - 2 do
          spr(68, screen_x + quantum_gate.size * garbage_body_index, screen_y)
        end

        spr(69, screen_x + quantum_gate.size * (self._width - 1), screen_y)
      end,

      dropped = function(self)
      end,
    }
  end,
}