---@diagnostic disable: global-in-nil-env

require("gate_class")

function garbage_gate(span, height, clr)
  local _color = clr or 2
  assert(_color == 2 or _color == 3 or _color == 4, "invalid color: " .. _color)

  local garbage = setmetatable({
    color = _color,
    first_drop = true,
    inner_border_color = 14,

    render = function(_ENV, screen_x, screen_y)
      local y0, x1, y1, body_color = screen_y + (1 - height) * 8 + _fall_screen_dy,
          screen_x + span * 8 - 2, screen_y + 6 + _fall_screen_dy,
          _state ~= "over" and _color or 5

      draw_rounded_box(screen_x, y0 + 1, x1, y1 + 1, 1) -- 影
      draw_rounded_box(screen_x, y0, x1, y1, body_color, body_color) -- 本体
      draw_rounded_box(screen_x + 1, y0 + 1, x1 - 1, y1 - 1, _state ~= "over" and inner_border_color or 1) -- 内側の線
    end
  }, { __index = gate_class("g", span, height) }):_init()

  if _color == 3 then
    garbage.inner_border_color = 11
  elseif _color == 4 then
    garbage.inner_border_color = 9
  end

  return garbage
end
