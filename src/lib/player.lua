--- プレーヤー (人間)
player_class = new_class()

function player_class._init(_ENV, _number)
  number = _number or 0
  init(_ENV)
end

--- 初期化
function player_class.init(_ENV)
  score = 0
end

--- プレーヤーの入力を更新
function player_class.update(_ENV)
  left, right, up, down, x, o = btnp(0, number), btnp(1, number), btnp(2, number), btnp(3, number), btnp(5, number), btn(4, number)
end
