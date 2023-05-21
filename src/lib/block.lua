---@diagnostic disable: lowercase-global

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

-- TODO: span, height は garbage の特異プロパティにする？ 検討
-- TODO: _timer_landing の初期化いる？ 検討
function block_class._init(_ENV, _type, _span, _height)
  type, state, span, height, sprite_set, _timer_landing =
      _type, "idle", _span or 1, _height or 1, sprites[_type], 0
end

function block_class.is_fallable(_ENV)
  return type ~= "i" and type ~= "?" and state ~= "swap" and state ~= "freeze" and state ~= "match"
end

function block_class.is_reducible(_ENV)
  return state == "idle" and type ~= "i" and type ~= "?"
end

function block_class:is_swappable_state()
  return self.state == "idle" or self.state == "falling"
end

function block_class:swap_with(direction)
  self.chain_id = nil
  self.swap_direction = direction
  self:change_state("swap")
end

function block_class:hover(timer)
  self.timer = timer or 12
  self:change_state("hover")
end

function block_class:fall()
  --#if assert
  assert(self:is_fallable(), "block " .. self.type)
  assert(self.x, "x is not set")
  assert(self.y, "y is not set")
  --#endif

  if self.state == "falling" then
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
  if state == "idle" then
    if _timer_landing > 0 then
      _timer_landing = _timer_landing - 1
    end
  elseif state == "swap" then
    if _tick_swap < block_swap_animation_frame_count then
      _tick_swap = _tick_swap + 1
    else
      chain_id = nil
      change_state(_ENV, "idle")
    end
  elseif state == "hover" then
    if timer > 0 then
      timer = timer - 1
    else
      change_state(_ENV, "idle")
    end
  elseif state == "match" then
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
  elseif state == "freeze" then
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
    if state == "swap" and swap_direction == "left" then
      swap_screen_dx = -swap_screen_dx
    end

    if state == "idle" and _timer_landing > 0 then
      sprite = sprite_set.landing[_timer_landing]
    elseif state == "match" then
      local sequence = sprite_set.match
      sprite = _tick_match <= block_match_delay_per_block and sequence[_tick_match] or sequence[#sequence]
    elseif state == "over" then
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
        (state == "match") and 13 or 10
      )
    end
  end

  if self.type == "?" then
    palt(0, false)
    pal(13, self.body_color)
  end

  if self.state == "over" then
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
  _timer_landing, _tick_swap = (state == "falling") and 12 or 0, 0

  local old_state = state
  state = new_state

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
  hover = "^",
  falling = "|",
  match = "*",
  freeze = "f",
}

function block_class:_tostring()
  if self.state == "swap" then
    if self.swap_direction == "left" then
      return (type_string[self.type] or self.type:upper()) .. "<"
    elseif self.swap_direction == "right" then
      return (type_string[self.type] or self.type:upper()) .. ">"
    else
      assert(false, "Invalid state")
    end
  else
    return (type_string[self.type] or self.type:upper()) .. state_string[self.state]
  end
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
          state ~= "over" and body_color or 9

      _render_box(screen_x, y0 + 1, x1, y1 + 1, 5)                                                   -- 影
      _render_box(screen_x, y0, x1, y1, _body_color, _body_color)                                    -- 本体
      _render_box(screen_x + 1, y0 + 1, x1 - 1, y1 - 1, state ~= "over" and inner_border_color or 1) -- 内側の線
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
