pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
#include colors.lua
#include player_cursor.lua

-- todo: merge with quantum_gate_types.lua

quantum_gate = {
  size = 8,
}

board_class = {
  new = function(_self) 
    local board = {
      cols = 6,
      rows = 12,
      _gates = {},
      _garbages = {},
      _offset_x = 10,
      _offset_y = 10,

      update = function(self)
        foreach(self._garbages, function(each)
          local y = self:y(each._stop_y)

          if each.state == "hit gate" then
            self:put_gate(each.x, y, each)
          end

          if each.state == "idle" then
            del(self._garbages, each)
            self:put_gate(each.x, y, each)
          end

          each:update()
        end)
      end,

      draw = function(self)
        -- draw gates
        for x = 1, self.cols do
          for y = 1, self.rows do
            local gate = self:gate_at(x, y)

            if gate and gate.type == "*" then
              self:_draw_gate(16, x, y)
            end
            if gate and gate.type == "g" then
              for gx = gate.x, gate.x + gate.width - 1 do
                local spr_id = 1
                if (gx == gate.x) spr_id = 0
                if (gx == gate.x + gate.width - 1) spr_id = 2
                self:_draw_gate(spr_id, gx, y)
              end
            end
          end
        end

        -- draw garbage unitaries
        foreach(self._garbages, function(each)
          for x = each.x, each.x + each.width - 1 do
            local spr_id = 1
            if (x == each.x) spr_id = 0
            if (x == each.x + each.width - 1) spr_id = 2
            spr(spr_id, self:screen_x(x), each.y)
          end
        end)

        -- border left
        line(self._offset_x - 2, self._offset_y,
             self._offset_x - 2, self:screen_y(self.rows + 1),
             colors.white)
        -- border bottom
        line(self._offset_x - 1, self:screen_y(self.rows + 1),
             self._offset_x + self.cols * quantum_gate.size - 1, self:screen_y(self.rows + 1),
             colors.white)
        -- border right
        line(self._offset_x + self.cols * quantum_gate.size, self._offset_y,
             self._offset_x + self.cols * quantum_gate.size, self:screen_y(self.rows + 1),
             colors.white)
        -- mask under the border bottom
        rectfill(self._offset_x - 1, self:screen_y(self.rows + 1) + 1,
                 self._offset_x + self.cols * quantum_gate.size - 1, 127,
                 colors.black)
      end,

      _draw_gate = function(self, spr_id, x, y)
        spr(spr_id, self:screen_x(x), self:screen_y(y) + self:dy())
      end,

      dy = function(self)
        if (#self._garbages != 0) then
          return self._garbages[#self._garbages]:dy()
        end
        return 0
      end,

      screen_x = function(self, x)
        return self._offset_x + (x - 1) * quantum_gate.size
      end,
 
      screen_y = function(self, y)
        return self._offset_y + (y - 1) * quantum_gate.size
      end,

      y = function(self, screen_y)
        return (screen_y - self._offset_y) / quantum_gate.size + 1
      end,

      gate_at = function(self, x, y)
        return self._gates[x][y]
      end,

      put_gate = function(self, x, y, gate)
        self._gates[x][y] = gate
      end,

      put_garbage = function(self)
        local width = flr(rnd(4)) + 3
        local garbage = garbage_unitary:new(width, self)

        add(self._garbages, garbage)
      end,

      gate_top_y = function(self, x_start, x_end)
        for y = 1, self.rows do
          for x = x_start, x_end, 1 do
            if (self._gates[x][y]) return y
          end
          for x = 1, self.cols do
            local gate = self._gates[x][y]
            if gate and gate.type == "g" and
               gate.x < x_start and x_start <= gate.x + gate.width - 1 then
              return y
            end
          end
        end
        return 1
      end,      
    }

    -- initialize the board
    for x = 1, board.cols do
      board._gates[x] = {}
    end  
    board._gates[1][12] = { type = "*" }
    board._gates[2][11] = { type = "*" }
    board._gates[2][12] = { type = "*" }
    board._gates[4][12] = { type = "*" }
    board._gates[4][11] = { type = "*" }
    board._gates[4][10] = { type = "*" }
    board._gates[5][11] = { type = "*" }
    board._gates[5][12] = { type = "*" }
    board._gates[6][12] = { type = "*" }    

    return board
  end
}

game_class = {
  new = function(_self)
    local board = board_class:new()
    return {
      button = {
        left = 0,
        right = 1,
        up = 2,
        down = 3,
        x = 4,
        o = 5,
      },  
      board = board,
      player_cursor = player_cursor:new(board.cols, board.rows)
    }
  end,
}

garbage_unitary = {
  new = function(_self, width, board)
    local x = flr(rnd(board.cols - width + 1)) + 1
    local start_y = board:screen_y(1)
    local stop_y = board:screen_y(board:gate_top_y(x, x + width - 1) - 1)

    return {
      type = "g",
      width = width,
      x = x,
      y = start_y,
      state = "fall",
      _stop_y = stop_y,
      _gate_top_y = stop_y + quantum_gate.size,
      _sink_y = stop_y + quantum_gate.size * 2,
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
        if self.state != "bounce" then
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
      end,

      _update_dy = function(self)
        if (self.state != "bounce") return
        self._dy += self._ddy
      end,
    }
  end,
}

function _init()
  game = game_class:new()
end

function _update60()
  if btnp(game.button.left) then
    game.player_cursor:move_left()
  end
  if btnp(game.button.right) then
    game.player_cursor:move_right()
  end
  if btnp(game.button.up) then
    game.player_cursor:move_up()
  end
  if btnp(game.button.down) then
    game.player_cursor:move_down()
  end
  if btnp(game.button.x) then
    game.board:put_garbage()
  end

  game.board:update()
  game.player_cursor:update()
end

function _draw()
  cls()
  game.board:draw()
  game.player_cursor:draw(game.board:screen_x(game.player_cursor.x),
                          game.board:screen_y(game.player_cursor.y),
                          game.board:dy())
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003333303333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003777303777773000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003733303337333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003730000037300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003330000033300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100000e057000570e057000570d057000570d0570d0070c0070c0070c00700007000070e057000570c057000570b057000570b0570005700007000070000700007000570b057020570a057010570a05701057
