require("engine/core/class")

local colors = require("colors")
local board = require("board")

local player_cursor = new_class()

player_cursor.color = colors.dark_green
player_cursor.sprite_corner = 65
player_cursor.sprite_middle = 66
player_cursor.animation_frame_count = 14

function player_cursor:_init(cols, rows, x, y)
  self.x = x or 3
  self.y = y or 6
  self._cols = cols or board.default_cols
  self._rows = rows or board.default_rows
  self._tick = 0
end

function player_cursor:move_left()
  if self.x > 1 then
    self.x = self.x - 1
  end
end

function player_cursor:move_right()
  if self.x < self._cols - 1 then
    self.x = self.x + 1
  end
end

function player_cursor:move_up()
  if self.y > 1 then
    self.y = self.y - 1
  end
end

function player_cursor:move_down()
  if self.y < self._rows then
    self.y = self.y + 1
  end
end

function player_cursor:update()
  self._small = self._tick >= player_cursor.animation_frame_count
  self._tick = self._tick + 1
  self._tick = self._tick % (player_cursor.animation_frame_count * 2)
end

function player_cursor:draw(board)
  local x = board:screen_x(self.x)
  local y = board:screen_y(self.y)
  local dy = board:dy()

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

return player_cursor
