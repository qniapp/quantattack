---@diagnostic disable: global-in-nil-env

require("gate")

garbage_gate_colors = { 2, 3, 4 }

--- @class GarbageGate
--- @field color number color of the gate
--- @field inner_border_color number color of the inner border
--- @field span number span of the gate
--- @field height number height of the gate

--- @param clr? 2 | 3 | 4 color of the gate
--- @param span? 3 | 4 | 5 | 6 span of the gate
--- @param height? integer height of the gate
--- @return table GarbageGate garbage gate
function garbage_gate(clr, span, height)
  local _color = clr or 2
  assert(_color == 2 or _color == 3 or _color == 4, "invalid color: " .. _color)

  local _span = span or 6
  assert(2 < _span, "span must be greater than 2")
  assert(_span < 7, "span must be less than 7")

  local garbage = setmetatable({
    color = _color,
    first_drop = true,
    inner_border_color = 14,

    --- @param _ENV GarbageGate
    --- @param screen_x integer x position of the gate
    --- @param screen_y integer y position of the gate
    render = function(_ENV, screen_x, screen_y)
      local y0, x1, y1, body_color = screen_y + (1 - height) * 8 + _fall_screen_dy,
          screen_x + _span * 8 - 2, screen_y + 6 + _fall_screen_dy,
          _state ~= "over" and _color or 5

      draw_rounded_box(screen_x, y0 + 1, x1, y1 + 1, 1) -- 影
      draw_rounded_box(screen_x, y0, x1, y1, body_color, body_color) -- 本体
      draw_rounded_box(screen_x + 1, y0 + 1, x1 - 1, y1 - 1, _state ~= "over" and inner_border_color or 1) -- 内側の線
    end
  }, { __index = gate("g", _span, height) }):_init()

  if _color == 3 then
    garbage.inner_border_color = 11
  elseif _color == 4 then
    garbage.inner_border_color = 9
  end

  return garbage
end
