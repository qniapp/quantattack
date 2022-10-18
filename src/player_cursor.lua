require("engine/core/class")

local animation_frame_count = 14

local player_cursor = new_class()
player_cursor.sfx_move = 0 -- カーソル移動の効果音
player_cursor.sfx_swap = 2 -- ゲート入れ替えの効果音

-- カーソルを左に移動
function player_cursor:move_left()
  if self.x > 1 then
    self.x = self.x - 1
  end
end

-- カーソルを右に移動
function player_cursor:move_right()
  if self.x < self._board.cols - 1 then
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
  if self.y < self._board.rows then
    self.y = self.y + 1
  end
end

-- カーソルの状態を更新
function player_cursor:update()
  self._tick = (self._tick + 1) % (animation_frame_count * 2)
end

-- カーソルを描画
function player_cursor:render()
  local x, y, dy = self._board:screen_x(self.x), self._board:screen_y(self.y), self._board:dy()

  if self._tick >= animation_frame_count then
    sspr(16, 32, 19, 11, x - 2, y - 2 + dy)
  else
    sspr(16, 48, 21, 13, x - 3, y - 3 + dy)
  end
end

function player_cursor:_init(board)
  self.x = 3
  self.y = 6
  self._tick = 0
  self._board = board
end

return player_cursor
