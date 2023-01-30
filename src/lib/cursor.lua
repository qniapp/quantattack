--- ユーザまたは QPU が操作するカーソルのクラス
cursor_class = new_class()

function cursor_class._init(_ENV)
  init(_ENV)
end

--- カーソルの初期化
function cursor_class.init(_ENV)
  x, y, _tick = 3, 6, 0
end

--- カーソルを左に移動
function cursor_class.move_left(_ENV)
  if x > 1 then
    x = x - 1
  end
end

--- カーソルを右に移動
function cursor_class.move_right(_ENV, cols)
  if x < cols - 1 then
    x = x + 1
  end
end

--- カーソルを上に移動
function cursor_class.move_up(_ENV, rows)
  if y < rows then
    y = y + 1
  end
end

--- カーソルを下に移動
function cursor_class.move_down(_ENV)
  if y > 1 then
    y = y - 1
  end
end

--- カーソルの状態を更新
function cursor_class.update(_ENV)
  _tick = (_tick + 1) % 28
end

--- カーソルを描画
function cursor_class.render(_ENV, screen_x, screen_y)
  if _tick < 14 then
    sspr(32, 32, 19, 11, screen_x - 2, screen_y - 2)
  else
    sspr(56, 32, 21, 13, screen_x - 3, screen_y - 3)
  end
end
