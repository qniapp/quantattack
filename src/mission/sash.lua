-- 背景色と前景色を指定できるようにする
-- トークン最適化

local sash = new_class()

function sash:_init()
  self.state = ":idle"
end

function sash:create(_text)
  local _ENV = self

  if state == ":idle" and text ~= _text then
    dh = 0.1
    ddh = 0.2

    text_dx = 5
    text_ddx = -0.15

    height = 0
    text = _text
    text_width = #text * 4
    text_x = -text_width
    text_center_x = 128 / 2 - text_width / 2
    state = ":slidein"
  end
end

function sash:update()
  local _ENV = self

  if state == ":slidein" then
    height = height + dh
    dh = dh + ddh
    if height > 10 then
      height = 10
    end

    if text_x < text_center_x then
      text_dx = text_dx + text_ddx
      text_x = text_x + text_dx
    end

    if text_x > text_center_x then
      text_x = text_center_x
      time_stop = t()
      sfx(15)
      state = ":stop"
    end
  end

  if state == ":stop" then
    if t() - time_stop > 1 then
      dh = -0.1
      ddh = -0.2
      text_dx = 3
      text_ddx = 0.8
      state = ":slideout"
    end
  end

  if state == ":slideout" then
    height = height + dh
    dh = dh + ddh

    text_dx = text_dx + text_ddx
    text_x = text_x + text_dx

    if text_x > 127 then
      state = ":idle"
    end
  end
end

function sash:render()
  if self.state ~= ":idle" and self.height > 0 then
    rectfill(0, 64 - self.height / 2, 127, 64 + self.height / 2, 7)
    print(self.text, self.text_x, 64 - 2, 13)
  end
end

return sash()
