---@diagnostic disable: global-in-nil-env

require("gate_class")

function garbage_gate(_span, _height, __color)
  local garbage = setmetatable({
    span = _span,
    height = _height,
    _color = __color,
    _garbage_first_drop = true,

    render = function(_ENV)
      local x0, y0, x1, y1 = observer:screen_x(x), observer:screen_y(y - height + 1) + _fall_screen_dy,
          observer:screen_x(x + span) - 2, observer:screen_y(y + 1) - 2 + _fall_screen_dy
      local bg_color = _state ~= "over" and _color or 5

      draw_rounded_box(x0, y0 + 1, x1, y1 + 1, 1, 1) -- 影
      draw_rounded_box(x0, y0, x1, y1, bg_color, bg_color) -- 本体
      draw_rounded_box(x0 + 1, y0 + 1, x1 - 1, y1 - 1, _state ~= "over" and inner_border_color or 1) -- 内側の線
    end
  }, { __index = gate_class("g") }):_init()

  if __color == 2 then
    garbage.inner_border_color = 14
  elseif __color == 3 then
    garbage.inner_border_color = 11
  elseif __color == 4 then
    garbage.inner_border_color = 9
  end

  return garbage
end
