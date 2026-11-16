---@diagnostic disable: lowercase-global

require("lib/helpers")

--- ブロック (量子ゲート) クラス
block_class = new_class()
do local _ENV = block_class
  block_match_animation_frame_count,
      block_match_delay_per_block,
      block_swap_animation_frame_count = unpack_split"45,8,3"
  sprites = transform({
    -- default|landing|match|jump
    -- jump: マッチではじけるときに上のブロックを押し上げる高さ (1/3 ドット)。QA2 と同じ 0.5, 1, 1.5, 2, 3 マス
    h = "0|1,1,1,2,2,2,3,3,1,1,1,1|24,24,24,25,25,25,24,24,24,26,26,26,0,0,0,27|12",
    x = "16|17,17,17,18,18,18,19,19,17,17,17,17|40,40,40,41,41,41,40,40,40,42,42,42,16,16,16,43|12",
    y = "32|33,33,33,34,34,34,35,35,33,33,33,33|56,56,56,57,57,57,56,56,56,58,58,58,32,32,32,59|12",
    z = "48|49,49,49,50,50,50,51,51,49,49,49,49|12,12,12,13,13,13,12,12,12,14,14,14,48,48,48,15|12",
    s = "4|5,5,5,6,6,6,7,7,5,5,5,5|28,28,28,29,29,29,28,28,28,30,30,30,4,4,4,31|24",
    t = "20|21,21,21,22,22,22,23,23,21,21,21,21|44,44,44,45,45,45,44,44,44,46,46,46,20,20,20,47|36",
    control = "36|37,37,37,38,38,38,39,39,37,37,37,37|60,60,60,61,61,61,60,60,60,62,62,62,36,36,36,63|48",
    cnot_x = "52|53,53,53,54,54,54,55,55,53,53,53,53|64,64,64,65,65,65,64,64,64,66,66,66,52,52,52,67|48",
    swap = "8|9,9,9,10,10,10,11,11,9,9,9,9|80,80,80,81,81,81,80,80,80,82,82,82,8,8,8,83|72",
    ["?"] = "98|98,98,98,98,98,98,98,98,98,98,98,98|98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98",
    ["#"] = "113|113,113,113,113,113,113,113,113,113,113,113,113|113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113"
  }, function(each)
    local default, landing, match, jump = unpack_split(each, "|")
    return {
      default = default,
      landing = split(landing),
      match = split(match),
      jump = jump
    }
  end)

  -- TODO: span, height は garbage の特異プロパティにする？ 検討
  -- TODO: _timer_landing の初期化いる？ 検討
  function _init(_ENV, _type, _span, _height)
    type, state, span, height, sprite_set, _timer_landing, jump_dy, fall_dy =
        _type, "idle", _span or 1, _height or 1, sprites[_type], unpack_split"0,0,0"
  end

  -- NOTE: board クラスでは「ブロックが落とせない状態か？」という判定しか行わないため、
  -- not block:is_fallable() ではなく block:is_not_fallable() と書けるようにする。
  -- これによって "not" のトークンを削減
  function is_not_fallable(_ENV)
    return type == "i" or type == "?" or state == "swap" or state == "freeze" or state == "match"
  end

  -- 押し上げられて浮いているブロックは、下りきるまでマッチしない
  function is_reducible(_ENV)
    return state == "idle" and type ~= "i" and type ~= "?" and jump_dy == 0
  end

  -- 押し上げられているブロックは、QA2 と同じく入れ替えられない
  function is_swappable_state(_ENV)
    return (state == "idle" or state == "fall") and jump_dy == 0
  end

  function swap_with(_ENV, direction)
    chain_id, swap_direction = nil, direction
    change_state(_ENV, "swap")
  end

  function hover(_ENV, _timer)
    timer = _timer or 12 -- ホバー状態はデフォルトで 12 フレーム
    change_state(_ENV, "hover")
  end

  function fall(_ENV)
    --#if assert
    assert(not is_not_fallable(_ENV), "block " .. type)
    assert(x, "x is not set")
    assert(y, "y is not set")
    --#endif

    change_state(_ENV, "fall")
  end

  -- マッチしたゲートは match_group (同じマッチのブロックと rows: 段数) と match_index (下から何段目か)
  -- をもらい、QA2 と同じように 45 フレーム光ったあと、下の段から 15 フレームごとに上を押し上げてはじける。
  -- はじけたマスは最後の段がはじけるまで埋まったままで、結果はまとめて出る。
  -- おじゃまブロックの分解 (match_group なし) は今までどおり 8 フレームごと。
  -- 分解中のマスは、もとのおじゃまブロック garbage を覚えておき、押し上げられるときはその幅全体で上がる。
  function replace_with(_ENV, other, match_index, _chain_id, garbage, match_group)
    new_block, _match_index, _tick_match, chain_id, other.chain_id, _garbage, _match_group =
        other, match_index or 0, 1, _chain_id, _chain_id, garbage, match_group

    change_state(_ENV, "match")
  end

  function update(_ENV)
    -- 押し上げられたブロックは、マッチが終わって 12 フレーム浮いたあと、落下と同じ秒速 5 マスで
    -- 下りる。マスごと落ちているあいだは押し上げた高さを保ち、着地してからその分を下りる
    if jump_dy > 0 then
      -- 盤面に、これより上のブロックが押し上げられたこのブロックを貫通しないか調べさせる
      observer._lifting = true
      _jump_hold = _jump_hold - 1
      if _jump_hold < 0 and state == "idle" then
        -- 押し上げる高さはどれも偶数 (12, 24, 36, 48, 72 とその和) なので、ちょうど 0 で止まる
        jump_dy = jump_dy - 2
        -- 下りきったところで着地する。マッチできるようになったことを盤面に知らせ、ふつうの着地と同じく
        -- 次のフレームのマッチの判定を chain_id を消すより先にする (このフレームのうちに 12 になる)
        if jump_dy == 0 then
          _timer_landing = 13
          observer:observable_update(_ENV)
        end
      end
    end

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
      if _tick_match <= block_match_animation_frame_count + (_match_group and _match_group.rows * 15 or _match_index * block_match_delay_per_block) then
        -- 自分の段の番 (45 + 15 * (段 - 1) フレーム目) に上を押し上げ、その 15 フレーム後にはじける
        if _match_group then
          observer:pop(_ENV, _tick_match - _match_index * 15)
        end
        _tick_match = _tick_match + 1
      else
        -- 押し上げられたままのマスには、結果のゲートも同じ高さで出す
        if new_block.type ~= "i" then
          new_block.jump_dy, new_block._jump_hold = jump_dy, _jump_hold
        end
        change_state(_ENV, "idle")

        if _garbage then
          new_block._garbage, new_block._freeze_frame_count =
              _garbage, (_garbage.span * _garbage.height - _match_index) * block_match_delay_per_block
          new_block:change_state("freeze")
        end
      end
    elseif state == "freeze" then
      if _freeze_frame_count > 0 then
        _freeze_frame_count = _freeze_frame_count - 1
      else
        _garbage = nil
        change_state(_ENV, "idle")
      end
    end
  end

  function render(_ENV, screen_x, screen_y, screen_other_x)
    local shake_dx, shake_dy, swap_screen_dx, sprite = 0, 0

    if type == "i" then
      return
    end

    -- 8 / 3 で割り切れないので、先に掛けてから割る (順序を変えると固定小数点の丸めで描画位置がずれる)
    swap_screen_dx = (_tick_swap or 0) * 8 / block_swap_animation_frame_count
    if state == "swap" and swap_direction == "left" then
      swap_screen_dx = -swap_screen_dx
    end

    if state == "idle" and _timer_landing > 0 then
      sprite = sprite_set.landing[_timer_landing]
    elseif state == "match" then
      if _match_group and _tick_match > 45 + _match_index * 15 then
        return
      end
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

    if type == "?" then
      palt(0, false)
      pal(13, body_color)
    end

    if state == "over" then
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

  function attach(_ENV, _observer)
    observer = _observer
  end

  function change_state(_ENV, new_state)
    -- 押し上げられて浮いたまま落ちてきたときは、下りきるまで着地しない
    _timer_landing, _tick_swap = state == "fall" and jump_dy == 0 and 12 or 0, 0

    local old_state = state
    state = new_state

    observer:observable_update(_ENV, old_state)
  end
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
  fall = "|",
  match = "*",
  freeze = "f",
}

function block_class._tostring(_ENV)
  if state == "swap" then
    if swap_direction == "left" then
      return (type_string[type] or type:upper()) .. "<"
    elseif swap_direction == "right" then
      return (type_string[type] or type:upper()) .. ">"
    else
      assert(false, "Invalid state")
    end
  else
    return (type_string[type] or type:upper()) .. state_string[state]
  end
end

--#endif

--#ifn title
--#ifn tutorial
--- おじゃまブロック

local inner_border_colors = split",14,11,9"

--- 新しいおじゃまブロックを作る
function garbage_block(_span, _height, _color, _chain_id, _tick_fall)
  local garbage = setmetatable({
    body_color = _color or ceil_rnd(3) + 1,
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
--#endif
--#endif
