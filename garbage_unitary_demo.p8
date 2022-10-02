pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
#include colors.lua
#include player_cursor.lua

-- todo: merge with quantum_gate_types.lua

function is_i(gate)      
  return gate.type == "i"
end

function is_h(gate)
  return gate.type == "h"
end

function is_x(gate)
  return gate.type == "x"
end

function is_y(gate)
  return gate.type == "y"
end

function is_z(gate)
  return gate.type == "z"
end

function is_s(gate)
  return gate.type == "s"
end

function is_t(gate)
  return gate.type == "t"
end

function is_control(gate)
  return gate.type == "control"
end

function is_swap(gate)
  return gate.type == "swap"
end

-- todo: implement this
function is_cnot_x(gate)
  return false
end

-- todo: rename is_garbage
function is_garbage_unitary(gate)
  return gate._type == "g"
end

-- gate states

function is_idle(gate)
  return gate.state == "idle"
end

function is_swapping(gate)
  return gate.state == "swapping_with_right" or gate.state == "swapping_with_left"
end

function is_swap_finished(gate)
  return gate.state == "swap_finished"
end

function is_droppable(gate)
  return not (is_i(gate) or is_dropping(gate) or is_swapping(gate))
end

function is_dropping(gate)
  return gate.state == "dropping"
end

function is_dropped(gate)
  return gate.state == "dropped"
end

function is_match(gate)
  return gate.state == "match"
end

function is_reducible(gate)
  return not (is_i(gate) or is_busy(gate))
end

function is_busy(gate)
  return not (is_idle(gate) or is_swap_finished(gate))
end

gate_reduction_rules = {
  reduce = function(self, board, x, y, include_next)
    include_next = include_next or false

    local y1 = y + 1
    local y2 = y + 2
    local y3 = y + 3

    if include_next then
      if y1 > board.row_next_gates then
        return {to = {}}
      end
    else
      if y1 > board.rows then
        return {to = {}}
      end    
    end

    local gate = board:reducible_gate_at(x, y)
    local gate_y1 = board:reducible_gate_at(x, y1)

    if (is_i(gate_y1)) return {to = {}}

    -- h  -->  i
    -- h       i  
    if is_h(gate) and
       is_h(gate_y1) then
      return {
        type = "hh",
        score = 100,
        to = {{},
              { dy = 1 }}
      }
    end
  
    -- x  -->  i
    -- x       i     
    if is_x(gate) and
       is_x(gate_y1) then
      return {
        type = "xx",
        score = 100,
        to = {{},
              { dy = 1 }}
      }       
    end

    -- x  -->  
    -- z       y   
    if is_x(gate) and
       is_z(gate_y1) then
      return {
        type = "xz",
        score = 200,
        to = {{},
              { dy = 1, gate = quantum_gate:new("y") }}
      }
    end

    -- y  -->  i
    -- y       i   
    if is_y(gate) and
       is_y(gate_y1) then
      return {
        type = "yy",
        score = 100,
        to = {{},
              { dy = 1 }}
      }
    end

    -- z  -->  i
    -- z       i    
    if is_z(gate) and
       is_z(gate_y1) then
      return {
        type = "zz",
        score = 100,
        to = {{},
              { dy = 1 }}
      }
    end

    -- z  -->  
    -- x       y        
    if is_z(gate) and
       is_x(gate_y1) then
      return {
        type = "zx",
        score = 200,
        to = {{},
              { dy = 1, gate = quantum_gate:new("y") }}
      }
    end

    -- s  --> 
    -- s       z        
    if is_s(gate) and
       is_s(gate_y1) then
      return {
        type = "ss",
        score = 200,
        to = {{},
              { dy = 1, gate = quantum_gate:new("z") }}
      }
    end

    -- t  -->  
    -- t       s  
    if is_t(gate) and
       is_t(gate_y1) then
      return {
        type = "tt",
        score = 200,
        to = {{},
              { dy = 1, gate = quantum_gate:new("s") }}
      }
    end

    -- s-s  -->  i i
    -- s-s       i i  
    if is_swap(gate) and is_swap(board:reducible_gate_at(gate.other_x, y)) and
       is_swap(gate_y1) and is_swap(board:reducible_gate_at(gate.other_x, y1)) then 
      local dx = gate.other_x - x
      return {
        type = "swap swap",
        score = 600,
        to = {{}, { dx = dx },
              { dy = 1 }, { dx = dx, dy = 1 }}
      }  
    end

    -- c-x  -->  i i
    -- c-x       i i
    if is_control(gate) and is_cnot_x(board:reducible_gate_at(gate.cnot_x_x, y)) and
       is_control(gate_y1) and is_cnot_x(board:reducible_gate_at(gate.cnot_x_x, y1)) and
       gate.cnot_x_x == gate_y1.cnot_x_x then
      local dx = gate.cnot_x_x - x
      return {
        type = "cnot cnot",
        score = 200,
        to = {{}, { dx = dx },
              { dy = 1 }, { dx = dx, dy = 1 }}
      }  
    end

    if include_next then
      if y2 > board.row_next_gates then
        return {to = {}}
      end       
    else
      if y2 > board.rows then
        return {to = {}}
      end    
    end

    local gate_y2 = board:reducible_gate_at(x, y2)

    -- h 
    -- x  -->  
    -- h       z
    if is_h(gate) and
       is_x(gate_y1) and
       is_h(gate_y2) then
      return {
        type = "hxh",
        score = 400,
        to = {{},
              { dy = 1 },
              { dy = 2, gate = quantum_gate:new("z") }}
      }      
    end 

    -- h 
    -- z  -->  
    -- h       x
    if is_h(gate) and
       is_z(gate_y1) and
       is_h(gate_y2) then
      return {
        type = "hzh",
        score = 400,
        to = {{},
              { dy = 1 },
              { dy = 2, gate = quantum_gate:new("x") }}
      }
    end 

    -- s
    -- z  -->  
    -- s       z
    if is_s(gate) and
       is_z(gate_y1) and
       is_s(gate_y2) then
      return {
        type = "szs",
        score = 400,
        to = {{},
              { dy = 1 },
              { dy = 2, gate = quantum_gate:new("z") }}
      }      
    end

    -- c-x
    -- x-c  --> 
    -- c-x       s-s
    if is_control(gate) and is_cnot_x(board:reducible_gate_at(gate.cnot_x_x, y)) and
       is_cnot_x(gate_y1) and is_control(board:reducible_gate_at(gate.cnot_x_x, y1)) and
       is_control(gate_y2) and is_cnot_x(board:reducible_gate_at(gate.cnot_x_x, y2)) and
       gate.cnot_x_x == gate_y1.cnot_x_x and gate.cnot_x_x == gate_y2.cnot_x_x then
      local dx = gate.cnot_x_x - x
      return {
        type = "cnot x3",
        score = 800,
        to = {{}, { dx = dx },
              { dy = 1 }, { dx = dx, dy = 1 },
              { dy = 2, gate = swap_gate:new(x + dx) }, { dx = dx, dy = 2, gate = swap_gate:new(x) }}
      }  
    end

    -- h h
    -- c-x  -->  x-c
    -- h h       
    if is_h(gate) and is_control(gate_y1) and is_h(board:reducible_gate_at(gate_y1.cnot_x_x, y)) and
       is_cnot_x(board:reducible_gate_at(gate_y1.cnot_x_x, y1)) and
       is_h(gate_y2) and is_h(board:reducible_gate_at(gate_y1.cnot_x_x, y2)) then
      local dx = gate_y1.cnot_x_x - x
      return {
        type = "hh cnot hh",
        score = 800,
        to = {{}, { dx = dx },
              { dy = 1, gate = cnot_x_gate:new(x + dx) }, { dx = dx, dy = 1, gate = control_gate:new(x) },
              { dy = 2 }, { dx = dx, dy = 2 }}
      }  
    end

    -- x x
    -- c-x  -->  c-x
    -- x         
    if (is_x(gate) and is_control(gate_y1) and is_x(board:reducible_gate_at(gate_y1.cnot_x_x, y)) and
        is_cnot_x(board:reducible_gate_at(gate_y1.cnot_x_x, y1)) and
        is_x(gate_y2)) then
      local dx = gate_y1.cnot_x_x - x
      return {
        type = "xx cnot xx",
        score = 800,
        to = {{}, { dx = dx }, { dy = 2 }}
      }  
    end

    -- z z
    -- c-x  -->  c-x
    --   z
    if is_z(gate) and is_control(gate_y1) and is_z(board:reducible_gate_at(gate_y1.cnot_x_x, y)) and
       is_cnot_x(board:reducible_gate_at(gate_y1.cnot_x_x, y1)) and
       is_z(board:reducible_gate_at(gate_y1.cnot_x_x, y2)) then
      local dx = gate_y1.cnot_x_x - x
      return {
        type = "zz cnot z",
        score = 800,
        to = {{}, { dx = dx }, { dx = dx, dy = 2 }}
      }  
    end

    -- s s       z z
    -- c-x  -->  c-x
    --   s
    if is_s(gate) and is_control(gate_y1) and is_s(board:reducible_gate_at(gate_y1.cnot_x_x, y)) and
       is_cnot_x(board:reducible_gate_at(gate_y1.cnot_x_x, y1)) and
       is_s(board:reducible_gate_at(gate_y1.cnot_x_x, y2)) then
      local dx = gate_y1.cnot_x_x - x
      return {
        type = "ss cnot s",
        score = 800,
        to = {{ gate = quantum_gate:new("z") }, { dx = dx, gate = quantum_gate:new("z") },
              { dx = dx, dy = 2 }}
      }  
    end

    -- t t       s s
    -- c-x  -->  c-x
    --   t
    if is_t(gate) and is_control(gate_y1) and is_t(board:reducible_gate_at(gate_y1.cnot_x_x, y)) and
       is_cnot_x(board:reducible_gate_at(gate_y1.cnot_x_x, y1)) and
       is_t(board:reducible_gate_at(gate_y1.cnot_x_x, y2)) then
      local dx = gate_y1.cnot_x_x - x
      return {
        type = "tt cnot t",
        score = 800,
        to = {{ gate = quantum_gate:new("s") }, { dx = dx, gate = quantum_gate:new("s") },
              { dx = dx, dy = 2 }}
      }  
    end

    -- x
    -- x-c  -->  x-c
    -- x       
    if is_x(gate) and
       is_cnot_x(gate_y1) and is_control(board:reducible_gate_at(gate_y1.cnot_c_x, y1)) and
       is_x(gate_y2) then
      return {
        type = "x cnot x",
        score = 800,
        to = {{}, { dy = 2 }}
      }  
    end   

    -- z
    -- c-x  -->  c-x
    -- z       
    if is_z(gate) and
       is_control(gate_y1) and is_cnot_x(board:reducible_gate_at(gate_y1.cnot_x_x, y1)) and
       is_z(gate_y2) then
      return {
        type = "z cnot z",
        score = 800,
        to = {{}, { dy = 2 }}
      }  
    end

    -- z
    -- h x       h
    -- x-c  -->  x-c
    -- h x       h 
    local x2 = gate_y2.cnot_c_x
    if y <= 9 and is_z(gate) and
       is_h(gate_y1) and is_cnot_x(gate_y2) and is_x(board:reducible_gate_at(x2, y1)) and
       is_control(board:reducible_gate_at(x2, y2)) and
       is_h(board:reducible_gate_at(x, y3)) and is_x(board:reducible_gate_at(x2, y3)) then
      local dx = gate_y2.cnot_c_x - x
      return {
        type = "xz cz x",
        score = 800,
        to = {{},
              { dx = dx, dy = 1 },
              { dx = dx, dy = 3 }}
      }  
    end     

    return {to = {}}
  end,
}

quantum_gate = {
  size = 8,
  _types = {"h", "x", "y", "z", "s", "t"},
  _num_frames_swap = 2,
  _num_frames_match = 45,
  _dy = 2,

  random_single_gate = function(self)
    local type = self._types[flr(rnd(#self._types)) + 1]
    return self:new(type)
  end,

  new = function(_self, type)
    return {
      type = type,
      dy = 0,
      state = "idle",

      update = function(self)
        if (self.type == "?") return

        if is_swapping(self) then
          if self.tick_swap < quantum_gate._num_frames_swap then
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
        elseif is_match(self) then
          if self.tick_match == nil then
            self.tick_match = 0
          elseif self.tick_match < quantum_gate._num_frames_match then
            self.tick_match += 1
          else
            self.tick_match = nil
            self.type = self._reduce_to.type
            self:_change_state("idle")
          end          
        end
      end,

      draw = function(self, screen_x, screen_y)
        if (is_i(self)) return
        if (self.type == "?") return

        local dx = 0
        if self.state == "swapping_with_right" then
          dx = self.tick_swap * (quantum_gate.size / quantum_gate._num_frames_swap)
        elseif self.state == "swapping_with_left" then
          dx = -self.tick_swap * (quantum_gate.size / quantum_gate._num_frames_swap)
        elseif self.state == "dropping" then
          self.dy += quantum_gate._dy
          if (screen_y + self.dy > self.stop_screen_y) then
            self.dy = self.stop_screen_y - screen_y
          end
        end

        spr(self:_sprite(), screen_x + dx, screen_y + self.dy)
      end,

      _sprite = function(self)
        local _sprites = {
          h = {
            idle = 0,
            match_up = 8,
            match_middle = 24,
            match_down = 40
          },
          x = {
            idle = 1,
            match_up = 9,
            match_middle = 25,
            match_down = 41,
          },
          y = {
            idle = 2,
            match_up = 10,
            match_middle = 26,
            match_down = 42,
          },
          z = {
            idle = 3,
            match_up = 11,
            match_middle = 27,
            match_down = 43,
          },
          s = {
            idle = 4,
            match_up = 12,
            match_middle = 28,
            match_down = 44,
          },
          t = {
            idle = 5,
            match_up = 13,
            match_middle = 29,
            match_down = 45,
          },          
        }
        local sprites = _sprites[self.type]

        if is_idle(self) or
           is_swapping(self) or
           is_swap_finished(self) or
           is_dropping(self) or
           is_dropped(self) then
          return sprites.idle
        elseif is_match(self) then
          local mod = self.tick_match % 12
          if mod <= 2 then
            return sprites.match_up
          elseif mod <= 5 then
            return sprites.match_middle
          elseif mod <= 8 then
            return sprites.match_down
          elseif mod <= 11 then
            return sprites.match_middle
          end
        else
          assert(false, "unknown state: " .. self.state)
        end
      end,

      replace_with = function(self, other)
        self._reduce_to = other
        self:_change_state("match")
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

      _change_state = function(self, new_state)
        self.state = new_state
      end,
    }
  end
}

board_class = {
  new = function(_self) 
    local board = {
      cols = 6,
      rows = 12,
      row_next_gates = 13,
      _gates = {},
      _falling_garbages = {},
      _offset_x = 10,
      _offset_y = 10,

      initialize_with_random_gates = function(self)
        for x = 1, self.cols do
          for y = self.row_next_gates, 1, -1 do
            if y >= self.rows - 2 or
               (y < self.rows - 2 and y >= 6 and rnd(1) > (y - 11) * -0.1 and (not is_i(self:gate_at(x, y + 1)))) then
              repeat
                self:put(x, y, quantum_gate:random_single_gate())
              until #gate_reduction_rules:reduce(self, x, y, true).to == 0
            else
              self:put(x, y, quantum_gate:new("i"))
            end
          end
        end      
      end,

      update = function(self)
        self:_reduce()
        self:_drop_gates()
        self:_update_falling_garbages()
        self:_update_gates()
      end,

      _reduce = function(self)
        for x = 1, self.cols do
          for y = 1, self.rows - 1 do
            if (not is_reducible(self:gate_at(x, y))) goto next

            local reduction = gate_reduction_rules:reduce(self, x, y)

            for _index, r in pairs(reduction.to) do
              local dx = r.dx or 0
              local dy = r.dy or 0
              local gate = r.gate or quantum_gate:new("i")

              self:gate_at(x + dx, y + dy):replace_with(gate)
            end

            ::next::
          end
        end
      end,      

      _drop_gates = function(self)
        for x = 1, self.cols do
          for y = self.rows - 1, 1, -1 do
            local gate = self:gate_at(x, y)
            if (gate.type == "?") goto next
            if (gate.type == "g") goto next
            if (not is_droppable(gate)) goto next

            if is_i(self:gate_at(x, y + 1)) then
              local stop_y = y
              while is_i(self:gate_at(x, stop_y + 1)) or is_dropping(self:gate_at(x, stop_y + 1)) do
                stop_y += 1
              end
              gate:drop(self:screen_y(y), self:screen_y(stop_y))
              self:put(x, stop_y, quantum_gate:new("?"))
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
          for y = 1, self.row_next_gates do
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

      reducible_gate_at = function(self, x, y)
        local gate = self:gate_at(x, y)

        if (is_reducible(gate)) return gate
        return quantum_gate:new("i")
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
      _spr = 57,
      _spr_left = 56,
      _spr_right = 58,
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
  local cursor = game.player_cursor

  if btnp(game.button.left) then
    sfx(0)
    cursor:move_left()
  end
  if btnp(game.button.right) then
    sfx(0)
    cursor:move_right()
  end
  if btnp(game.button.up) then
    sfx(0)
    cursor:move_up()
  end
  if btnp(game.button.down) then
    sfx(0)
    cursor:move_down()
  end
  if btnp(game.button.x) then
    local swapped = game.board:swap(cursor.x, cursor.x + 1, cursor.y)
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
  cursor:update()
end

function _draw()
  cls()
  game.board:draw()
  game.player_cursor:draw(game.board:screen_x(game.player_cursor.x),
                          game.board:screen_y(game.player_cursor.y),
                          game.board:dy())
end

__gfx__
0888880000ccc000099999000eeeee000bbbbb0002222200000000000000000006ddd60000d6d00006ddd600066666000d666600066666007777777777777700
8e888e800cc6cc009f999f90efffffe0bb3333b02eeeee200000000000000000d6ddd6d00dd6dd00dd6d6dd0dddd6dd0d6ddddd0ddd6ddd0ddddddddddddd770
8e888e80ccc6ccc099f9f990eeeefee0b3bbbbb0222e22200000000000000000d66666d0d66666d0ddd6ddd0ddd6ddd0dd666dd0ddd6ddd07777777777777d70
8eeeee80c66666c0999f9990eeefeee0bb333bb0222e22200000000000000000d6ddd6d0ddd6ddd0ddd6ddd0dd6dddd0ddddd6d0ddd6ddd07777777777777d70
8e888e80ccc6ccc0999f9990eefeeee0bbbbb3b0222e22200000000000000000d6ddd6d0ddd6ddd0ddd6ddd0d66666d0d6666dd0ddd6ddd07777777777777d70
8e888e801cc6cc10999f9990efffffe0b3333bb0222e22200000000000000000ddddddd01ddddd10ddddddd0ddddddd0ddddddd0ddddddd0ddddddddddddd770
1888881001ccc100199999101eeeee101bbbbb101222221000000000000000001ddddd1001ddd1001ddddd101ddddd101ddddd101ddddd107777777777777700
01111100001110000111110001111100011111000111110000000000000000000111110000111000011111000111110001111100011111000000000000000000
08888800000000000000000000000000000000000000000000000000000000000ddddd0000ddd0000ddddd000ddddd000ddddd000ddddd000000000000000000
8888888000000000000000000000000000000000000000000000000000000000d6ddd6d00dd6dd00d6ddd6d0d66666d0dd6666d0d66666d00000000000000000
8888888000000000000000000000000000000000000000000000000000000000d6ddd6d0ddd6ddd0dd6d6dd0dddd6dd0d6ddddd0ddd6ddd00000000000000000
8e888e8000000000000000000000000000000000000000000000000000000000d66666d0d66666d0ddd6ddd0ddd6ddd0dd666dd0ddd6ddd00000000000000000
8e888e8000000000000000000000000000000000000000000000000000000000d6ddd6d0ddd6ddd0ddd6ddd0dd6dddd0ddddd6d0ddd6ddd00000000000000000
8eeeee8000000000000000000000000000000000000000000000000000000000d6ddd6d01dd6dd10ddd6ddd0d66666d0d6666dd0ddd6ddd00000000000000000
1e888e10000000000000000000000000000000000000000000000000000000001ddddd1001ddd1001ddddd101ddddd101ddddd101ddddd100000000000000000
01111100000000000000000000000000000000000000000000000000000000000111110000111000011111000111110001111100011111000000000000000000
0e888e00000000000000000000000000000000000000000000000000000000000ddddd0000ddd0000ddddd000ddddd000ddddd000ddddd000000000000000000
8e888e8000000000000000000000000000000000000000000000000000000000ddddddd00ddddd00ddddddd0ddddddd0ddddddd0ddddddd00000000000000000
8eeeee8000000000000000000000000000000000000000000000000000000000d6ddd6d0ddd6ddd0d6ddd6d0d66666d0dd6666d0d66666d00000000000000000
8e888e8000000000000000000000000000000000000000000000000000000000d6ddd6d0ddd6ddd0dd6d6dd0dddd6dd0d6ddddd0ddd6ddd00000000000000000
8e888e8000000000000000000000000000000000000000000000000000000000d66666d0d66666d0ddd6ddd0ddd6ddd0dd666dd0ddd6ddd00000000000000000
8888888000000000000000000000000000000000000000000000000000000000d6ddd6d01dd6dd10ddd6ddd0dd6dddd0ddddd6d0ddd6ddd00000000000000000
188888100000000000000000000000000000000000000000000000000000000016ddd61001d6d1001dd6dd101666661016666d101dd6dd100000000000000000
01111100000000000000000000000000000000000000000000000000000000000111110000111000011111000111110001111100011111000000000000000000
00000000000000000000000000000000000000000000000000000000000000000777777777777777777777000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000077ddddddddddddddddddd7700000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000007d7777777777777777777d700000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000007d7777777777777777777d700000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000007d7777777777777777777d700000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000077ddddddddddddddddddd7700000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000777777777777777777777000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000333300333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003777303777773000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003733303337333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003730000037300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003330000033300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000010057000570e057000570d057000570d0570d0070c0070c0070c00700007000070e057000570c057000570b057000570b0570005700007000070000700007000570b057020570a057010570a05701057
000100002b0102d01031010336102e0102f0103160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
