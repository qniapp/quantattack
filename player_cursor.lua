player_cursor = {
  sprites = {
    corner = 65,
    middle = 66,
  },
  color = colors.dark_green,
}

-- todo: 引数を board, x, y の順にする (x と y にデフォルト値をつけたい)
-- todo: 全体を player_cursor = { ... } の中に入れる
function player_cursor:new(x, y, board)
  local c = {
    init = function(self)
      self.x = x
      self.y = y
      self.board = board
      self.tick = 0
      self.warn = false
      self.state_machine = state_machine:new()

      self.state_machine:add_state(
        "idle",
        -- transition function
        function(pc)
          if (pc.tick >= 15) return "shrunk"
          return "idle"
        end,
  
        -- update function
        function(pc)
          pc:_advance_tick()
        end,

        -- draw function
        function(pc)
          pc:_draw_sprites(pc:_screen_xl(),
                           pc:_screen_xr(),
                           pc:_screen_yt(),
                           pc:_screen_yb())    
        end    
      )
      self.state_machine:add_state(
        "shrunk",
        -- transition function
        function(pc)
          if (pc.tick <= 14) return "idle"
          return "shrunk"    
        end,
  
        -- update function
        function(pc)
          pc:_advance_tick()
        end,

        -- draw function
        function(pc)
          pc:_draw_sprites(pc:_screen_xl() + 1,
                           pc:_screen_xr() - 1,
                           pc:_screen_yt() + 1,
                           pc:_screen_yb() - 1)       
        end
      )
      self.state_machine:set_state("idle")
    end,

    move_left = function(self)
      if self.x == 1 then
        self.warn = true
      else
        self.x -= 1
      end
    end,

    move_right = function(self)
      if self.x == self.board.cols - 1 then
        self.warn = true
      else
        self.x += 1
      end
    end,

    move_up = function(self)
      if self.y == 1 then
        self.warn = true
      else
        self.y -= 1
      end
    end,

    move_down = function(self)
      if self.y == self.board.rows then
        self.warn = true
      else
        self.y += 1
      end
    end,  

    update = function(self)
      self.state_machine:update(self)
    end,

    draw = function(self)
      self.state_machine:draw(self)
    end,

    -- private

    _advance_tick = function(self)
      assert(self.tick >= 0 and self.tick < 30)

      self.tick += 1
      if (self.tick == 30) self.tick = 0
    end,

    _draw_sprites = function(self, xl, xr, yt, yb)
      if self.warn then
        pal(player_cursor.color, colors.red)
      end
      if self.game_over then
        pal(player_cursor.color, colors.dark_grey)
      end

      spr(player_cursor.sprites.corner, xl, yt)
      spr(player_cursor.sprites.middle, self:_screen_xm(), yt)
      spr(player_cursor.sprites.corner, xr, yt, 1, 1, true, false)
      spr(player_cursor.sprites.corner, xl, yb, 1, 1, false, true)
      spr(player_cursor.sprites.middle, self:_screen_xm(), yb, 1, 1, false, true)
      spr(player_cursor.sprites.corner, xr, yb, 1, 1, true, true)

      pal(player_cursor.color, player_cursor.color)
    end,

    _screen_xl = function(self)
      return self.board:screen_x(self.x) - 5
    end,

    _screen_xm = function(self)
      return self.board:screen_x(self.x) + quantum_gate.size - 4
    end,

    _screen_xr = function(self)
      return self.board:screen_x(self.x + 1) + 3
    end,

    _screen_yt = function(self)
      return self.board:screen_y(self.y) - 5
    end,

    _screen_yb = function(self)
      return self.board:screen_y(self.y) + quantum_gate.size - 4
    end
  }

  c:init()

  return c
end