---@diagnostic disable: global-in-nil-env

require("lib/block")

--                       span
--          ██████████████████████████████
--          ██                          ██
--          ██  ░░░░░░░░░░░░░░░░░░░░░░  ██
--  height  ██  ░░                  ░░  ██
--          ██  ░░░░░░░░░░░░░░░░░░░░░░  ██
--          ██       inner border       ██
--          ██████████████████████████████
--
--- @class Garbageblock おじゃまブロック
--- @field span 3 | 4 | 5 | 6 おじゃまブロックの幅
--- @field height integer おじゃまブロックの高さ
--- @field body_color 2 | 3 | 4 おじゃまブロックの色
--- @field inner_border_color 14 | 11 | 9 おじゃまブロック内側の枠線の色
--- @field first_drop boolean 最初の落下かどうか
--- @field render function おじゃまブロックを描画

local garbage_block_colors = { 2, 3, 4 }
local inner_border_colors = { nil, 14, 11, 9 }

-- 新しいおじゃまブロックを作る
--- @param _span? 3 | 4 | 5 | 6 おじゃまブロックの幅
--- @param _height? integer おじゃまブロックの高さ
--- @param _color? 2 | 3 | 4 おじゃまブロックの色
--- @return Garbageblock
function garbage_block(_span, _height, _color)
  local garbage = setmetatable({
    body_color = _color or garbage_block_colors[ceil_rnd(#garbage_block_colors)],
    first_drop = true,
    _render_box = draw_rounded_box,

    --- @param _ENV Garbageblock
    --- @param screen_x integer おじゃまブロック先頭ブロック (左下) の X 座標
    --- @param screen_y integer おじゃまブロック先頭ブロックの Y 座標
    render = function(_ENV, screen_x, screen_y)
      local y0, x1, y1, _body_color =
      screen_y + (1 - height) * tile_size,
          screen_x + span * tile_size - 2,
          screen_y + 6,
          _state ~= "over" and body_color or 9

      _render_box(screen_x, y0 + 1, x1, y1 + 1, 5) -- 影
      _render_box(screen_x, y0, x1, y1, _body_color, _body_color) -- 本体
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

  return garbage --[[@as Garbageblock]]
end
