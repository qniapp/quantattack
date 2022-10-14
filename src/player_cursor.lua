require("engine/core/class")

local board_class = require("board")

-- プレイヤーのカーソル。
-- ゲートを入れ換える位置を指定するのに使われる。
local player_cursor = new_class()

-- アニメーションによって画面内のカーソルを目立たせる。
-- アニメーションは 2 コマで、ここに指定したフレーム数ごとに切り替わる。
local animation_frame_count = 14

function player_cursor:_init()
  self.x = 3
  self.y = 6
  self._tick = 0
end

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

-- カーソル移動の効果音を鳴らす
function player_cursor:sfx_move()
  sfx(0)
end

-- ゲート入れ替えの効果音を鳴らす
function player_cursor:sfx_swap()
  sfx(2)
end

-- カーソルの状態を更新
-- _update から呼ばれる
function player_cursor:update()
  self._tick = (self._tick + 1) % (animation_frame_count * 2)
end

-- カーソルを描画
-- _draw から呼ばれる
function player_cursor:render(board)
  local x = board:screen_x(self.x)
  local y = board:screen_y(self.y)
  local dy = board:dy()

  -- カーソルは 2 種類のスプライトの組合わせによって表示する。
  -- ┏  ┳  ┓
  --
  -- ┗  ┻  ┛
  --
  -- - 66: カーソルの四隅を表すスプライトの番号
  -- - 67: カーソルの中央 (T の字部分) を表すスプライトの番号

  local d = self._tick >= animation_frame_count and 1 or 0
  local x_left = x - 5 + d
  local x_middle = x + 4
  local x_right = x + 12 - d
  local y_top = y - 5 + d + dy
  local y_bottom = y + 4 - d + dy

  spr(66, x_left, y_top)
  spr(67, x_middle, y_top)
  spr(66, x_right, y_top, 1, 1, true, false)
  spr(66, x_left, y_bottom, 1, 1, false, true)
  spr(67, x_middle, y_bottom, 1, 1, false, true)
  spr(66, x_right, y_bottom, 1, 1, true, true)
end

return player_cursor
