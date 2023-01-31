---@diagnostic disable: global-in-nil-env, lowercase-global

title_logo_bounce_speed, title_logo_bounce_screen_dy = 0, 0

-- タイトルロゴを跳ねさせる
local function bounce_title_logo()
  title_logo_bounce_screen_dy, title_logo_bounce_speed = 0, -5
end

function update_title_logo_bounce()
  if title_logo_bounce_speed ~= 0 then
    title_logo_bounce_speed = title_logo_bounce_speed + 0.9
    title_logo_bounce_screen_dy = title_logo_bounce_screen_dy + title_logo_bounce_speed

    if title_logo_bounce_screen_dy > 0 then
      title_logo_bounce_screen_dy, title_logo_bounce_speed = 0, -title_logo_bounce_speed
    end
  end
end

local attack_cube_callback = function(target_x, target_y)
  bounce_title_logo()
  sfx(19)
  particles:create(target_x, target_y,
    "5,5,9,7,,,-0.03,-0.03,20|5,5,9,7,,,-0.03,-0.03,20|4,4,9,7,,,-0.03,-0.03,20|4,4,2,5,,,-0.03,-0.03,20|4,4,6,7,,,-0.03,-0.03,20|2,2,9,7,,,-0.03,-0.03,20|2,2,9,7,,,-0.03,-0.03,20|2,2,6,5,,,-0.03,-0.03,20|2,2,6,5,,,-0.03,-0.03,20|0,0,2,5,,,-0.03,-0.03,20")
end

function game()
  return setmetatable({
    reduce_callback = function(_score, _player)
      -- NOP
    end,

    combo_callback = function(_combo_count, screen_x, screen_y, _player, board, _other_board)
      ions:create(
        screen_x,
        screen_y,
        attack_cube_callback,
        12,
        64,
        36
      )
    end,

    block_offset_callback = function(chain_count)
      return chain_count
    end,

    chain_callback = function(_chain_id, chain_count, screen_x, screen_y)
      if chain_count > 1 then
        ions:create(
          screen_x,
          screen_y,
          attack_cube_callback,
          12,
          64,
          36
        )
      end
    end,

    init = function(_ENV)
      all_players_info = {}
    end,

    add_player = function(_ENV, player, board)
      add(all_players_info, {
        player = player,
        board = board,
        tick = 0
      })
    end,

    update = function(_ENV)
      for _, each in pairs(all_players_info) do
        local player, board, cursor = each.player, each.board, each.board.cursor

        player:update(board)

        if player.left then
          cursor:move_left()
        end
        if player.right then
          cursor:move_right(board.cols)
        end
        if player.up then
          cursor:move_up(board.rows)
        end
        if player.down then
          cursor:move_down()
        end
        if player.x then
          board:swap(cursor.x, cursor.y)
        end
        if player.o then
          _raise(_ENV, each)
        end

        board:update(_ENV, player)
        cursor:update()
      end

      particles:update_all()
      bubbles:update_all()
      ions:update_all()
    end,

    render = function(_ENV)
      for _, each in pairs(all_players_info) do
        each.board:render()
      end

      particles:render_all()
      bubbles:render_all()
      ions:render_all()
    end,

    -- ブロックをせりあげる
    _raise = function(_ENV, player_info)
      local board = player_info.board

      board.raised_dots = board.raised_dots + 1

      if board.raised_dots == 8 then
        board.raised_dots = 0
        board:insert_blocks_at_bottom()
        board.cursor:move_up(board.rows)
      end
    end
  }, { __index = _ENV })
end
