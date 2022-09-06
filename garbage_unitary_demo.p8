pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
#include colors.lua
#include player_cursor.lua

-- todo: merge with quantum_gate_types.lua

function is_i(gate)      
  return gate.type == "i"
end

function is_idle(gate)
  return gate.state == "idle"
end

function is_swapping(gate)
  return gate.state == "swapping_with_right" or gate.state == "swapping_with_left"
end

function is_swap_finished(gate)
  return gate.state == "swap_finished"
end

function is_dropping(gate)
  return gate.state == "dropping"
end

function is_dropped(gate)
  return gate.state == "dropped"
end

quantum_gate = {
  size = 8,
  types = {"h", "x", "y", "z", "s", "t"},
  _spr = {h=0, x=1, y=2, z=3, s=4, t=5},
  num_frames_swap = 2,
  _dy = 16,

  new = function(_self, type)
    return {
      type = type,
      dy = 0,

      update = function(self)
        if (self.type == "?") return

        if is_swapping(self) then
          if self.tick_swap < quantum_gate.num_frames_swap then
            self.tick_swap += 1
          else
            self:_change_state("swap_finished")
          end          
        elseif is_swap_finished(self) then
          self:_change_state("idle")
        elseif is_dropping(self) then
          if self.start_screen_y + self.dy == self.stop_screen_y then
            self:_change_state("dropped")
          end
        elseif is_dropped(self) then
          self.dy = 0
          self:_change_state("idle")
        end
      end,

      draw = function(self, screen_x, screen_y)
        if (is_i(self)) return
        if (self.type == "?") return

        local dx = 0
        local dy = 0
        if self.state == "swapping_with_right" then
          dx = self.tick_swap * (quantum_gate.size / quantum_gate.num_frames_swap)
        elseif self.state == "swapping_with_left" then
          dx = -self.tick_swap * (quantum_gate.size / quantum_gate.num_frames_swap)
        elseif self.state == "dropping" then
          self.dy += quantum_gate._dy
          if (screen_y + self.dy > self.stop_screen_y) then
            self.dy = self.stop_screen_y - screen_y
          end
        end

        spr(quantum_gate._spr[self.type], screen_x + dx, screen_y + self.dy)
      end,

      start_swap_with_right = function(self, swap_new_x)
        self.tick_swap = 0
        self.swap_new_x = swap_new_x
        self:_change_state("swapping_with_right")
      end,

      start_swap_with_left = function(self, swap_new_x)
        self.tick_swap = 0
        self.swap_new_x = swap_new_x
        self:_change_state("swapping_with_left")
      end,

      drop = function(self, start_screen_y, stop_screen_y)
        self.dy = 0
        self.start_screen_y = start_screen_y
        self.stop_screen_y = stop_screen_y
        self:_change_state("dropping")
      end,

      is_droppable = function(self)
        return (not is_i(self)) and (not is_dropping(self)) and (not is_swapping(self))
      end,

      _change_state = function(self, new_state)
        self.state = new_state
      end,
    }
  end
}

function random_gate()
  local type = quantum_gate.types[flr(rnd(#quantum_gate.types)) + 1]
  return quantum_gate:new(type)
end

board_class = {
  new = function(_self) 
    local board = {
      cols = 6,
      rows = 12,
      rows_plus_next_rows = 13,
      _gates = {},
      _falling_garbages = {},
      _offset_x = 10,
      _offset_y = 10,

      initialize_with_random_gates = function(self)
        for x = 1, self.cols do
          for y = self.rows_plus_next_rows, 1, -1 do
            if y >= self.rows - 2 or
               (y < self.rows - 2 and y >= 6 and rnd(1) > (y - 11) * -0.1 and (not is_i(self:gate_at(x, y + 1)))) then
              self:put(x, y, random_gate())
            else
              self:put(x, y, quantum_gate:new("i"))
            end
          end
        end      
      end,

      update = function(self)
        self:_drop_gates()
        self:_update_falling_garbages()
        self:_update_gates()
      end,

      _drop_gates = function(self)
        for x = 1, self.cols do
          for y = self.rows - 1, 1, -1 do
            local gate = self:gate_at(x, y)
            if (gate.type == "?") goto next
            if (gate.type == "g") goto next
            if (not gate:is_droppable()) goto next

            if is_i(self:gate_at(x, y + 1)) then
              local stop_y = y
              while is_i(self:gate_at(x, stop_y + 1)) or is_dropping(self:gate_at(x, stop_y + 1)) do
                stop_y += 1
              end
              gate:drop(self:screen_y(y), self:screen_y(stop_y))
              self:put(x, stop_y, quantum_gate:new("?"))

              -- printh("drop " .. gate.type .. "(" .. y .. " -> ".. stop_y ..")")
            end

            ::next::
          end
        end
      end,

      _update_falling_garbages = function(self)
        foreach(self._falling_garbages, function(each)
          if each.state == "hit gate" then
            self:put(each.x, self:y(each.stop_y), each)
          elseif each.state == "idle" then
            del(self._falling_garbages, each)
          end

          each:update()
        end)      
      end,

      _update_gates = function(self)
        local gates_to_swap = {}

        for x = 1, self.cols do
          for y = self.rows, 1, -1 do
            local gate = self:gate_at(x, y)
            if (gate.type == "?") goto next

            gate:update()

            if is_swap_finished(gate) then
              add(gates_to_swap, { gate = gate, y = y })
            end
            if is_dropped(gate) then
              printh("gate.type = " .. gate.type)

              self:put(x, self:y(gate.stop_screen_y), gate)
              self:put(x, self:y(gate.start_screen_y), quantum_gate:new("i"))
            end

            ::next::
          end
        end

        foreach(gates_to_swap, function(each)
          self:put(each.gate.swap_new_x, each.y, each.gate)
        end)        
      end,

      draw = function(self)
        -- draw idle gates
        for x = 1, self.cols do
          for y = 1, self.rows_plus_next_rows do
            local gate = self:gate_at(x, y)
            if (not gate) goto next

            local screen_x = self:screen_x(x)
            local screen_y = self:screen_y(y) + self:dy()
            gate:draw(screen_x, screen_y)

            ::next::
          end
        end

        -- draw falling garbage unitaries
        foreach(self._falling_garbages, function(each)
          each:draw(self:screen_x(each.x))
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

      swap = function(self, x_left, x_right, y)
        -- if not self:is_swappable(x_left, x_right, y) then
        --   return false
        -- end

        local left_gate = self:gate_at(x_left, y)
        local right_gate = self:gate_at(x_right, y)

        left_gate:start_swap_with_right(x_right)
        right_gate:start_swap_with_left(x_left)

        return true
      end,

      dy = function(self)
        if (#self._falling_garbages != 0) then
          return self._falling_garbages[#self._falling_garbages]:dy()
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

      put = function(self, x, y, gate)
        self._gates[x][y] = gate
      end,

      put_garbage = function(self)
        local width = flr(rnd(4)) + 3

        add(self._falling_garbages, garbage:new(width, self))
      end,

      gate_top_y = function(self, x_start, x_end)
        for y = 1, self.rows do
          for x = x_start, x_end do
            if (not is_i(self:gate_at(x, y))) return y
          end

          for x = 1, self.cols do
            local gate = self:gate_at(x, y)
            if (gate.type != "g") goto next

            for gx = x, x + gate.width - 1, 1 do
              if (x_start <= gx and gx <= x_end) return y
            end

            ::next::
          end
        end
        return 1
      end,      
    }

    -- initialize the board
    for x = 1, board.cols do
      board._gates[x] = {}
    end
    board:initialize_with_random_gates()

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

garbage = {
  new = function(_self, width, board)
    local random_x = flr(rnd(board.cols - width + 1)) + 1
    local start_y = board:screen_y(1)
    local stop_y = board:screen_y(board:gate_top_y(random_x, random_x + width - 1) - 1)

    return {
      type = "g",
      width = width,
      x = random_x,
      y = start_y,
      state = "fall",
      stop_y = stop_y,
      _spr = 14,
      _spr_left = 13,
      _spr_right = 15,
      _gate_top_y = stop_y + quantum_gate.size,
      _sink_y = stop_y + quantum_gate.size * 2,
      _dy = 16,
      _ddy = 0.98,

      update = function(self)
        self:_update_y()
        self:_update_state()
        self:_update_dy()
      end,

      draw = function(self, screen_x, screen_y)
        for x = 0, self.width - 1 do
          local spr_id = self._spr
          if (x == 0) spr_id = self._spr_left
          if (x == self.width - 1) spr_id = self._spr_right

          if screen_y then
            spr(spr_id, screen_x + x * quantum_gate.size, screen_y)
          elseif self.state == "fall" then
            spr(spr_id, screen_x + x * quantum_gate.size, self.y)
          end
        end
      end,

      dy = function(self)
        if self.state == "sink" or self.state == "bounce" then
          return self.y - self.stop_y
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
              sfx(1)
            else
              self:_change_state("sink")
            end
          end
        else
          -- bounce
          if self.y > self.stop_y and self._dy > 0 then
            self.y = self.stop_y
            self._dy = -self._dy * 0.6
          end
        end

        if (self.y == self.stop_y and
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
  local player_cursor = game.player_cursor

  if btnp(game.button.left) then
    sfx(0)
    player_cursor:move_left()
  end
  if btnp(game.button.right) then
    sfx(0)
    player_cursor:move_right()
  end
  if btnp(game.button.up) then
    sfx(0)
    player_cursor:move_up()
  end
  if btnp(game.button.down) then
    sfx(0)
    player_cursor:move_down()
  end
  if btnp(game.button.x) then
    local swapped = game.board:swap(player_cursor.x, player_cursor.x + 1, player_cursor.y)
    -- if swapped == false then
    --   self.player_cursor.cannot_swap = true
    -- end

    if swapped then
      sfx(2)        
    end
  end
  if btnp(game.button.o) then
    game.board:put_garbage()
  end

  game.board:update()
  player_cursor:update()
end

function _draw()
  cls()
  game.board:draw()
  game.player_cursor:draw(game.board:screen_x(game.player_cursor.x),
                          game.board:screen_y(game.player_cursor.y),
                          game.board:dy())
end

__gfx__
0888880000ccc000099999000eeeee000bbbbb000222220000000000000000000000000000000000000000000000000000000000077777777777777777777700
8e888e800cc6cc009f999f90efffffe0bb3333b02eeeee200000000000000000000000000000000000000000000000000000000077ddddddddddddddddddd770
8e888e80ccc6ccc099f9f990eeeefee0b3bbbbb0222e2220000000000000000000000000000000000000000000000000000000007d7777777777777777777d70
8eeeee80c66666c0999f9990eeefeee0bb333bb0222e2220000000000000000000000000000000000000000000000000000000007d7777777777777777777d70
8e888e80ccc6ccc0999f9990eefeeee0bbbbb3b0222e2220000000000000000000000000000000000000000000000000000000007d7777777777777777777d70
8e888e801cc6cc10999f9990efffffe0b3333bb0222e22200000000000000000000000000000000000000000000000000000000077ddddddddddddddddddd770
1888881001ccc100199999101eeeee101bbbbb101222221000000000000000000000000000000000000000000000000000000000077777777777777777777700
01111100001110000111110001111100011111000111110000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100002202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000010057000570e057000570d057000570d0570d0070c0070c0070c00700007000070e057000570c057000570b057000570b0570005700007000070000700007000570b057020570a057010570a05701057
000100002b0102d01031010336102e0102f0103160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
