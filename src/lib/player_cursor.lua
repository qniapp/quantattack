---@diagnostic disable: lowercase-global, global-in-nil-env

local player_cursor = new_class()

function player_cursor._init(_ENV)
  init(_ENV)
end

function player_cursor.init(_ENV)
  x, y, _tick = 3, 11, 0
end

function player_cursor.move_left(_ENV)
  if x > 1 then
    x = x - 1
  end
end

function player_cursor.move_right(_ENV, cols)
  if x < cols - 1 then
    x = x + 1
  end
end

function player_cursor.move_up(_ENV)
  if y > 7 then
    y = y - 1
  end
end

function player_cursor.move_down(_ENV, rows)
  if y < rows then
    y = y + 1
  end
end

function player_cursor.update(_ENV)
  _tick = (_tick + 1) % 28
end

function player_cursor.render(_ENV, screen_x, screen_y)
  if _tick < 14 then
    sspr(32, 32, 19, 11, screen_x - 2, screen_y - 2)
  else
    sspr(56, 32, 21, 13, screen_x - 3, screen_y - 3)
  end
end

return player_cursor
