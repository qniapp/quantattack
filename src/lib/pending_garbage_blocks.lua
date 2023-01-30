---@diagnostic disable: global-in-nil-env, lowercase-global, unbalanced-assignments

pending_garbage_blocks_class = new_class()

function pending_garbage_blocks_class._init(_ENV)
  all = {}
end

function pending_garbage_blocks_class.add_garbage(_ENV, span, height, chain_id)
  -- 同じ chain_id のおじゃまブロックをまとめる
  for _, each in pairs(all) do
    if each.chain_id == chain_id and each.span == 6 then
      if each.height <= height then
        -- 同じ chain_id でより低いおじゃまブロックがすでにプールに入っている場合、消す
        del(all, each)
      else
        -- 同じ chain_id でより高いおじゃまブロックがすでにプールに入っている場合、何もしない
        return
      end
    end
  end

  add(all, garbage_block(span, height, nil, chain_id, 60))
end

-- おじゃまブロックの相殺
function pending_garbage_blocks_class.offset(_ENV, chain_count)
  local offset_height = chain_count

  for _, each in pairs(all) do
    if each.span == 6 then
      if not each.tick_fall then
        if each.height > offset_height then
          each.height = each.height - offset_height
          break
        else
          offset_height = offset_height - each.height
          del(all, each)
        end
      end
    else
      offset_height = offset_height - 1
      del(all, each)
    end
  end

  return offset_height
end

function pending_garbage_blocks_class.update(_ENV, board)
  local first_garbage_block = all[1]

  if first_garbage_block then
    if first_garbage_block.tick_fall > 0 then
      if first_garbage_block.tick_fall < 30 then
        first_garbage_block.dy = ceil_rnd(2) - 1
      end
      first_garbage_block.tick_fall = first_garbage_block.tick_fall - 1
    else
      -- おじゃまブロックが幅いっぱいの場合、x = 1
      -- そうでない場合、
      -- x + span - 1 <= board.cols を満たす x をランダムに決める
      local x, y = first_garbage_block.span == board.cols and
          1 or
          ceil_rnd(board.cols - first_garbage_block.span + 1),
          board.rows + 1

      if board:is_block_empty(x, y) then
        -- おじゃまブロックを落とす
        board:put(x, y, first_garbage_block)
        del(all, first_garbage_block)
      end
    end
  end
end

function pending_garbage_blocks_class.render(_ENV, board)
  for i, each in pairs(all) do
    if i < 6 then
      local x0, y0 = board.offset_x + 1 + (i - 1) * 9, each.dy

      if each.tick_fall then
        pal(7, each.inner_border_color)
        pal(6, each.inner_border_color)
      end

      if each.span < 6 then
        draw_rounded_box(x0, y0 + 4, x0 + 12, y0 + 9, 7, 7)
        draw_rounded_box(x0 + 1, y0 + 5, x0 + 11, y0 + 8, 0, 0)
      else
        draw_rounded_box(x0, y0 + 1, x0 + 12, y0 + 9, 7, 7)
        draw_rounded_box(x0 + 1, y0 + 2, x0 + 11, y0 + 8, 0, 0)

        cursor(x0 + 5, y0 + 3)
        color(6)
        print(each.height)
      end

      pal()
    end
  end
end
