tile_size = 8

function draw_rounded_box(x0, y0, x1, y1, border_color, fill_color)
  line(x0 + 1, y0, x1 - 1, y0, border_color)
  line(x1, y0 + 1, x1, y1 - 1, border_color)
  line(x1 - 1, y1, x0 + 1, y1, border_color)
  line(x0, y1 - 1, x0, y0 + 1, border_color)

  if fill_color then
    rectfill(x0 + 1, y0 + 1, x1 - 1, y1 - 1, fill_color)
  end
end

function print_outlined(str, x, y, color) -- 21 tokens
  print(str, x - 1, y, 0)
  print(str, x + 1, y)
  print(str, x, y - 1)
  print(str, x, y + 1)
  print(str, x, y, color)
end

function maybe_fill_zero_less_than_10(num)
  return (num < 10) and "0" .. num or num
end
