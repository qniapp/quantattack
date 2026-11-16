-- quantattack test harness for endless only: with `qa-run --param`, the board starts from that
-- layout instead of random blocks. Rows bottom up, separated by "|"; cells by ";", each a block
-- type with an optional ",other_x" (as in the tutorial): "t;swap,3;swap,2;h;i;i|...".
-- "g,SPAN" is a garbage block SPAN wide; the cells it covers stay "i".
local init = _init

function _init()
  init()
  if stat(6) ~= "" then
    for y = 0, board.rows do
      for x = 1, board.cols do
        board:put(x, y, block_class"i")
      end
    end
    for y, row in pairs(split(stat(6), "|")) do
      for x, cell in pairs(split(row, ";")) do
        local block_type, other_x = unpack_split(cell)
        local block = block_class(block_type)
        if block_type == "g" then
          block = garbage_block(other_x)
        else
          block.other_x = other_x
        end
        board:put(x, y, block)
      end
    end
  end
end
