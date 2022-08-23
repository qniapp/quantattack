pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
#include colors.lua

board_class = {
  new = function(self) 
    local board = {
      cols = 6,
      rows = 12,
      gates = {},
      offset_x = 10,
      offset_y = 10,
      dy = 0,

      draw = function(self)
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
        line(self.offset_x - 2, self.offset_y,
             self.offset_x - 2, self:screen_y(self.rows + 1),
             colors.white)
        -- border bottom
        line(self.offset_x - 1, self:screen_y(self.rows + 1),
             self.offset_x + self.cols * sprite_size - 1, self:screen_y(self.rows + 1),
             colors.white)
        -- border right
        line(self.offset_x + self.cols * sprite_size, self.offset_y,
             self.offset_x + self.cols * sprite_size, self:screen_y(self.rows + 1),
             colors.white)
        -- gate mask
        rectfill(self.offset_x - 1, self:screen_y(self.rows + 1) + 1,
                 self.offset_x + self.cols * sprite_size - 1, 127,
                 colors.black)
      end,

      _draw_gate = function(self, spr_id, x, y)
        spr(spr_id, self:screen_x(x), self:screen_y(y) + self.dy)
      end,

      screen_x = function(self, x)
        return self.offset_x + (x - 1) * sprite_size
      end,
 
      screen_y = function(self, y)
        return self.offset_y + (y - 1) * sprite_size
      end,

      gate_at = function(self, x, y)
        return self.gates[x][y]
      end,

      put_gate = function(self, gate_type, x, y)
        self.gates[x][y] = gate_type
      end,

      put_garbage_unitary = function(self)
        local start_y = self:screen_y(1)
        local stop_y = self:screen_y(self:gate_top_y() - 1)
        return garbage_class:new(start_y, stop_y)
      end,

      gate_top_y = function(self)
        for y = self.rows, 1, -1 do
          local gate_found = false
          for x = 1, self.cols do
            if self.gates[x][y] then
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
      board.gates[x] = {}
    end  
    board.gates[1][12] = "*"
    board.gates[2][11] = "*"
    board.gates[2][12] = "*"
    board.gates[4][12] = "*"
    board.gates[4][11] = "*"
    board.gates[4][10] = "*"
    board.gates[5][11] = "*"
    board.gates[5][12] = "*"
    board.gates[6][12] = "*"    

    return board
  end
}

game = {
 board = board_class:new()
}

function _init()
 sprite_size = 8
end

garbage_class = {
  new = function(self, start_y, stop_y)
    return {
      y = start_y,
      stop_y = stop_y,
      gate_top_y = stop_y + sprite_size,
      sink_y = stop_y + sprite_size * 2,
      dy = 16,
      ddy = 0.98,
      dy_loss = 0.5,
      hit_gate = false,
      hit_bottom = false,

      update = function(self)
        self:_update_y()
        self:_update_state()
        self:_update_dy()
      end,

      _update_y = function(self)
        self.y_prev = self.y
        self.y += self.dy
      end,

      _update_state = function(self)
        if not self.hit_bottom then
          if self.dy < 0.1 then
            self.hit_bottom = true
            self.dy = -8
          end

          if self.y > self.gate_top_y and self.dy > 0 then
            if (not self.hit_gate) sfx(0)
            if (self.y > self.sink_y) self.y = self.sink_y
            self.hit_gate = true
            self.dy = self.dy * 0.2
          end
        else
          if self.y > self.stop_y and self.dy > 0 then
            self.y = self.stop_y
            self.dy = -self.dy * self.dy_loss
          end
        end      
      end,

      _update_dy = function(self)
        if (not self.hit_bottom) return
        self.dy += self.ddy
      end,

      is_dropped = function(self)
        return self.y == self.stop_y and
               self.y == self.y_prev
      end,
    }
  end,
}

function _update60()
 if btnp(4) and garbage == nil then
  garbage = game.board:put_garbage_unitary()
 end

 if (garbage == nil) return

 if garbage:is_dropped() then
  garbage = nil
  local y = game.board:gate_top_y() - 1
  for x = 1, game.board.cols do
   game.board:put_gate("g", x, y)
  end
  return
 end

 garbage:update()

 if garbage.hit_gate then
  game.board.dy = garbage.y - screen_y(game.board:gate_top_y()) + sprite_size
 end
end

function _draw()
 cls()

 -- draw garbage unitary
 if (garbage != nil) then
  for x = 1, game.board.cols do
   local spr_id = 1
   if (x == 1) spr_id = 0
   if (x == game.board.cols) spr_id = 2
   spr(spr_id, screen_x(x), garbage.y)
  end
 end

 game.board:draw()
end

function screen_x(x)
 return game.board.offset_x + (x - 1) * sprite_size
end

function screen_y(y)
 return game.board.offset_y + (y - 1) * sprite_size
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
