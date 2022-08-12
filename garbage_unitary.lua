garbage_unitary = {
  new = function(self, width)
    return {
      _type = "garbage",
      _state = "idle",
      _width = width,
      _sprites = {
        left = 67,
        body = 68,
        right = 69,
      },

      update = function(self)
      end,

      draw = function(self, screen_x, screen_y)
        spr(self._sprites.left, screen_x, screen_y)

        for body_index = 1, self._width - 2 do
          spr(self._sprites.body, screen_x + quantum_gate.size * body_index, screen_y)
        end

        spr(self._sprites.right, screen_x + quantum_gate.size * (self._width - 1), screen_y)
      end,

      dropped = function(self)
      end,
    }
  end,
}