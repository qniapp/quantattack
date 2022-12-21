---@diagnostic disable: global-in-nil-env, lowercase-global, unbalanced-assignments

require("lib/garbage_block")

function create_pending_garbage_blocks()
  local cue = setmetatable({
    _init = function(_ENV)
      all = {}
      return _ENV
    end,

    add_garbage = function(_ENV, span, height, chain_id)
      -- 同じ chain_id のおじゃまゲートをまとめる
      for _, each in pairs(all) do
        if each.chain_id == chain_id and each.span == 6 then
          if each.height <= height then
            -- 同じ chain_id でより低いおじゃまゲートがすでにプールに入っている場合、消す
            del(all, each)
          else
            -- 同じ chain_id でより高いおじゃまゲートがすでにプールに入っている場合、何もしない
            return
          end
        end
      end

      local new_garbage_block = garbage_block(span, height)
      new_garbage_block.chain_id = chain_id
      new_garbage_block.wait_time = 60
      new_garbage_block.dy = 0
      add(all, new_garbage_block)
    end,

    offset = function(_ENV, chain_count)
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
    end,

    update = function(_ENV, board)
      local first_garbage_block = all[1]

      if first_garbage_block then
        if first_garbage_block.tick_fall then
          if first_garbage_block.tick_fall == 0 then
            del(all, first_garbage_block)
            board:put(first_garbage_block.x, 1, first_garbage_block)
            first_garbage_block:fall()
          else
            first_garbage_block.dy = ceil_rnd(2) - 1
            first_garbage_block.tick_fall = first_garbage_block.tick_fall - 1
          end
        elseif first_garbage_block.wait_time == 0 then
          -- 落とす時の x 座標を決める
          local x
          if first_garbage_block.span == board.cols then
            x = 1
          else
            -- おじゃまゲートの x 座標
            -- x + span - 1 <= board.cols を満たす x をランダムに決める
            --
            -- x = ceil_rnd(6 - 3 + 1)
            -- →   ceil_rnd(4)
            x = ceil_rnd(board.cols - first_garbage_block.span + 1)
          end

          for i = x, x + first_garbage_block.span - 1 do
            if not board:is_block_empty(i, 1) or not board:is_block_empty(i, 2) then
              return
            end
          end

          -- 落とせることが確定
          first_garbage_block.x = x
          first_garbage_block.tick_fall = 30
        else
          first_garbage_block.wait_time = first_garbage_block.wait_time - 1
        end
      end
    end,

    render = function(_ENV, board)
      for i, each in pairs(all) do
        if i < 6 then
          local x0, y0 = board.offset_x + 1 + (i - 1) * 9, board.offset_y + each.dy

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

          pal(6, 6)
          pal(7, 7)
        end
      end
    end
  }, { __index = _ENV }):_init()

  return cue
end
