player_cursor = {
  _sprites = {
    corner = 65,
    middle = 66,
  },
  _color = colors.dark_green,

  new = function(self, board, x, y)
    local c = {
      init = function(self)
        self.x = x or 3
        self.y = y or 6
        self.board = board
        self.tick = 0
        self.idle_and_shurnk_frames = 14
        self.cannot_swap = false
        self.state_machine = state_machine:new()

        self.state_machine:add_state(
          "idle",
          -- transition function
          function(pc)
            if (pc.tick > self.idle_and_shurnk_frames) return "shrunk"
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
            if (pc.tick <= self.idle_and_shurnk_frames) return "idle"
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
        if (self.x > 1) self.x -= 1
      end,

      move_right = function(self)
        if (self.x < self.board.cols - 1) self.x += 1
      end,

      move_up = function(self)
        if (self.y > 1) self.y -= 1
      end,

      move_down = function(self)
        if (self.y < self.board.rows) self.y += 1
      end,  

      update = function(self)
        self.state_machine:update(self)
      end,

      draw = function(self)
        self.state_machine:draw(self)
      end,

      -- private

      _advance_tick = function(self)
        assert(self.tick >= 0 and self.tick <= self.idle_and_shurnk_frames * 2)

        self.tick += 1
        if (self.tick == self.idle_and_shurnk_frames * 2) self.tick = 0
      end,

      _draw_sprites = function(self, xl, xr, yt, yb)
        if self.cannot_swap then
          pal(player_cursor._color, colors.red)
        end
        if self.game_over then
          pal(player_cursor._color, colors.dark_grey)
        end

        spr(player_cursor._sprites.corner, xl, yt)
        spr(player_cursor._sprites.middle, self:_screen_xm(), yt)
        spr(player_cursor._sprites.corner, xr, yt, 1, 1, true, false)
        spr(player_cursor._sprites.corner, xl, yb, 1, 1, false, true)
        spr(player_cursor._sprites.middle, self:_screen_xm(), yb, 1, 1, false, true)
        spr(player_cursor._sprites.corner, xr, yb, 1, 1, true, true)

        pal(player_cursor._color, player_cursor._color)
      end,

      _screen_xl = function(self)
        return self.board:screen_x(self.x) - 5
      end,

      _screen_xm = function(self)
        return self.board:screen_x(self.x) + quantum_gate.size - 4
      end,

      _screen_xr = function(self)
        return self.board:screen_x(self.x + 1) + 4
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
}

