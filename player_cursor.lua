
player_cursor = {
  _sprites = {
    ["corner"] = 65,
    ["middle"] = 66
  },

  _color = colors.dark_green,

  new = function(self, x, y, board)
    local c = {
      init = function(self, x, y, board)
        self.x = x
        self.y = y
        self.board = board
        self._tick = 0
        self.warn = false
        self:_change_state("idle")
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
        assert(self._tick >= 0 and self._tick < 30)

        -- tick == 0 ... 14: state -> "idle"
        if self._tick == 15 then
          self:_change_state("shrunk")
        end

        -- tick == 15 ... 29: state -> "shrunk"
        if self._tick == 29 then
          self:_change_state("idle")
        end

        self._tick += 1
        if self._tick == 30 then
          self._tick = 0
        end
      end,

      draw = function(self)
        local x_left = self.board:screen_x(self.x)
        local x_right = self.board:screen_x(self.x + 1)
        local y = self.board:screen_y(self.y)

        -- top left
        local xtl = x_left - 5
        local ytl = y - 5

        -- top right
        local xtr = x_right + 4
        local ytr = ytl

        -- bottom left
        local xbl = xtl
        local ybl = y + quantum_gate.size - 4

        -- bottom right
        local xbr = xtr
        local ybr = ybl

        -- top middle
        local xtm = x_left + quantum_gate.size - 4
        local ytm = ytl

        -- bottom middle
        local xbm = xtm
        local ybm = ybl

        if self:is_shrunk() then
          xtl += 1
          ytl += 1
          xtr -= 1
          ytr += 1
          xbl += 1
          ybl -= 1
          xbr -= 1
          ybr -= 1
          ytm += 1
          ybm -= 1
        end

        if self.warn then
          pal(player_cursor._color, colors.red)
        end
        if self.game_over then
          pal(player_cursor._color, colors.dark_grey)
        end

        spr(player_cursor._sprites.corner, xtl, ytl)
        spr(player_cursor._sprites.corner, xtr, ytr, 1, 1, true, false)
        spr(player_cursor._sprites.corner, xbl, ybl, 1, 1, false, true)
        spr(player_cursor._sprites.corner, xbr, ybr, 1, 1, true, true)
        spr(player_cursor._sprites.middle, xtm, ytm)
        spr(player_cursor._sprites.middle, xbm, ybm, 1, 1, false, true)

        pal(player_cursor._color, player_cursor._color)
      end,

      is_idle = function(self)
        return self._state == "idle"
      end,

      is_shrunk = function(self)
        return self._state == "shrunk"
      end,

      -- private

      _change_state = function(self, new_state)
        assert(new_state)
        assert(new_state == "idle" or new_state == "shrunk")

        if new_state == "idle" then
          assert(self._state == nil or self:is_shrunk())
        end
        if new_state == "shrunk" then
          assert(self:is_idle())
        end

        self._state = new_state
      end,
    }

    c:init(x, y, board)

    return c
  end,
}