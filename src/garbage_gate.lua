---@diagnostic disable: global-in-nil-env

require("gate_class")

function garbage_gate(span, height, clr)
  local garbage = setmetatable({
    color = clr,
    _garbage_first_drop = true,

    render = function(_ENV, screen_x, screen_y)
      local x0, y0, x1, y1 = screen_x, screen_y + (1 - height) * 8 + _fall_screen_dy,
          screen_x + span * 8 - 2, screen_y + 6 + _fall_screen_dy
      local bg_color = _state ~= "over" and clr or 5

      draw_rounded_box(x0, y0 + 1, x1, y1 + 1, 1) -- 影
      draw_rounded_box(x0, y0, x1, y1, bg_color, bg_color) -- 本体
      draw_rounded_box(x0 + 1, y0 + 1, x1 - 1, y1 - 1, _state ~= "over" and inner_border_color or 1) -- 内側の線
    end
  }, { __index = gate_class("g", span, height) }):_init()

  if clr == 2 then
    garbage.inner_border_color = 14
  elseif clr == 3 then
    garbage.inner_border_color = 11
  elseif clr == 4 then
    garbage.inner_border_color = 9
  end

  return garbage
end
