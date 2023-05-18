require("lib/effects")

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

--- ブロック (量子ゲート) クラス
block_class = new_class()
block_class.block_match_animation_frame_count = 45
block_class.block_match_delay_per_block = 8
block_class.block_swap_animation_frame_count = 3
block_class.sprites = transform({
  -- default|landing|match
  h = "0|1,1,1,2,2,2,3,3,1,1,1,1|24,24,24,25,25,25,24,24,24,26,26,26,0,0,0,27",
  x = "16|17,17,17,18,18,18,19,19,17,17,17,17|40,40,40,41,41,41,40,40,40,42,42,42,16,16,16,43",
  y = "32|33,33,33,34,34,34,35,35,33,33,33,33|56,56,56,57,57,57,56,56,56,58,58,58,32,32,32,59",
  z = "48|49,49,49,50,50,50,51,51,49,49,49,49|12,12,12,13,13,13,12,12,12,14,14,14,48,48,48,15",
  s = "4|5,5,5,6,6,6,7,7,5,5,5,5|28,28,28,29,29,29,28,28,28,30,30,30,4,4,4,31",
  t = "20|21,21,21,22,22,22,23,23,21,21,21,21|44,44,44,45,45,45,44,44,44,46,46,46,20,20,20,47",
  control = "36|37,37,37,38,38,38,39,39,37,37,37,37|60,60,60,61,61,61,60,60,60,62,62,62,36,36,36,63",
  cnot_x = "52|53,53,53,54,54,54,55,55,53,53,53,53|64,64,64,65,65,65,64,64,64,66,66,66,52,52,52,67",
  swap = "8|9,9,9,10,10,10,11,11,9,9,9,9|80,80,80,81,81,81,80,80,80,82,82,82,8,8,8,83",
  ["?"] = "98|98,98,98,98,98,98,98,98,98,98,98,98|98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98",
  ["#"] = "113|113,113,113,113,113,113,113,113,113,113,113,113|113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113"
}, function(each)
  local default, landing, match = unpack(split(each, "|"))
  return {
    default = default,
    landing = split(landing),
    match = split(match)
  }
end)

function block_class._init(_ENV, _type, _span, _height)
  type, sprite_set, span, height, _state, _timer_landing =
      _type, sprites[_type], _span or 1, _height or 1, "idle", 0
end

--- 状態が idle かどうかを返す
function block_class:is_idle()
  return self._state == "idle"
end

function block_class:is_hover()
  return self._state == "hover"
end

function block_class.is_fallable(_ENV)
  return not (type == "i" or type == "?" or is_swapping(_ENV) or is_freeze(_ENV) or is_match(_ENV))
end

function block_class:is_falling()
  return self._state == "falling"
end

function block_class.is_reducible(_ENV)
  return type ~= "i" and type ~= "?" and is_idle(_ENV)
end

function block_class:is_match()
  return self._state == "match"
end

-- おじゃまブロックが小さいブロックに分解した後の硬直中かどうか
function block_class:is_freeze()
  return self._state == "freeze"
end

function block_class:is_swapping()
  return self:_is_swapping_with_right() or self:_is_swapping_with_left()
end

function block_class:_is_swapping_with_left()
  return self._state == "swapping_with_left"
end

function block_class:_is_swapping_with_right()
  return self._state == "swapping_with_right"
end

function block_class:is_swappable_state()
  return self:is_idle() or self:is_falling()
end

function block_class:is_empty()
  return self.type == "i" and not self:is_swapping()
end

function block_class.is_single_block(_ENV)
  return type == 'h' or type == 'x' or type == 'y' or type == 'z' or type == 's' or type == 't'
end

function block_class:swap_with(direction)
  self.chain_id = nil
  self:change_state("swapping_with_" .. direction)
end

function block_class:hover(timer)
  self.timer = timer or 12
  self:change_state("hover")
end

function block_class:fall()
  --#if assert
  assert(self:is_fallable(), "block " .. self.type .. "(" .. self.x .. ", " .. self.y .. ")")
  --#endif

  if self:is_falling() then
    return
  end

  self:change_state("falling")
end

function block_class.replace_with(_ENV, other, match_index, _chain_id, garbage_span, garbage_height)
  new_block, _match_index, _tick_match, chain_id, other.chain_id, _garbage_span, _garbage_height =
      other, match_index or 0, 1, _chain_id, _chain_id, garbage_span, garbage_height

  change_state(_ENV, "match")
end

function block_class.update(_ENV)
  if is_idle(_ENV) then
    if _timer_landing > 0 then
      _timer_landing = _timer_landing - 1
    end
  elseif is_swapping(_ENV) then
    if _tick_swap < block_swap_animation_frame_count then
      _tick_swap = _tick_swap + 1
    else
      chain_id = nil
      change_state(_ENV, "idle")
    end
  elseif is_hover(_ENV) then
    if timer > 0 then
      timer = timer - 1
    else
      change_state(_ENV, "idle")
    end
  elseif is_match(_ENV) then
    if _tick_match <= block_match_animation_frame_count + _match_index * block_match_delay_per_block then
      _tick_match = _tick_match + 1
    else
      change_state(_ENV, "idle")

      if _garbage_span then
        new_block._tick_freeze = 0
        new_block._freeze_frame_count = (_garbage_span * _garbage_height - _match_index) * block_match_delay_per_block
        new_block:change_state("freeze")
      end
    end
  elseif is_freeze(_ENV) then
    if _tick_freeze < _freeze_frame_count then
      _tick_freeze = _tick_freeze + 1
    else
      change_state(_ENV, "idle")
    end
  end
end

function block_class:render(screen_x, screen_y, screen_other_x)
  local shake_dx, shake_dy, swap_screen_dx, sprite = 0, 0

  do
    local _ENV = self

    if type == "i" then
      return
    end

    swap_screen_dx = (_tick_swap or 0) * (8 / block_swap_animation_frame_count)
    if _is_swapping_with_left(_ENV) then
      swap_screen_dx = -swap_screen_dx
    end

    if is_idle(_ENV) and _timer_landing > 0 then
      sprite = sprite_set.landing[_timer_landing]
    elseif is_match(_ENV) then
      local sequence = sprite_set.match
      sprite = _tick_match <= block_match_delay_per_block and sequence[_tick_match] or sequence[#sequence]
    elseif _state == "over" then
      sprite = sprite_set.match[#sprite_set.match]
    else
      sprite = sprite_set.default
    end

    -- CNOT または SWAP の接続を描画
    if other_x and x < other_x then
      line(
        screen_x + 3,
        screen_y + 3,
        screen_other_x + 3,
        screen_y + 3,
        is_match(_ENV) and 13 or 10
      )
    end
  end

  if self.type == "?" then
    palt(0, false)
    pal(13, self.body_color)
  end

  if self._state == "over" then
    shake_dx, shake_dy = rnd(2) - 1, rnd(2) - 1
    pal(6, 9)
    pal(7, 1)
  end

  spr(sprite, screen_x + swap_screen_dx + shake_dx, screen_y + shake_dy)

  palt(0, true)
  pal(13, 13)
  pal(6, 6)
  pal(7, 7)
end

function block_class:attach(observer)
  self.observer = observer
end

function block_class.change_state(_ENV, new_state)
  _timer_landing, _tick_swap =
      is_falling(_ENV) and 12 or 0, 0

  local old_state = _state
  _state = new_state

  observer:observable_update(_ENV, old_state)
end

--#if debug
local type_string = {
  i = '_',
  control = '●',
  cnot_x = '+',
  swap = 'X'
}

local state_string = {
  idle = " ",
  swapping_with_left = "<",
  swapping_with_right = ">",
  hover = "^",
  falling = "|",
  match = "*",
  freeze = "f",
}

function block_class:_tostring()
  return (type_string[self.type] or self.type:upper()) .. state_string[self._state]
end

--#endif

--- おじゃまブロック

local garbage_block_colors = { 2, 3, 4 }
local inner_border_colors = { nil, 14, 11, 9 }

--- 新しいおじゃまブロックを作る
function garbage_block(_span, _height, _color, _chain_id, _tick_fall)
  local garbage = setmetatable({
    body_color = _color or garbage_block_colors[ceil_rnd(#garbage_block_colors)],
    chain_id = _chain_id,
    tick_fall = _tick_fall,
    dy = 0,
    first_drop = true,
    _render_box = draw_rounded_box,
    render = function(_ENV, screen_x, screen_y)
      local y0, x1, y1, _body_color =
          screen_y + (1 - height) * 8,
          screen_x + span * 8 - 2,
          screen_y + 6,
          _state ~= "over" and body_color or 9

      _render_box(screen_x, y0 + 1, x1, y1 + 1, 5)                                                    -- 影
      _render_box(screen_x, y0, x1, y1, _body_color, _body_color)                                     -- 本体
      _render_box(screen_x + 1, y0 + 1, x1 - 1, y1 - 1, _state ~= "over" and inner_border_color or 1) -- 内側の線
    end
  }, { __index = block_class("g", _span or 6, _height) })

  --#if assert
  assert(garbage.body_color == 2 or garbage.body_color == 3 or garbage.body_color == 4,
    "invalid color: " .. garbage.body_color)
  assert(2 < garbage.span, "span must be greater than 2")
  assert(garbage.span < 7, "span must be less than 7")
  --#endif

  garbage.inner_border_color = inner_border_colors[garbage.body_color]

  return garbage
end

--- ブロックのマッチパターン
reduction_rules = transform(
  transform(
  -- NOTE: ルールの行数を昇り順にならべておくことで、
  -- マッチする時に途中で探索を切り上げることができるようにする
    {
      h =
      "h\nh|,,\n,-1,|10&h\nx\nh|,,\n,-1,\n,-2,z|20&h\ny\nh|,,\n,-1,\n,-2,y|20&h\nz\nh|,,\n,-1,\n,-2,x|20&h\nswap,swap\n?,h|,,\ntrue,-2,|50&h\nx\nswap,swap\n?,h|,,\n,-1,z\ntrue,-3,|60&h\ny\nswap,swap\n?,h|,,\n,-1,y\ntrue,-3,|60&h\nswap,swap\n?,x\n?,h|,,z\ntrue,-2,\ntrue,-3,|60&h\nswap,swap\n?,y\n?,h|,,y\ntrue,-2,\ntrue,-3,|60&h\nz\nswap,swap\n?,h|,,\n,-1,x\ntrue,-3,|60&h\nswap,swap\n?,z\n?,h|,,x\ntrue,-2,\ntrue,-3,|60",
      x =
      "x\nx|,,\n,-1,|10&x,x\ncontrol,cnot_x\nx|,,\ntrue,,\n,-2,|90&x,x\ncnot_x,control\nx|,,\ntrue,,\n,-2,|90&x\ncnot_x,control\nx|,,\n,-2,|80&x\nswap,swap\n?,x|,,\ntrue,-2,|50",
      y =
      "y\ny|,,\n,-1,|10&y\nswap,swap\n?,y|,,\ntrue,-2,|50&y,x\ncontrol,cnot_x\ny|,,\ntrue,,\n,-2,|90&y,z\ncnot_x,control\ny|,,\ntrue,,\n,-2,|90",
      z =
      "z\nz|,,\n,-1,|10&z,z\ncontrol,cnot_x\n?,z|,,\ntrue,,\ntrue,-2,|90&z\ncontrol,cnot_x\nz|,,\n,-2,|80&z\nswap,swap\n?,z|,,\ntrue,-2,|50",
      s =
      "s\ns|,,\n,-1,z|10&s\nx\ns|,,\n,-1,\n,-2,x|20&s\ny\ns|,,\n,-1,\n,-2,y|20&s\nz\ns|,,\n,-1,\n,-2,|20&s\nswap,swap\n?,s|,,z\ntrue,-2,|50&s\nx\nswap,swap\n?,s|,,\n,-1,x\ntrue,-3,|60&s\ny\nswap,swap\n?,s|,,\n,-1,y\ntrue,-3,|60&s\nz\nswap,swap\n?,s|,,\n,-1,\ntrue,-3,|60&s\nswap,swap\n?,x\n?,s|,,x\ntrue,-2,\ntrue,-3,|60&s\nswap,swap\n?,y\n?,s|,,y\ntrue,-2,\ntrue,-3,|60&s\nswap,swap\n?,z\n?,s|,,\ntrue,-2,\ntrue,-3,|60",
      t =
      "t\nt|,,\n,-1,s|10&t\ns\nt|,,\n,-1,\n,-2,z|20&t\nswap,swap\n?,t|,,s\ntrue,-2,|50&t\nz\ns\nt|,,\n,-1,\n,-2,\n,-3,|30&t\ns\nz\nt|,,\n,-1,\n,-2,\n,-3,|30&t\ns\nswap,swap\n?,t|,,\n,-1,z\ntrue,-3,|60&t\nswap,swap\n?,s\n?,t|,,z\ntrue,-2,\ntrue,-3,|60&t\nswap,swap\n?,z\n?,s\n?,t|,,\ntrue,-2,\ntrue,-3,\ntrue,-4,|70&t\nswap,swap\n?,s\n?,z\n?,t|,,\ntrue,-2,\ntrue,-3,\ntrue,-4,|70&t\nz\nswap,swap\n?,s\n?,t|,,\n,-1,\ntrue,-3,\ntrue,-4,|70&t\ns\nswap,swap\n?,z\n?,t|,,\n,-1,\ntrue,-3,\ntrue,-4,|70&t\nz\ns\nswap,swap\n?,t|,,\n,-1,\n,-2,\ntrue,-4,|70&t\ns\nz\nswap,swap\n?,t|,,\n,-1,\n,-2,\ntrue,-4,|70",
      control = "control,cnot_x\nswap,swap\ncnot_x,control|,,\ntrue,,\n,-2,\ntrue,-2,|200",
      cnot_x =
      "cnot_x,control\ncnot_x,control|,,\ntrue,,\n,-1,\ntrue,-1,|40&cnot_x,control\ncontrol,cnot_x\ncnot_x,control|,,\ntrue,,\n,-1,\ntrue,-1,\n,-2,swap\ntrue,-2,swap|100",
      swap = "swap,swap\nswap,swap|,,\ntrue,,\n,-1,\ntrue,-1,|300"
    },
    function(rule_string) return split(rule_string, "&") end),
  function(gate_rules)
    return transform(
      gate_rules,
      function(each)
        local pattern, reduce_to, score = unpack(split(each, "|"))

        return {
          transform(split(pattern, "\n"), split),
          transform(split(reduce_to, "\n"), function(to)
            local attrs = split(to)
            return {
              dx = attrs[1] ~= "",
              dy = attrs[2] == "" and nil or tonum(attrs[2]),
              block_type = attrs[3] == "" and 'i' or attrs[3]
            }
          end),
          tonum(score)
        }
      end
    )
  end
)

--- 待機中のおじゃまブロック
pending_garbage_blocks_class = new_class()

function pending_garbage_blocks_class._init(_ENV)
  all = {}
end

function pending_garbage_blocks_class.add_garbage(_ENV, span, height, chain_id)
  -- 同じ chain_id のおじゃまブロックをまとめる
  for _, each in pairs(all) do
    if each.chain_id == chain_id and each.span == 6 then
      if each.height <= height then
        -- 同じ chain_id でより低いおじゃまブロックがすでにプールに入っている場合、消す
        del(all, each)
      else
        -- 同じ chain_id でより高いおじゃまブロックがすでにプールに入っている場合、何もしない
        return
      end
    end
  end

  add(all, garbage_block(span, height, nil, chain_id, 60))
end

--- おじゃまブロックの相殺
function pending_garbage_blocks_class.offset(_ENV, chain_count)
  local offset_height = chain_count

  for _, each in pairs(all) do
    if each.span == 6 then
      if not each.tick_fall then
        if each.height > offset_height then
          each.height = each.height - offset_height
          break
        else
          offset_height = offset_height - each.height
          del(all, each)
        end
      end
    else
      offset_height = offset_height - 1
      del(all, each)
    end
  end

  return offset_height
end

function pending_garbage_blocks_class.update(_ENV, board)
  local first_garbage_block = all[1]

  if first_garbage_block then
    if first_garbage_block.tick_fall > 0 then
      if first_garbage_block.tick_fall < 30 then
        first_garbage_block.dy = ceil_rnd(2) - 1
      end
      first_garbage_block.tick_fall = first_garbage_block.tick_fall - 1
    else
      -- おじゃまブロックが幅いっぱいの場合、x = 1
      -- そうでない場合、
      -- x + span - 1 <= board.cols を満たす x をランダムに決める
      local x, y = first_garbage_block.span == board.cols and
          1 or
          ceil_rnd(board.cols - first_garbage_block.span + 1),
          board.rows + 1

      if board:is_block_empty(x, y) then
        -- おじゃまブロックを落とす
        board:put(x, y, first_garbage_block)
        del(all, first_garbage_block)
      end
    end
  end
end

function pending_garbage_blocks_class.render(_ENV, board)
  for i, each in pairs(all) do
    if i < 6 then
      local x0, y0 = board.offset_x + 1 + (i - 1) * 9, each.dy

      if each.tick_fall then
        pal(7, each.inner_border_color)
        pal(6, each.inner_border_color)
      end

      if each.span < 6 then
        draw_rounded_box(x0, y0 + 4, x0 + 12, y0 + 9, 7, 7)
        draw_rounded_box(x0 + 1, y0 + 5, x0 + 11, y0 + 8, 0, 0)
      else
        draw_rounded_box(x0, y0 + 1, x0 + 12, y0 + 9, 7, 7)
        draw_rounded_box(x0 + 1, y0 + 2, x0 + 11, y0 + 8, 0, 0)

        cursor(x0 + 5, y0 + 3)
        print(each.height, 6)
      end

      pal()
    end
  end
end

--- ボードのクラス
board_class = new_class()

function board_class._init(_ENV, _cursor, __offset_x, _cols)
  cursor, _offset_x, show_top_line =
      _cursor or cursor_class(), __offset_x, true
  init(_ENV, _cols)
end

-- ボードの初期化
function board_class.init(_ENV, _cols)
  -- サイズ関係
  cols, rows = _cols or 6, 17

  -- 画面上のサイズと位置
  width, height, offset_x, raised_dots =
      cols * 8, (rows - 1) * 8, _offset_x or 11, 0

  -- board の状態
  state, win, lose, timeup, top_block_y, _changed, show_gameover_menu, done_over_fx =
      "play", false, false, false, 0, false, false, false

  -- ゲームオーバーの線 etc.
  top_line_start_x, freeze_timer = 0, 0

  _chain_count, _topped_out_frame_count, _topped_out_delay_frame_count, _bounce_speed,
  _bounce_screen_dy =
      {}, 0, 600, 0, 0

  -- 各種ブロックの取得
  blocks, reducible_blocks, _garbage_blocks, contains_garbage_match_block = {}, {}, {}, false

  tick, steps, pending_garbage_blocks, _flash_col_timer, _flash_col_colors, _check_hover_flag, _reduce_cache,
  _is_block_fallable_cache =
      0, 0, pending_garbage_blocks_class(), {}, split("1,1,1,1,1,1,5,5,5,5,5,13,13,7"), {}, {}, {}

  for y = 0, rows do
    reducible_blocks[y], _check_hover_flag[y] = {}, {}
  end

  cursor:init()
end

function board_class.block_at(_ENV, x, y)
  if blocks[y] == nil or blocks[y][x] == nil then
    put(_ENV, x, y, block_class("i"))
  end

  return blocks[y][x]
end

function board_class.put_random_blocks(_ENV)
  for y = 0, 8 do
    for x = 1, cols do
      -- y = 0 (次のブロック) と、y = 1 .. 4 (下から 4 行) はブロックで埋める
      -- y >= 5 の行は確率的にブロックを置く
      if y < 5 or
          (rnd(1) > 0.2 and (not is_block_empty(_ENV, x, y - 1))) then
        repeat
          put(_ENV, x, y, _random_single_block(_ENV))
        until #reduce(_ENV, x, y, true).to == 0
      end
    end
  end
end

function board_class.reduce_blocks(_ENV, game, player, other_board)
  local chain_xy, combo_count = {}

  for y = #reducible_blocks, 1, -1 do
    for x, _ in pairs(reducible_blocks[y] or {}) do
      local reduction = reduce(_ENV, x, y)

      if player then
        game.reduce_callback(
          reduction.score,
          player,
          _ENV,
          reduction.contains_swap
        )
      end

      if #reduction.to > 0 then
        local chain_id = reduction.chain_id

        -- 新しい chain_id の場合 _chain_count を 1 に初期化する
        if _chain_count[chain_id] == nil then
          _chain_count[chain_id] = 1
        else
          _chain_count[chain_id] = _chain_count[chain_id] + 1
          chain_xy[chain_id] = { x = x, y = y }
        end

        if combo_count and game.combo_callback then
          -- 同時消し
          combo_count = combo_count + #reduction.to
          game.combo_callback(
            combo_count,
            { screen_x(_ENV, x), screen_y(_ENV, y) },
            player,
            _ENV,
            other_board
          )
        else
          combo_count = #reduction.to
        end

        for index, r in pairs(reduction.to) do
          sfx(35)

          local dx, dy, new_block = r.dx and reduction.dx or 0, r.dy or 0, block_class(r.block_type)

          if new_block.type == "swap" or new_block.type == "cnot_x" or new_block.type == "control" then
            new_block.other_x = x + (r.dx and 0 or reduction.dx)
          end

          if blocks[y + dy] == nil then
            put(_ENV, y + dy, x + dx, block_class("i"))
          end
          blocks[y + dy][x + dx]:replace_with(new_block, index, chain_id)
          _flash_col_timer[x + dx] = #_flash_col_colors + 1

          -- ブロックが消える、または変化するとき、その上にあるブロックすべてに chain_id をセット
          for chainable_y = y + dy + 1, #blocks do
            local block_to_fall = blocks[chainable_y][x + dx]
            if block_to_fall.type ~= "i" then
              if block_to_fall:is_match() then
                goto next_reduction
              end
              block_to_fall.chain_id = chain_id
            end
          end

          ::next_reduction::
        end
      end
    end
  end

  -- おじゃまブロックのマッチ
  repeat
    local matched_garbage_block_count = 0

    for _, each in pairs(_garbage_blocks) do
      if each:is_idle() then
        local x, y, garbage_span, garbage_height = each.x, each.y, each.span, each.height

        -- 隣接ブロック adj_x, adj_y がマッチ中であるかを返す。
        local match_with = function(adj_x, adj_y)
          if adj_y < 1 or adj_x < 1 or cols < adj_x then
            return false
          end

          local adjacent_block = blocks[adj_y][adj_x]

          if not adjacent_block:is_match() then
            return false
          end

          if adjacent_block.type == "?" then
            if each.body_color == adjacent_block.body_color then
              each.chain_id = adjacent_block.chain_id
              return true
            end
          else
            each.chain_id = adjacent_block.chain_id
            return true
          end

          return false
        end

        --          ██ ██ ██ ██  y+garbage_height
        --         ┌───────────┐
        --         │           │
        --         │           │
        -- x,y ──▶ │ g         │
        --         └───────────┘
        --          ██ ██ ██ ██  y-1
        --
        -- おじゃまブロックの下と上にマッチ中のブロックがあるかどうか調べる
        --
        for gx = x, x + garbage_span - 1 do
          if match_with(gx, y + garbage_height) or
              match_with(gx, y - 1) then
            matched_garbage_block_count = matched_garbage_block_count + 1
            goto matched
          end
        end

        --    ┌───────────┐
        --  ██│           │██
        --  ██│           │██
        --  ██│ g         │██
        --    └─▲─────────┘
        -- x-1  │          x+garbage_span
        --     x,y
        --
        -- おじゃまブロックの左と右にマッチ中のブロックがあるかどうか調べる
        for dy = 0, garbage_height - 1 do
          if match_with(x - 1, y + dy) or
              match_with(x + garbage_span, y + dy) then
            matched_garbage_block_count = matched_garbage_block_count + 1
            goto matched
          end
        end

        goto next_garbage_block

        ::matched::
        for dx = 0, garbage_span - 1 do
          for dy = 0, garbage_height - 1 do
            -- 1. おじゃまブロック全体に ? ブロックをしきつめる
            garbage_match_block = block_class("?")
            garbage_match_block.body_color = each.body_color
            put(_ENV, x + dx, y + dy, garbage_match_block)

            -- 2. 以下のようにブロックを入れ換える
            --
            --                    ┌─────────────┐
            --                    │ i  i  i  i  │
            -- new garbage head ──┼▶g  i  i  i  │
            --       (x=0,dy=1)   │ ██ ██ ██ ██ │ random block (dy=0)
            --                    └─────────────┘
            blocks[y + dy][x + dx]:replace_with(
              dy == 0 and _random_single_block(_ENV) or
              ((dy == 1 and dx == 0) and
              garbage_block(garbage_span, garbage_height - 1, each.body_color) or
              block_class("i")),
              dx + dy * garbage_span,
              dy == 0 and each.chain_id or nil,
              garbage_span,
              garbage_height
            )
          end
        end
      end

      ::next_garbage_block::
    end
  until matched_garbage_block_count == 0

  -- 連鎖
  for chain_id, xy in pairs(chain_xy) do
    local coord = { screen_x(_ENV, xy.x), screen_y(_ENV, xy.y) }

    if game and game.chain_callback then
      if #pending_garbage_blocks.all > 1 then
        local offset_height_left =
            game.block_offset_callback(
              _chain_count[chain_id],
              coord,
              player,
              _ENV,
              other_board
            )

        -- 相殺しても残っていれば、相手に攻撃
        if offset_height_left > 0 then
          game.chain_callback(
            chain_id,
            _chain_count[chain_id],
            coord,
            player,
            _ENV,
            other_board
          )
        end
      else
        game.chain_callback(
          chain_id,
          _chain_count[chain_id],
          coord,
          player,
          _ENV,
          other_board
        )
      end
    end
  end
end

function board_class.reduce(_ENV, x, y, include_next_blocks)
  if include_next_blocks then
    return _reduce_nocache(_ENV, x, y, true)
  else
    return _memoize(_ENV, _reduce_nocache, _reduce_cache, x, y)
  end
end

function board_class._reduce_nocache(_ENV, x, y, include_next_blocks)
  local reduction, block = { to = {}, score = 0 }, blocks[y][x]
  local rules = reduction_rules[block.type] or {}

  for _, rule in pairs(rules) do
    -- other_x と dx を決める
    local block_pattern_rows, other_x, dx = rule[1]

    if (include_next_blocks and y - #block_pattern_rows < -1) or
        (not include_next_blocks and y - #block_pattern_rows < 0) then
      return reduction
    end

    for i, block_types in pairs(block_pattern_rows) do
      if y - i + 1 < 0 then
        goto next_rule
      end

      -- other_x と dx を決める際に、パターンにマッチしないブロックがあれば
      -- 先にここではじいておく
      if block_types[1] ~= "?" then
        if reducible_block_at(_ENV, x, y - i + 1).type ~= block_types[1] then
          goto next_rule
        end
      end

      if block_types[2] then
        local current_block = reducible_block_at(_ENV, x, y - i + 1)

        if current_block.other_x then
          if current_block.type == block_types[1] then
            other_x = current_block.other_x
            dx = other_x - x
            goto check_match
          else
            goto next_rule
          end
        end
      end
    end

    ::check_match::
    -- chainable フラグがついたブロックがマッチしたブロックの中に 1 個でも含まれていたら連鎖
    local chain_id, contains_swap = x .. "," .. y, false

    -- マッチするかチェック
    for i, block_types in pairs(block_pattern_rows) do
      local current_y = y - i + 1

      if current_y < 0 then
        goto next_rule
      end

      if block_types[1] ~= "?" then
        local block1 = reducible_block_at(_ENV, x, current_y)

        if block1.type ~= block_types[1] or
            (block1.other_x and block1.other_x ~= other_x) then
          goto next_rule
        end

        -- SWAP を含むパターンの点数かどうかをチェック
        if rule[3] == 50 or rule[3] == 60 or rule[3] == 70 or rule[3] == 200 or rule[3] == 300 then
          contains_swap = true
        end

        if block1.chain_id then
          chain_id = block1.chain_id
        end
      end

      if block_types[2] then
        local block2 = reducible_block_at(_ENV, other_x, current_y)
        if block2.type ~= block_types[2] or
            (block2.other_x and block2.other_x ~= x) then
          goto next_rule
        end

        if block2.chain_id then
          chain_id = block2.chain_id
        end
      end
    end

    reduction = {
      to = rule[2],
      dx = dx,
      score = rule[3],
      chain_id = chain_id,
      contains_swap = contains_swap
    }
    goto matched

    ::next_rule::
  end

  ::matched::
  return reduction
end

-- ボード上の X 座標を画面上の X 座標に変換
function board_class.screen_x(_ENV, x)
  return offset_x + (x - 1) * 8
end

-- ボード上の Y 座標を画面上の Y 座標に変換
-- 一行目は表示しないことに注意
function board_class.screen_y(_ENV, y)
  return 128 - y * 8 - raised_dots + _bounce_screen_dy
end

function board_class._random_single_block(_ENV)
  return block_class(rnd(split('h,x,y,z,s,t')))
end

-------------------------------------------------------------------------------
-- board の状態
-------------------------------------------------------------------------------

function board_class.is_busy(_ENV)
  for x = 1, cols do
    for y = 1, #blocks do
      local block = blocks[y][x]
      if not (block:is_idle() or block:is_swapping()) then
        return true
      end
    end
  end

  return false
end

function board_class.is_game_over(_ENV)
  return state == "over"
end

-------------------------------------------------------------------------------
-- board の操作
-------------------------------------------------------------------------------

function board_class.reducible_block_at(_ENV, x, y)
  --#if assert
  assert(1 <= x and x <= cols, "x = " .. x)
  assert(0 <= y, "y = " .. y)
  --#endif

  return reducible_blocks[y][x] or block_class("i")
end

-- x, y に block を配置し、block.x と block.y をセットする
function board_class.put(_ENV, x, y, block)
  --#if assert
  assert(1 <= x and x <= cols, "invalid x value: x = " .. x)
  assert(0 <= y, "invalid x value: y = " .. y)
  assert(block ~= nil, "block should not be nil")
  --#endif

  block.x, block.y = x, y

  -- もし blocks[y] == nil の場合、I で初期化する
  for tmp_y = 0, y + block.height do
    -- 新しい行 y を追加
    -- TODO: 後で別関数に切り出す
    if blocks[tmp_y] == nil then
      blocks[tmp_y] = {}
      for tmp_x = 1, cols do
        local i_block = block_class("i")
        blocks[tmp_y][tmp_x] = i_block
        i_block.x, i_block.y = tmp_x, tmp_y
        i_block:attach(_ENV)
      end
    end

    if _check_hover_flag[tmp_y] == nil then
      _check_hover_flag[tmp_y] = {}
    end
  end

  -- おじゃまブロックを分解する時 (= garbage_match ブロックと置き換える時)、
  -- おじゃまブロックキャッシュから消す
  if blocks[y][x] and blocks[y][x].type == "g" then
    del(_garbage_blocks, blocks[y][x])
  end

  -- 新たにおじゃまブロックを置く場合
  -- おじゃまブロックキャッシュに追加する
  if block.type == "g" then
    add(_garbage_blocks, block)
  end

  blocks[y][x] = block
  block:attach(_ENV)
  observable_update(_ENV, block)

  _check_hover_flag[y][x] = true
end

function board_class.remove_block(_ENV, x, y)
  put(_ENV, x, y, block_class("i"))
end

function board_class.send_garbage(_ENV, chain_id, span, _height)
  pending_garbage_blocks:add_garbage(span, _height, chain_id)
end

function board_class.insert_blocks_at_bottom(_ENV)
  shift_all_blocks_up(_ENV)

  -- min_cnot_probability = 0.3
  -- max_cnot_probability = 0.7
  if rnd(1) < min(0.3 + flr(steps / 5) * 0.1, 0.7) then
    local control_x, cnot_x_x

    repeat
      control_x, cnot_x_x = ceil_rnd(cols), ceil_rnd(cols)
    until control_x ~= cnot_x_x

    local control_block = block_class("control")
    control_block.other_x = cnot_x_x

    local cnot_x_block = block_class("cnot_x")
    cnot_x_block.other_x = control_x

    put(_ENV, control_x, 0, control_block)
    put(_ENV, cnot_x_x, 0, cnot_x_block)
  end

  -- 最下段の空いている部分に新しいブロックを置く
  for x = 1, cols do
    if is_block_empty(_ENV, x, 0) then
      repeat
        put(_ENV, x, 0, _random_single_block(_ENV))
      until #reduce(_ENV, x, 1, true).to == 0
    end
  end

  steps = steps + 1
end

function board_class.shift_all_blocks_up(_ENV)
  for y = #blocks, 0, -1 do
    for x = 1, cols do
      if not is_block_empty(_ENV, x, y) then
        put(_ENV, x, y + 1, blocks[y][x])
        remove_block(_ENV, x, y)
      end
    end
  end
end

--- x_left, y と x_left + 1, y のブロックを入れ替える
-- 入れ替えできる場合は true を、そうでない場合は false を返す
function board_class.swap(_ENV, x_left, y)
  local x_right = x_left + 1
  local left_block, right_block = block_at(_ENV, x_left, y), block_at(_ENV, x_right, y)

  -- 入れ替えできない場合
  --  1. 左または右の状態が idle や falling でない
  --  2. 左または右が # ブロック
  --  3. 左または右がおじゃまブロックの一部
  --  4. CNOT または SWAP の一部と単一ブロックを入れ替えようとしている場合
  if not (left_block:is_swappable_state() and right_block:is_swappable_state()) or
      (left_block.type == "#" or right_block.type == "#") or
      (_is_part_of_garbage(_ENV, x_left, y) or _is_part_of_garbage(_ENV, x_right, y)) or
      (left_block.other_x and left_block.other_x < x_left and not is_block_empty(_ENV, x_right, y)) or
      (not is_block_empty(_ENV, x_left, y) and right_block.other_x and x_right < right_block.other_x) then
    return false
  end

  left_block:swap_with("right")
  right_block:swap_with("left")
  return true
end

function board_class.update(_ENV, game, player, other_board)
  pending_garbage_blocks:update(_ENV)
  _update_bounce(_ENV)
  freeze_timer = max(freeze_timer - 1, 0)
  if freeze_timer == 0 then
    top_line_start_x = (top_line_start_x + 4) % 96
  end

  if state == "play" then
    if win or lose then
      state, tick_over = "over", 0
      sfx(17)
    elseif timeup then
      state, tick_over = "over", 0
    else
      _update_game(_ENV, game, player, other_board)
    end
  elseif state == "over" then
    if lose then
      if tick_over == 20 and not done_over_fx then
        sfx(18)
      end

      for x = 1, cols do
        for y = 0, #blocks do
          if tick_over == 0 then
            blocks[y][x]._state = "over"
          elseif tick_over == 20 and not done_over_fx then
            blocks[y][x] = block_class("i")
            particles:create(
              { screen_x(_ENV, x), screen_y(_ENV, y) },
              "5,5,9,7,,,-0.03,-0.03,40|5,5,9,7,,,-0.03,-0.03,40|4,4,9,7,,,-0.03,-0.03,40|4,4,2,5,,,-0.03,-0.03,40|4,4,6,7,,,-0.03,-0.03,40|2,2,9,7,,,-0.03,-0.03,40|2,2,9,7,,,-0.03,-0.03,40|2,2,6,5,,,-0.03,-0.03,40|2,2,6,5,,,-0.03,-0.03,40|0,0,2,5,,,-0.03,-0.03,40"
            )
          end
        end
      end
    end

    tick_over = tick_over + 1

    if tick_over > 20 then
      done_over_fx = true
    end
  end

  -- 列フラッシュのタイマーをそれぞれ -1 する
  _flash_col_timer = transform(_flash_col_timer, function(each)
    return each and max(each - 1, 0) or 0
  end)

  tick = tick + 1
end

function board_class.render(_ENV)
  -- 列フラッシュを描画
  for x = 1, cols do
    local col_start_x, flash_color = screen_x(_ENV, x), _flash_col_colors[_flash_col_timer[x]]

    if flash_color then
      rectfill(
        col_start_x,
        0,
        col_start_x + 6,
        height,
        flash_color
      )
    end
  end

  -- ブロックの描画
  for x = 1, cols do
    for y = 0, rows do
      local scr_x, scr_y, block = screen_x(_ENV, x), screen_y(_ENV, y), block_at(_ENV, x, y)

      block:render(scr_x, scr_y, block.other_x and screen_x(_ENV, block.other_x))

      -- 一番下のマスクを描画
      if y == 0 and not is_game_over(_ENV) then
        spr(97, scr_x, scr_y)
      end
    end
  end

  -- 残り時間ゲージの描画
  if is_topped_out(_ENV) then
    local time_left_height, gauge_x =
        (_topped_out_delay_frame_count - _topped_out_frame_count) / _topped_out_delay_frame_count * 128,
        offset_x < 64 and offset_x + 50 or offset_x - 4

    if time_left_height > 0 then
      rectfill(
        gauge_x,
        128 - time_left_height,
        gauge_x + 1,
        127,
        freeze_timer > 0 and 12 or 8
      )
    end
  end

  -- 待機中のおじゃまブロックを描画
  pending_garbage_blocks:render(_ENV)

  -- ブロック上限の線を描画
  if not is_game_over(_ENV) then
    if show_top_line then
      if top_line_start_x < 73 then
        line(
          max(offset_x - 1, offset_x + top_line_start_x - 25),
          40,
          min(offset_x + 48, offset_x + top_line_start_x + 5),
          40,
          freeze_timer > 0 and 12 or (is_topped_out(_ENV) and 8 or 1)
        )
      end
    end

    -- カーソルを描画
    cursor:render(screen_x(_ENV, cursor.x), screen_y(_ENV, cursor.y))
  elseif (win or lose) and tick_over > 20 and #particles.all == 0 then
    -- WIN! または LOSE を描画
    sspr(
      win and 0 or 48,
      96,
      48,
      24,
      win and offset_x or offset_x + 3 * sin(tick % 60 / 60),
      win and 40 + 3 * sin(tick % 60 / 60) or 43
    )
  end

  -- try again, title を描画
  if show_gameover_menu then
    spr(99, offset_x, 97)
    print_outlined("try again", offset_x + 11, 98, 1, 7)

    spr(112, offset_x, 110)
    print_outlined("title", offset_x + 11, 111, 1, 7)
  end
end

function board_class.is_topped_out(_ENV)
  return screen_y(_ENV, top_block_y) - _bounce_screen_dy <= 40
end

function board_class._update_game(_ENV, game, player, other_board)
  if is_topped_out(_ENV) then
    if not is_busy(_ENV) and freeze_timer == 0 then
      _topped_out_frame_count = _topped_out_frame_count + 1

      if _topped_out_frame_count >= _topped_out_delay_frame_count then
        lose = true
      end
    end
  else
    _topped_out_frame_count = 0
  end

  if _changed then
    reduce_blocks(_ENV, game, player, other_board)
    _changed = false
  end

  -- 落下と更新処理をすべてのブロックに対して行う。
  -- あわせて top_block_y も更新
  --
  -- swap などのペアとなるブロックを正しく落とすために、
  -- 一番下の行から上に向かって順に処理
  top_block_y, contains_garbage_match_block = 0, false

  for y = 1, #blocks do
    for x = 1, cols do
      local block = blocks[y][x]

      block:update()

      if block.type ~= "i" then
        if block.type == "?" then
          contains_garbage_match_block = true
        end

        -- 落下できるブロックをホバー状態にする
        if not block:is_falling() and
            not block:is_hover() and
            is_block_fallable(_ENV, x, y) then
          if not block.other_x then -- 単体ブロックとおじゃまゲート
            block:hover()
            if y > 1 and blocks[y - 1][x]:is_hover() then
              block.timer = blocks[y - 1][x].timer
            end
          else -- CNOT または SWAP
            if x < block.other_x and is_block_fallable(_ENV, block.other_x, y) then
              block:hover()
              blocks[y][block.other_x]:hover(block.timer + 1)
            end
          end
        end

        -- ホバー中のブロックに乗ったブロックをホバー状態にする
        if _check_hover_flag[y][x] then
          _check_hover_flag[y][x] = false

          if not block:is_hover() then
            local hover_timer = propagatable_hover_timer(_ENV, x, y)
            if hover_timer then
              if not block.other_x then
                -- 単体ブロックとおじゃまゲート
                block:hover(hover_timer)
              elseif x < block.other_x then
                -- CNOT または SWAP
                block:hover(hover_timer)
                blocks[y][block.other_x]:hover(hover_timer + 1)
              end
            end
          end
        end

        -- top_block_y を更新
        if block.type == "g" then
          if not block.first_drop and top_block_y < y + block.height - 1 then
            top_block_y = y + block.height - 1
          end
        elseif top_block_y < y then
          top_block_y = y
        end

        if block:is_idle() and block.chain_id and blocks[y - 1][x].chain_id == nil then
          block.chain_id = nil
        end

        if block:is_falling() then
          if not is_block_fallable(_ENV, x, y) then
            if block.type == "g" then
              bounce(_ENV)
              sfx(9)
              block.first_drop = false
            end

            block:change_state("idle")

            if block.other_x and x < block.other_x then
              local other_block = blocks[y][block.other_x]
              other_block:change_state("idle")
            end
          else
            if is_block_empty(_ENV, x, y - 1) then
              -- 落下中のブロックをひとつ下に移動
              if not block.other_x then
                remove_block(_ENV, x, y)
                put(_ENV, x, y - 1, block)
              elseif x < block.other_x then
                remove_block(_ENV, x, y)
                put(_ENV, x, y - 1, block)

                local other_block = blocks[y][block.other_x]
                other_block._state = "falling"
                remove_block(_ENV, block.other_x, y)
                put(_ENV, block.other_x, y - 1, other_block)
              end
            end
          end
        end
      end
    end
  end

  for chain_id, _ in pairs(_chain_count) do
    -- 連鎖可能フラグ (chain_id) の立ったブロックが 1 つもなかった場合、
    -- _chain_count をリセット
    for x = 1, cols do
      for y = 1, #blocks do
        if blocks[y][x].chain_id == chain_id then
          goto next_chain_id
        end
      end
    end
    _chain_count[chain_id] = nil

    ::next_chain_id::
  end
end

--- bounce エフェクトを開始
function board_class.bounce(_ENV)
  _bounce_screen_dy, _bounce_speed = 0, -4
end

function board_class._update_bounce(_ENV)
  if _bounce_speed ~= 0 then
    _bounce_speed = _bounce_speed + 0.9
    _bounce_screen_dy = _bounce_screen_dy + _bounce_speed

    if _bounce_screen_dy > 0 then
      _bounce_screen_dy, _bounce_speed = 0, -_bounce_speed
    end
  end
end

--- x, y が空かどうかを返す
-- おじゃまユニタリと SWAP, CNOT ブロックも考慮する
function board_class.is_block_empty(_ENV, x, y)
  --#if assert
  assert(0 < x and x <= cols, "x = " .. x)
  assert(0 <= y, "y = " .. y)
  --#endif

  return block_at(_ENV, x, y):is_empty() and
      not (_is_part_of_garbage(_ENV, x, y) or
      _is_part_of_cnot(_ENV, x, y) or
      _is_part_of_swap(_ENV, x, y))
end

-- x, y がおじゃまブロックの一部であるかどうかを返す
function board_class._is_part_of_garbage(_ENV, x, y)
  return _garbage_head_block(_ENV, x, y) ~= nil
end

function board_class._block_or_its_head_block(_ENV, x, y)
  return _garbage_head_block(_ENV, x, y) or
      _cnot_head_block(_ENV, x, y) or
      _swap_head_block(_ENV, x, y) or
      blocks[y][x]
end

-- x, y がおじゃまブロックの一部であった場合、
-- おじゃまブロック先頭のブロックを返す
-- 一部でない場合は nil を返す
function board_class._garbage_head_block(_ENV, x, y)
  for _, each in pairs(_garbage_blocks) do
    local garbage_x, garbage_y = each.x, each.y
    if garbage_x <= x and x <= garbage_x + each.span - 1 and     -- 幅に x が含まれる
        garbage_y <= y and y <= garbage_y + each.height - 1 then -- 高さに y が含まれる
      return each
    end
  end

  return nil
end

-- x, y が CNOT の一部であるかどうかを返す
function board_class._is_part_of_cnot(_ENV, x, y)
  return _cnot_head_block(_ENV, x, y) ~= nil
end

-- x, y が CNOT の一部であった場合、
-- CNOT 左端のブロック (control または cnot_x) を返す
-- 一部でない場合は nil を返す
function board_class._cnot_head_block(_ENV, x, y)
  for tmp_x = 1, x - 1 do
    local block = blocks[y][tmp_x]

    if (block.type == "cnot_x" or block.type == "control") and x < block.other_x then
      return block
    end
  end

  local block = blocks[y][x]
  return (block.type == "cnot_x" or block.type == "control") and block or nil
end

-- x, y が SWAP ペアの一部であるかどうかを返す
function board_class._is_part_of_swap(_ENV, x, y)
  return _swap_head_block(_ENV, x, y) ~= nil
end

-- x, y が SWAP ペアの一部であった場合、
-- SWAP ペア左端のブロックを返す
-- 一部でない場合は nil を返す
function board_class._swap_head_block(_ENV, x, y)
  for tmp_x = 1, x - 1 do
    local block = blocks[y][tmp_x]

    if block.type == "swap" and x < block.other_x then
      return block
    end
  end

  local block = blocks[y][x]
  return block.type == "swap" and block or nil
end

--- ブロック x, y の直下のブロックでホバー状態にあるもののうち、
-- timer の最大値を取得する。
-- 直下のブロックが一つもなかった場合は nil を返す。
--
-- x, y で指定するブロックは X などの単一ブロックだけでなく、
-- CNOT, SWAP, おじゃまゲートもある。
-- このため、直下のブロックは複数の場合もある。
function board_class.propagatable_hover_timer(_ENV, x, y)
  local block, hover_timer = blocks[y][x], 0

  -- y が最下段、または next block の場合、
  -- またはブロックが落下可能でない状態の場合、
  -- nil を返す
  if y < 2 or not block:is_fallable() then
    return nil
  end

  for_all_nonempty_blocks_below(_ENV, x, y, function(each)
    if each:is_hover() and hover_timer < each.timer then
      hover_timer = each.timer
    end
  end)

  return hover_timer > 0 and hover_timer or nil
end

-- ブロック x, y が x, y - 1 に落とせるかどうかを返す
function board_class.is_block_fallable(_ENV, x, y)
  return _memoize(_ENV, _is_block_fallable_nocache, _is_block_fallable_cache, x, y)
end

function board_class._is_block_fallable_nocache(_ENV, x, y)
  local block, fallable = blocks[y][x], true

  if y < 2 or not block:is_fallable() then
    return false
  end

  for_all_nonempty_blocks_below(_ENV, x, y, function(each)
    if not each:is_falling() then
      fallable = false
    end
  end)

  return fallable
end

-- x, y で指定するブロックの下にあるすべてのブロックに対して、f を適用する
function board_class.for_all_nonempty_blocks_below(_ENV, x, y, f)
  local block = blocks[y][x]

  -- ブロックの幅 (x 座標の start と end) を得る
  local start_x, end_x = x, x + block.span - 1
  if block.other_x then
    start_x, end_x = min(x, block.other_x), max(x, block.other_x)
  end

  for i = start_x, end_x do
    if is_block_empty(_ENV, i, y - 1) then
      goto next_block
    end

    f(_block_or_its_head_block(_ENV, i, y - 1))

    ::next_block::
  end
end

-- ボード内にあるいずれかのブロックが更新された場合に呼ばれる。
-- _changed フラグを立て各種キャッシュも更新・クリアする。
function board_class.observable_update(_ENV, block, old_state)
  local x, y = block.x, block.y

  if old_state == "swapping_with_right" and block:is_idle() then
    local new_x = x + 1
    local right_block = blocks[y][new_x]

    --#if assert
    assert(right_block:_is_swapping_with_left(), right_block._state)
    --#endif

    if right_block.type ~= "i" then
      particles:create(
        { screen_x(_ENV, x) - 2, screen_y(_ENV, y) + 3 },
        "1,1,10,10,-1,-0.8,0.05,0.05,3|1,1,10,10,-1,0,0.05,0,5|1,1,10,10,-1,0.8,0.05,-0.05,3"
      )
    end
    if block.type ~= "i" then
      particles:create(
        { screen_x(_ENV, new_x) + 10, screen_y(_ENV, y) + 3 },
        "1,1,10,10,1,-0.8,-0.05,0.05,3|1,1,10,10,1,0,-0.05,0,5|1,1,10,10,1,0.8,-0.05,-0.05,3"
      )
    end

    local right_block_other_x = right_block.other_x

    if block.other_x then
      blocks[y][block.other_x].other_x = new_x
    end

    if right_block_other_x then
      blocks[y][right_block_other_x].other_x = x
    end

    put(_ENV, new_x, y, block)
    put(_ENV, x, y, right_block)

    right_block:change_state("idle")

    return
  end

  -- hover が完了して下のブロックが空または falling の場合、
  -- パネルの状態を ":falling" にする
  if old_state == "hover" and is_block_fallable(_ENV, x, y) then
    block:fall()
  end

  if old_state == "match" and block:is_idle() then
    sfx(11, -1, (block._match_index % 6 - 1) * 4, 4)
    put(_ENV, x, y, block.new_block)
    particles:create(
      { screen_x(_ENV, x) + 3, screen_y(_ENV, y) + 3 },
      "2,1,7,7,-1,-1,0.05,0.05,16|2,1,7,7,1,-1,-0.05,0.05,16|2,1,7,7,-1,1,0.05,-0.05,16|2,1,7,7,1,1,-0.05,-0.05,16"
    )
    return
  end

  if block:is_hover() then
    for each_y = y + 1, #blocks do
      for each_x = 1, cols do
        if _check_hover_flag[each_y] == nil then
          _check_hover_flag[each_y] = {}
        end
        _check_hover_flag[each_y][each_x] = true
      end
    end
  end

  if reducible_blocks[y] == nil then
    reducible_blocks[y] = {}
  end
  if block:is_reducible() then
    reducible_blocks[y][x] = block
  else
    reducible_blocks[y][x] = nil
  end

  _changed = true

  if block:is_reducible() then
    _reduce_cache = {}
  end

  if not (block:is_swapping() or block:is_match()) then
    for i = y, #blocks do
      _is_block_fallable_cache[i] = {}
    end
  end
end

function board_class._memoize(_ENV, f, cache, x, y)
  if cache[y] == nil then
    cache[y] = {}
  end

  local result = cache[y][x]

  if result == nil then
    result = f(_ENV, x, y)
    cache[y][x] = result
  end

  return result
end

--#if debug
function board_class._tostring(_ENV)
  local str = ''

  for y = #blocks, 1, -1 do
    for x = 1, cols do
      local block = block_at(_ENV, x, y)

      if block.type == "i" and
          _is_part_of_garbage(_ENV, x, y) then
        str = str .. "g " .. " "
      else
        str = str .. block:_tostring() .. " "
      end
    end
    str = str .. "\n"
  end

  return str
end

--#endif
