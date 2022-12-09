---@diagnostic disable: lowercase-global, global-in-nil-env

function create_player_cursor(board)
  local cursor = setmetatable({
    _board = board,

    init = function(_ENV)
      x, y, _tick = 3, 11, 0
    end,

    move_left = function(_ENV)
      if x > 1 then
        x = x - 1
      end
    end,

    move_right = function(_ENV)
      if x < _board.cols - 1 then
        x = x + 1
      end
    end,

    move_up = function(_ENV)
      if y > 7 then
        y = y - 1
      end
    end,

    move_down = function(_ENV)
      if y < _board.rows then
        y = y + 1
      end
    end,

    update = function(_ENV)
      _tick = (_tick + 1) % 28
    end,

    render = function(_ENV)
      local screen_x, screen_y = _board:screen_x(x), _board:screen_y(y)

      if _tick >= 14 then
        sspr(32, 32, 19, 11, screen_x - 2, screen_y - 2)
      else
        sspr(56, 32, 21, 13, screen_x - 3, screen_y - 3)
      end
    end
  }, { __index = _ENV })

  cursor:init()

  return cursor
end
