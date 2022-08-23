player_cursor = {
  _sprites = {
    corner = 65,
    middle = 66,
  },
  _color = colors.dark_green,

  new = function(self, board, x, y)
    return {
      x = x or 3,
      y = y or 6,
      _board = board,
      _tick = 0,
      _state_change_frames = 14,

      move_left = function(self)
        if (self.x > 1) self.x -= 1
      end,

      move_right = function(self)
        if (self.x < self._board.cols - 1) self.x += 1
      end,

      move_up = function(self)
        if (self.y > 1) self.y -= 1
      end,

      move_down = function(self)
        if (self.y < self._board.rows) self.y += 1
      end,  

      update = function(self)
        self._shrunk = self._tick >= self._state_change_frames
        self:_advance_tick()
      end,

      draw = function(self)
        if self.cannot_swap then
          pal(player_cursor._color, colors.red)
        end
        if self.game_over then
          pal(player_cursor._color, colors.dark_grey)
        end

        local xl = self:_screen_xl()
        local xm = self:_screen_xm()
        local xr = self:_screen_xr()
        local yt = self:_screen_yt()
        local yb = self:_screen_yb()

        spr(player_cursor._sprites.corner, xl, yt)
        spr(player_cursor._sprites.middle, xm, yt)
        spr(player_cursor._sprites.corner, xr, yt, 1, 1, true, false)
        spr(player_cursor._sprites.corner, xl, yb, 1, 1, false, true)
        spr(player_cursor._sprites.middle, xm, yb, 1, 1, false, true)
        spr(player_cursor._sprites.corner, xr, yb, 1, 1, true, true)

        pal(player_cursor._color, player_cursor._color)
      end,      

      -- private

      _advance_tick = function(self)
        self._tick += 1
        self._tick %= self._state_change_frames * 2
      end,

      _screen_xl = function(self)
        return self._board:screen_x(self.x) - 5 + (self._shrunk and 1 or 0)
      end,

      _screen_xm = function(self)
        return self._board:screen_x(self.x) + quantum_gate.size - 4
      end,

      _screen_xr = function(self)
        return self._board:screen_x(self.x + 1) + 4 - (self._shrunk and 1 or 0)
      end,

      _screen_yt = function(self)
        return self._board:screen_y(self.y) - 5 + (self._shrunk and 1 or 0)
      end,

      _screen_yb = function(self)
        return self._board:screen_y(self.y) + quantum_gate.size - 4 - (self._shrunk and 1 or 0)
      end
    } 
  end
}