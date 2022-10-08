require("engine/core/class")
require("engine/render/color")

local board_class = require("board")

-- プレイヤーのカーソル。
-- ゲートを入れ換える位置を指定するのに使われる。
local player_cursor = new_class()

-- カーソルの色。
-- ボードの端に到達したためこれ以上カーソルが動かせない場合や、
-- ゲームオーバー時に色が変わる。
local color = colors.dark_green

-- カーソルの見た目は次のようになる。
-- 2 種類のスプライトの組合わせによって表示される。
-- ┏ ┳ ┓
-- ┗ ┻ ┛
local sprite_corner = 65 -- カーソルの四隅を表すスプライト番号
local sprite_middle = 66 -- カーソルの中央 (T の字部分) を表すスプライト番号

-- アニメーションによって画面内のカーソルを目立たせる。
-- アニメーションは 2 コマで、以下のフレーム数ごとに切り替わる。
local animation_frame_count = 14

-- ボードの座標 x, y にカーソルを作る
function player_cursor:_init(x, y)
  self.x = x or 3
  self.y = y or 6
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

-- カーソルの状態を更新
-- _update から呼ばれる
function player_cursor:update()
  self._tick = self._tick + 1
  self._tick = self._tick % (animation_frame_count * 2)
end

-- カーソルを描画
-- _draw から呼ばれる
function player_cursor:render(board)
  local x = board:screen_x(self.x)
  local y = board:screen_y(self.y)
  local dy = board:dy()

  -- TODO: .cannot_swap のテスト
  if self.cannot_swap then
    pal(color, colors.red)
  end

  -- TODO: .game_over のテスト
  if self.game_over then
    pal(color, colors.dark_grey)
  end

  local d = self._tick >= animation_frame_count and 1 or 0
  local x_left = x - 5 + d
  local x_middle = x + 4
  local x_right = x + 12 - d
  local y_top = y - 5 + d + dy
  local y_bottom = y + 4 - d + dy

  spr(sprite_corner, x_left, y_top)
  spr(sprite_middle, x_middle, y_top)
  spr(sprite_corner, x_right, y_top, 1, 1, true, false)
  spr(sprite_corner, x_left, y_bottom, 1, 1, false, true)
  spr(sprite_middle, x_middle, y_bottom, 1, 1, false, true)
  spr(sprite_corner, x_right, y_bottom, 1, 1, true, true)

  pal(color, color)
end

return player_cursor
