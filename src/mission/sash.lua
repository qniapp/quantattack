---@diagnostic disable: global-in-nil-env, lowercase-global
-- sfx の音をサイレンっぽくする

local sash = new_class()

function sash:_init()
  self.state = ":idle"
end

function sash.create(_ENV, _text, _color, _background_color)
  if state == ":idle" and text ~= _text then
    height, dh, ddh, background_color =
    0, 0.1, 0.2, _background_color
    text_width = #_text * 4
    text, text_x, text_dx, text_ddx, text_center_x, text_color =
    _text, -text_width, 5, -0.15, 128 / 2 - text_width / 2, _color
    state = ":slidein"
  end
end

function sash.update(_ENV)
  if state == ":slidein" then
    height, dh = height + dh, dh + ddh
    if height > 10 then
      height = 10
    end

    if text_x < text_center_x then
      text_x, text_dx = text_x + text_dx, text_dx + text_ddx
    end

    if text_x > text_center_x then
      text_x, time_stop, state = text_center_x, t(), ":stop"
      sfx(15)
    end
  end

  if state == ":stop" then
    if t() - time_stop > 1 then
      dh, ddh, text_dx, text_ddx, state = -0.1, -0.2, 3, 0.8, ":slideout"
    end
  end

  if state == ":slideout" then
    height, dh, text_x, text_dx = height + dh, dh + ddh, text_x + text_dx, text_dx + text_ddx

    if text_x > 127 then
      state = ":idle"
    end
  end
end

function sash:render()
  local _rectfill, _print, _ENV = rectfill, print, self

  if state ~= ":idle" and height > 0 then
    _rectfill(0, 64 - height / 2, 127, 64 + height / 2, background_color)
    _print(text, text_x, 64 - 2, text_color)
  end
end

return sash()
