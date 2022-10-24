-- print `text` centered around (`center_x`, `center_y`) with color `col`
-- multi-line text is supported
function print_centered(text, center_x, center_y, col)
  local lines = split(text, '\n')

  -- center on y too (character_height / 2 = 3)
  center_y = center_y - (#lines - 1) * 3

  for l in all(lines) do
    local x, y = center_x - #l * 2 + 1, center_y - 2
    api.print(l, x, y, col)

    -- prepare offset for next line
    center_y = center_y + character_height
  end
end

function draw_rounded_box(x0, y0, x1, y1, border_color, fill_color)
  -- draw border, cutting corners
  line(x0 + 1, y0, x1 - 1, y0, border_color)
  line(x1, y0 + 1, x1, y1 - 1, border_color)
  line(x1 - 1, y1, x0 + 1, y1, border_color)
  line(x0, y1 - 1, x0, y0 + 1, border_color)

  -- fill rectangle if big enough to have an interior
  if x0 + 1 <= x1 - 1 and y0 + 1 <= y1 - 1 then
    rectfill(x0 + 1, y0 + 1, x1 - 1, y1 - 1, fill_color)
  end
end

function mfunc(s)
  local tokens, function_index, index, args = split(s), 1, 1, {}

  while index <= #tokens do
    index = index + 1
    if _ENV[tokens[index]] ~= nil or index > #tokens then
      _ENV[tokens[function_index]](unpack(args))
      function_index, args = index, {}
    else
      add(args, tokens[index])
    end
  end
end
