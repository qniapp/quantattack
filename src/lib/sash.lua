---@diagnostic disable: global-in-nil-env, lowercase-global

local sash = new_class()
local all_texts = {}

function sash:_init()
  self:init()
end

function sash:init()
  all_texts = {}
  self.current_text = nil
end

function sash.create(_ENV, _text, _color, _background_color, _slidein_callback, _slideout_callback)
  if current_text ~= _text then
    current_text = _text

    local _ENV = setmetatable({}, { __index = _ENV })

    height, dh, ddh, background_color, slidein_callback, slideout_callback =
    0, 0.1, 0.2, _background_color, _slidein_callback, _slideout_callback
    text_width = #_text * 4
    text, text_x, text_dx, text_ddx, text_center_x, text_color =
    _text, -text_width, 5, -0.14, 64 - text_width / 2, _color
    state = ":slidein"

    add(all_texts, _ENV)
  end
end

function sash.update(_ENV)
  if all_texts[1] then
    local _ENV = all_texts[1]

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
        if slideout_callback then
          slideout_callback()
        end

        del(all_texts, _ENV)

        if all_texts[1] and all_texts[1].slidein_callback then
          all_texts[1].slidein_callback()
        end
      end
    end
  end
end

function sash:render()
  if all_texts[1] then
    local _rectfill, _print, _ENV = rectfill, print, all_texts[1]

    if state ~= ":idle" and height > 0 then
      _rectfill(0, 64 - height / 2, 127, 64 + height / 2, background_color)
      _print(text, text_x, 64 - 2, text_color)
    end
  end
end

return sash()
