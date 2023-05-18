---@diagnostic disable: global-in-nil-env, lowercase-global

-- sash:create("text,text_color,background_color", slideout_callback) 新しい sash を作る (シングルトン)
--   - text: 表示するテキスト
--   - text_color: テキストの色
--   - background_color: sash の背景色
--   - slideout_callback: sash が右端から消えた時に呼ぶコールバック

sash = derived_class(effect_set)()

function sash:create(properties, _slideout_callback)
  self.all = {}
  self:_add(function (_ENV)
      text, text_color, background_color = unpack_split(properties)
      background_height, dh, ddh, slideout_callback, text_x, text_dx, text_ddx, text_center_x, state =
        0, 0.1, 0.2, _slideout_callback, #text * -4, 5, -0.14, 64 - #text * 2, ":slidein"
  end)
end

function sash._update(_ENV)
  if state == ":slidein" then
    background_height, dh = background_height + dh, dh + ddh
    if background_height > 10 then
      background_height = 10
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
      dh, ddh, text_dx, text_ddx, state =
          -0.1, -0.2, 3, 0.8, ":slideout"
    end
  end

  if state == ":slideout" then
    background_height, dh, text_x, text_dx =
        background_height + dh, dh + ddh, text_x + text_dx, text_dx + text_ddx

    if text_x > 127 then
      if slideout_callback then
        slideout_callback()
      end

      state = ":finished"
    end
  end
end

function sash._render(_ENV)
  if background_height > 0 then
    rectfill(0, 64 - background_height / 2, 127, 64 + background_height / 2, background_color)
    print(text, text_x, 64 - 2, text_color)
  end
end
