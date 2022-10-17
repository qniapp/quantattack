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
-- _draw から呼ばれる
function player_cursor:render(board)
  local x, y, dy = board:screen_x(self.x), board:screen_y(self.y), board:dy()

  -- TODO: sspr で大きなスプライトとして描画したほうがトークン数が減る

  -- カーソルは 2 種類のスプライトの組合わせによって表示する。
  -- ┏  ┳  ┓
  --
  -- ┗  ┻  ┛
  --
  -- - 66: カーソルの四隅を表すスプライトの番号
  -- - 67: カーソルの中央 (T の字部分) を表すスプライトの番号

  local d = self._tick >= animation_frame_count and 1 or 0
  local x_left, x_middle, x_right, y_top, y_bottom = x - 5 + d, x + 4, x + 12 - d, y - 5 + d + dy, y + 4 - d + dy

  spr(66, x_left, y_top)
  spr(67, x_middle, y_top)
  spr(66, x_right, y_top, 1, 1, true, false)
  spr(66, x_left, y_bottom, 1, 1, false, true)
  spr(67, x_middle, y_bottom, 1, 1, false, true)
  spr(66, x_right, y_bottom, 1, 1, true, true)
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
