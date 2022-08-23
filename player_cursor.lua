player_cursor = {
  _sprites = {
    corner = 65,
    middle = 66,
  },
  _color = colors.dark_green,

  new = function(self, board_cols, board_rows, x, y)
    return {
      x = x or 3,
      y = y or 6,
      _board_cols = board_cols,
      _board_rows = board_rows,
      _tick = 0,
      _state_change_frames = 14,

      move_left = function(self)
        if (self.x > 1) self.x -= 1
      end,

      move_right = function(self)
        if (self.x < self._board_cols - 1) self.x += 1
      end,

      move_up = function(self)
        if (self.y > 1) self.y -= 1
      end,

      move_down = function(self)
        if (self.y < self._board_rows) self.y += 1
      end,  

      update = function(self)
        self._shrunk = self._tick >= self._state_change_frames
        self._tick += 1
        self._tick %= self._state_change_frames * 2
      end,

      draw = function(self, screen_x, screen_y, board_dy)
        if self.cannot_swap then
          pal(player_cursor._color, colors.red)
        end
        if self.game_over then
          pal(player_cursor._color, colors.dark_grey)
        end

        local d = self._shrunk and 1 or 0
        local b_dy = board_dy or 0
        local xl = screen_x - 5 + d
        local xm = screen_x + 4
        local xr = screen_x + 12 - d
        local yt = screen_y - 5 + d + b_dy
        local yb = screen_y + 4 - d + b_dy

        spr(player_cursor._sprites.corner, xl, yt)
        spr(player_cursor._sprites.middle, xm, yt)
        spr(player_cursor._sprites.corner, xr, yt, 1, 1, true, false)
        spr(player_cursor._sprites.corner, xl, yb, 1, 1, false, true)
        spr(player_cursor._sprites.middle, xm, yb, 1, 1, false, true)
        spr(player_cursor._sprites.corner, xr, yb, 1, 1, true, true)

        pal(player_cursor._color, player_cursor._color)
      end
    } 
  end
}