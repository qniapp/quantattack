local colors = require("engine/colors")

-- config
cursor_color = colors.dark_green
cursor_sprite_corner = 65
cursor_sprite_middle = 66
cursor_anim_frames = 14

player_cursor = {
 new = function(_self, cols, rows, x, y)
  return {
   x = x or 3,
   y = y or 6,
   _cols = cols,
   _rows = rows,
   _tick = 0,

   move_left = function(self)
    if (self.x > 1) self.x -= 1
   end,

   move_right = function(self)
    if (self.x < self._cols - 1) self.x += 1
   end,

   move_up = function(self)
    if (self.y > 1) self.y -= 1
   end,

   move_down = function(self)
    if (self.y < self._rows) self.y += 1
   end,  

   update = function(self)
    self._small = self._tick >= cursor_anim_frames
    self._tick += 1
    self._tick %= cursor_anim_frames * 2
   end,

   draw = function(self, screen_x, screen_y, board_dy)
    if self.cannot_swap then
     pal(cursor_color, colors.red)
    end
    if self.game_over then
     pal(cursor_color, colors.dark_grey)
    end

    local d = self._small and 1 or 0
    local b_dy = board_dy or 0
    local xl = screen_x - 5 + d
    local xm = screen_x + 4
    local xr = screen_x + 12 - d
    local yt = screen_y - 5 + d + b_dy
    local yb = screen_y + 4 - d + b_dy

    spr(cursor_sprite_corner, xl, yt)
    spr(cursor_sprite_middle, xm, yt)
    spr(cursor_sprite_corner, xr, yt, 1, 1, true, false)
    spr(cursor_sprite_corner, xl, yb, 1, 1, false, true)
    spr(cursor_sprite_middle, xm, yb, 1, 1, false, true)
    spr(cursor_sprite_corner, xr, yb, 1, 1, true, true)

    pal(cursor_color, cursor_color)
   end
  } 
 end
}

return player_cursor
