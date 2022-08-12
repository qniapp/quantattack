-- todo: 幅2のおじゃまゲートを作る

garbage_unitary = {
  new = function(self)
    return {
      _type = "garbage",
      _state = "idle",

      update = function(self)
      end,

      draw = function(self, x, y)
        spr(67, x, y)
        spr(68, x + quantum_gate.size, y)
      end,

      dropped = function(self)
      end,
    }
  end,
}