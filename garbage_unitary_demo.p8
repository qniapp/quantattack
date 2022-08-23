pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
#include colors.lua

board_class = {
  new = function(self) 
    local board = {
      cols = 6,
      rows = 12,
      _gates = {},
      _offset_x = 10,
      _offset_y = 10,

      update = function(self)
        if (self.garbage == nil) return

        if self.garbage.state == "idle" then
          self.garbage = nil
          local y = self:gate_top_y() - 1
          for x = 1, self.cols do
            self:put_gate("g", x, y)
          end
          return
        end
        self.garbage:update()
      end,

      draw = function(self)
        -- draw garbage unitary
        if (self.garbage != nil) then
          for x = 1, self.cols do
            local spr_id = 1
            if (x == 1) spr_id = 0
            if (x == self.cols) spr_id = 2
            spr(spr_id, self:screen_x(x), self.garbage.y)
          end
        end

        -- draw gates
        for x = 1, self.cols do
          for y = 1, self.rows do
            local gate = self:gate_at(x, y)

            if gate == "*" then
              self:_draw_gate(16, x, y)
            end
            if gate == "g" then
              local spr_id = 1
              if (x == 1) spr_id = 0
              if (x == self.cols) spr_id = 2
              self:_draw_gate(spr_id, x, y)
            end
          end
        end

        -- border left
        line(self._offset_x - 2, self._offset_y,
             self._offset_x - 2, self:screen_y(self.rows + 1),
             colors.white)
        -- border bottom
        line(self._offset_x - 1, self:screen_y(self.rows + 1),
             self._offset_x + self.cols * sprite_size - 1, self:screen_y(self.rows + 1),
             colors.white)
        -- border right
        line(self._offset_x + self.cols * sprite_size, self._offset_y,
             self._offset_x + self.cols * sprite_size, self:screen_y(self.rows + 1),
             colors.white)
        -- mask under the border bottom
        rectfill(self._offset_x - 1, self:screen_y(self.rows + 1) + 1,
                 self._offset_x + self.cols * sprite_size - 1, 127,
                 colors.black)
      end,

      _draw_gate = function(self, spr_id, x, y)
        spr(spr_id, self:screen_x(x), self:screen_y(y) + self:_dy())
      end,

      _dy = function(self)
        if (self.garbage) return self.garbage:dy()
        return 0
      end,

      screen_x = function(self, x)
        return self._offset_x + (x - 1) * sprite_size
      end,
 
      screen_y = function(self, y)
        return self._offset_y + (y - 1) * sprite_size
      end,

      gate_at = function(self, x, y)
        return self._gates[x][y]
      end,

      put_gate = function(self, gate_type, x, y)
        self._gates[x][y] = gate_type
      end,

      put_garbage = function(self)
        local start_y = self:screen_y(1)
        local stop_y = self:screen_y(self:gate_top_y() - 1)
        self.garbage = garbage_class:new(start_y, stop_y)
        return self.garbage
      end,

      gate_top_y = function(self)
        for y = self.rows, 1, -1 do
          local gate_found = false
          for x = 1, self.cols do
            if self._gates[x][y] then
              gate_found = true
            end
          end
          if (not gate_found) return y + 1
        end
        return 1
      end,
    }

    -- initialize the board
    for x = 1, board.cols do
      board._gates[x] = {}
    end  
    board._gates[1][12] = "*"
    board._gates[2][11] = "*"
    board._gates[2][12] = "*"
    board._gates[4][12] = "*"
    board._gates[4][11] = "*"
    board._gates[4][10] = "*"
    board._gates[5][11] = "*"
    board._gates[5][12] = "*"
    board._gates[6][12] = "*"    

    return board
  end
}

game = {
 board = board_class:new()
}

garbage_class = {
  new = function(self, start_y, stop_y)
    return {
      y = start_y,
      state = "fall",
      _stop_y = stop_y,
      _gate_top_y = stop_y + sprite_size,
      _sink_y = stop_y + sprite_size * 2,
      _dy = 16,
      _ddy = 0.98,

      update = function(self)
        self:_update_y()
        self:_update_state()
        self:_update_dy()
      end,

      dy = function(self)
        if self.state == "sink" or self.state == "bounce" then
          return self.y - self._stop_y
        else
          return 0
        end
      end,

      _update_y = function(self)
        self.y_prev = self.y
        self.y += self._dy
      end,

      _update_state = function(self)
        if self.state ~= "bounce" then
          if self._dy < 0.1 then
            self:_change_state("bounce")
            self._dy = -7
          end

          if self.y > self._gate_top_y and self._dy > 0 then
            if (self.y > self._sink_y) self.y = self._sink_y
            self._dy = self._dy * 0.2

            if (self.state == "fall") then 
              self:_change_state("hit gate")
              sfx(0)
            else
              self:_change_state("sink")
            end
          end
        else
          -- bounce
          if self.y > self._stop_y and self._dy > 0 then
            self.y = self._stop_y
            self._dy = -self._dy * 0.6
          end
        end

        if (self.y == self._stop_y and
            self.y == self.y_prev) then
          self:_change_state("idle")
        end
      end,

      _change_state = function(self, new_state)
        self.state = new_state
        printh(new_state)
      end,

      _update_dy = function(self)
        if (self.state ~= "bounce") return
        self._dy += self._ddy
      end,
    }
  end,
}

function _init()
 sprite_size = 8
end

function _update60()
 if btnp(4) and game.board.garbage == nil then
  game.board:put_garbage()
 end
 game.board:update()
end

function _draw()
 cls()
 game.board:draw()
end

__gfx__
07777777777777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77ddddddddddddddddddd77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d7777777777777777777d7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d7777777777777777777d7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d7777777777777777777d7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77ddddddddddddddddddd77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777777777777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbbb30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbbb30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbbb30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbbb30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbbb30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100000e057000570e057000570d057000570d0570d0070c0070c0070c00700007000070e057000570c057000570b057000570b0570005700007000070000700007000570b057020570a057010570a05701057
