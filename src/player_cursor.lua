require("engine/core/class")  -- already in engine/common, but added for clarity

local colors = require("colors")
local board = require("board")

player_cursor = {
    color = colors.dark_green,
    sprite_corner = 65,
    sprite_middle = 66,
    animation_frame_count = 14,

    new = function(_self, cols, rows, x, y)
        return {
            x = x or 3,
            y = y or 6,
            _cols = board.default_cols,
            _rows = board.default_rows,
            _tick = 0,

            move_left = function(self)
                if self.x > 1 then
                    self.x = self.x - 1
                end
            end,

            move_right = function(self)
                if self.x < self._cols - 1 then
                    self.x = self.x + 1
                end
            end,

            move_up = function(self)
                if self.y > 1 then
                    self.y = self.y - 1
                end
            end,

            move_down = function(self)
                if self.y < self._rows then
                    self.y = self.y + 1
                end
            end,

            update = function(self)
                self._small = self._tick >= player_cursor.animation_frame_count
                self._tick = self._tick + 1
                self._tick = self._tick % (player_cursor.animation_frame_count * 2)
            end,

            draw = function(self, screen_x, screen_y, board_dy)
                local x = screen_x or self.x
                local y = screen_y or self.y
                local dy = board_dy or 0

                if self.cannot_swap then
                    pal(player_cursor.color, colors.red)
                end
                if self.game_over then
                    pal(player_cursor.color, colors.dark_grey)
                end

                local d = self._small and 1 or 0
                local xl = x - 5 + d
                local xm = x + 4
                local xr = x + 12 - d
                local yt = y - 5 + d + dy
                local yb = y + 4 - d + dy

                spr(player_cursor.sprite_corner, xl, yt)
                spr(player_cursor.sprite_middle, xm, yt)
                spr(player_cursor.sprite_corner, xr, yt, 1, 1, true, false)
                spr(player_cursor.sprite_corner, xl, yb, 1, 1, false, true)
                spr(player_cursor.sprite_middle, xm, yb, 1, 1, false, true)
                spr(player_cursor.sprite_corner, xr, yb, 1, 1, true, true)

                pal(player_cursor.color, player_cursor.color)
            end
        }
    end
}

return player_cursor
