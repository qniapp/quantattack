local board_class = require("board")

local animation_frame_count = 14

local player_cursor = {
  sfx_move = 0, -- カーソル移動の効果音
  sfx_swap = 2 -- ゲート入れ替えの効果音
}

-- カーソルを左に移動
function player_cursor:move_left()
  if self.x > 1 then
    self.x = self.x - 1
  end
end

-- カーソルを右に移動
function player_cursor:move_right()
  if self.x < board_class.cols - 1 then
    self.x = self.x + 1
  end
end

-- カーソルを上に移動
function player_cursor:move_up()
  if self.y > 1 then
    self.y = self.y - 1
  end
end

-- カーソルを下に移動
function player_cursor:move_down()
  if self.y < board_class.rows then
    self.y = self.y + 1
  end
end

-- カーソルの状態を更新
function player_cursor:update()
  self._tick = (self._tick + 1) % (animation_frame_count * 2)
end

-- カーソルを描画
function player_cursor:render(board)
  local x, y, dy = board:screen_x(self.x), board:screen_y(self.y), board:dy()

  if self._tick >= animation_frame_count then
    sspr(16, 32, 19, 11, x - 2, y - 2 + dy)
  else
    sspr(16, 48, 21, 13, x - 3, y - 3 + dy)
  end
end

function player_cursor.new()
  return {
    x = 3,
    y = 6,
    _tick = 0,
    move_left = player_cursor.move_left,
    move_right = player_cursor.move_right,
    move_up = player_cursor.move_up,
    move_down = player_cursor.move_down,
    update = player_cursor.update,
    render = player_cursor.render
  }
end

return player_cursor
