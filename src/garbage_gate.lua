---@diagnostic disable: global-in-nil-env

require("gate_class")

function garbage_gate(_span, _height, _color)
  local garbage = setmetatable({
    span = _span,
    height = _height,
    color = _color,
    _garbage_first_drop = true,

    render = function(_ENV)
       local x0, y0, x1, y1, bg_color = board:screen_x(x), board:screen_y(y - height + 1) + _fall_screen_dy,
          board:screen_x(x + span) - 2, board:screen_y(y + 1) - 2 + _fall_screen_dy,
          _state ~= "over" and color or 5
       draw_rounded_box(x0, y0 + 1, x1, y1 + 1, 1, 1) -- 影
       draw_rounded_box(x0, y0, x1, y1, bg_color, bg_color) -- 本体
       draw_rounded_box(x0 + 1, y0 + 1, x1 - 1, y1 - 1, _state ~= "over" and inner_border_color or 1) -- 内側の線
    end
  }, { __index = gate_class("g") }):_init()

  if _color == 2 then
    garbage.inner_border_color = 14
  elseif _color == 3 then
    garbage.inner_border_color = 11
  elseif _color == 4 then
    garbage.inner_border_color = 9
  end

  return garbage
end
