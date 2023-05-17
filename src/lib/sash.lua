---@diagnostic disable: global-in-nil-env, lowercase-global

-- メソッド:
--   sash:create(text, text_color, background_color, slideout_callback) 新しい sash を作る (シングルトン)
--     - text: 表示するテキスト
--     - text_color: テキストの色
--     - background_color: sash の背景色
--     - slideout_callback: sash が右端から消えた時に呼ぶコールバック
--   sash:update() 現在の sash の更新
--   sash:draw()   現在の sash を描画
--
-- クラス変数
--   sash.current 現在の sash
local sash = new_class()

function sash:_init()
  -- NOP
end

function sash.create(_ENV, _text, _text_color, _background_color, _slideout_callback)
  current = {}

  local _ENV = setmetatable(current, { __index = _ENV })

  background_height, dh, ddh, background_color, slideout_callback,
  text, text_x, text_dx, text_ddx, text_center_x, text_color, state =
      0, 0.1, 0.2, _background_color, _slideout_callback,
      _text, #_text * -4, 5, -0.14, 64 - #_text * 2, _text_color, ":slidein"
end

function sash.update(_ENV)
  if current then
    local _ENV = current

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
end

function sash.render(_ENV)
  if current then
    local _ENV = current

    if background_height > 0 then
      rectfill(0, 64 - background_height / 2, 127, 64 + background_height / 2, background_color)
      print(text, text_x, 64 - 2, text_color)
    end
  end
end

return sash()
