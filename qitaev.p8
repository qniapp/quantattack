pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
colors = {
  ["dark_blue"] = 1,
  ["dark_purple"] = 2,
  ["dark_green"] = 3,
  ["brown"] = 4,
  ["dark_grey"] = 5,
  ["light_grey"] = 6,
  ["white"] = 7,
  ["red"] = 8,
  ["orange"] = 9,
  ["yellow"] = 10,
  ["blue"] = 12,
}

dropping_particle = {
  all = {},

  create = function(self, x, y, init_size, color)
    local p = {}
    local left = false

    if flr(rnd(2)) == 0 then
      left = true
    end

    p.x = x
    p.y = y
    p.color = color
    p.width = init_size
    p.tick = 0
    p.max_tick = 20 + rnd(10)
    p.dx = (rnd(.8)) * .4
    p.dy = rnd(.05)
    p.ddy = .02

    if (left) then
      p.dx *= -1
    end

    add(dropping_particle.all, p)

    return p
  end,

  update = function(self)
    foreach(dropping_particle.all, function(p)
      if (p.tick > p.max_tick) then
        del(dropping_particle.all, p)
      end
      if (p.tick > p.max_tick - 5) then
        p.color = colors.dark_grey
      end

      p.x = p.x + p.dx
      p.y = p.y + p.dy
      p.dy = p.dy + p.ddy
      p.tick = p.tick + 1
    end)
  end,

  draw = function(self)
    foreach(dropping_particle.all, function(p)
      circfill(p.x, p.y, p.width, p.color)
    end)
  end
}

gate_reduction_rules = {
  reduce = function(self, board, x, y, include_next)
    include_next = include_next or false

    if include_next then
      if y + 1 > board.rows + board.next_row then
        return {}
      end
    else
      if y + 1 > board.rows then
        return {}
      end    
    end

    if (board:idle_gate_at(x, y):is_h() and
        board:idle_gate_at(x, y + 1):is_h()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.i() },
      }
    end

    if (board:idle_gate_at(x, y):is_x() and
        board:idle_gate_at(x, y + 1):is_x()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.i() },
      }
    end

    if (board:idle_gate_at(x, y):is_y() and
        board:idle_gate_at(x, y + 1):is_y()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.i() },
      }
    end

    if (board:idle_gate_at(x, y):is_z() and
        board:idle_gate_at(x, y + 1):is_z()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.i() },
      }
    end

    if (board:idle_gate_at(x, y):is_z() and
        board:idle_gate_at(x, y + 1):is_x()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.y() },
      }
    end

    if (board:idle_gate_at(x, y):is_x() and
        board:idle_gate_at(x, y + 1):is_z()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.y() },
      }
    end

    if (board:idle_gate_at(x, y):is_s() and
        board:idle_gate_at(x, y + 1):is_s()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.z() },
      }
    end

    if (board:idle_gate_at(x, y):is_t() and
        board:idle_gate_at(x, y + 1):is_t()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.s() },
      }
    end

    if include_next then
      if y + 2 > board.rows + board.next_row then
        return {}
      end       
    else
      if y + 2 > board.rows then
        return {}
      end    
    end

    if (board:idle_gate_at(x, y):is_h() and
        board:idle_gate_at(x, y + 1):is_x() and
        board:idle_gate_at(x, y + 2):is_h()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 2, ["gate"] = gate.z() },
      }      
    end 

    if (board:idle_gate_at(x, y):is_h() and
        board:idle_gate_at(x, y + 1):is_z() and
        board:idle_gate_at(x, y + 2):is_h()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 2, ["gate"] = gate.x() },
      }
    end 

    if (board:idle_gate_at(x, y):is_s() and
        board:idle_gate_at(x, y + 1):is_z() and
        board:idle_gate_at(x, y + 2):is_s()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 2, ["gate"] = gate.z() },
      }      
    end

    -- c -- x   x -- c
    -- x -- c   c -- x  --> 
    -- c -- x,  x -- c       swap -- swap
    if (board:idle_gate_at(x, y):is_c() and
       (board:idle_gate_at(x, y + 1):is_cnot_x()) and
        board:idle_gate_at(x, y + 2):is_c() and
        board:idle_gate_at(board:idle_gate_at(x, y).xx, y + 1):is_c() and
        board:idle_gate_at(board:idle_gate_at(x, y).xx, y + 2):is_cnot_x()) then
      local dx = board:idle_gate_at(x, y).xx - x
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() }, { ["dx"] = dx, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.i() }, { ["dx"] = dx, ["dy"] = 1, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 2, ["gate"] = gate.swap() }, { ["dx"] = dx, ["dy"] = 2, ["gate"] = gate.swap() },
      }  
    end

    -- todo:
    -- h    h
    -- c -- x  -->
    -- h    h       x -- c

    return {}
  end,
}

board = {
  cols = 6,
  rows = 12,
  next_row = 1,
  cnot_probability = 0.1,

  new = function(self, top, left)
    local b = {
      init = function(self, top, left)
        self.gate = {}
        self.top = top
        self.left = left
        self.cols = board.cols
        self.rows = board.rows
        self.next_row = board.next_row
        self.raised_dots = 0

        for x = 1, board.cols do
          self.gate[x] = {}
          for y = board.rows + board.next_row, 1, -1 do
            if y >= board.rows - 2 or
               (y < board.rows - 2 and y >= 6 and rnd(1) > (y - 11) * -0.1 and (not self.gate[x][y + 1]:is_i())) then
              repeat
                self:set(x, y, self:_random_gate())
              until (#gate_reduction_rules:reduce(self, x, y, true) == 0)
            else
              self:set(x, y, gate.i())
            end
          end
        end
      end,

      idle_gate_at = function(self, x, y)
        assert(x >= 1 and x <= board.cols)
        assert(y >= 1 and y <= board.rows + board.next_row)

        if self.gate[x][y]:is_idle() then
          return self.gate[x][y]
        else
          return gate.i()
        end
      end,

      set = function(self, x, y, gate)
        assert(x >= 1 and x <= board.cols)
        assert(y >= 1 and y <= board.rows + board.next_row)

        self.gate[x][y] = gate
      end,

      update = function(self)
        self:reduce()
        self:drop_gates()
        self:update_gates()
      end,

      draw = function(self)
        for bx = 1, board.cols do
          for by = board.rows + board.next_row, 1, -1 do
            local x = self.left + (bx - 1) * gate.size
            local y = self.top + (by - 1) * gate.size

            wire:draw(x, y - self.raised_dots)

            local gate = self.gate[bx][by]

            if gate:is_swapping_with_left() then
              gate:draw(x + 4, y - self.raised_dots)
            elseif gate:is_swapping_with_right() then
              gate:draw(x - 4, y - self.raised_dots)
            else
              gate:draw(x, y - self.raised_dots)
            end
          end
        end

        for bx = 1, board.cols do
          for by = board.rows + board.next_row, 1, -1 do
            local x = self.left + (bx - 1) * gate.size
            local y = self.top + (by - 1) * gate.size
            local gate = self.gate[bx][by]

            -- draw cnot laser
            if gate:is_c() and rnd(1) > 0.3 then
              local lx0 = x + 3
              local ly0 = y + 3 - self.raised_dots
              local lx1 = self.left + (self.gate[bx][by].xx - 1) * 8 + 3
              local ly1 = ly0

              line(lx0, ly0, lx1, ly1, colors.yellow)
            end

            -- draw cnot gates over the cnot laser
            if gate:is_c() or gate:is_cnot_x() then
              gate:draw(x, y - self.raised_dots)
            end

            if (by == board.rows + board.next_row) then
              spr(64, x, y - self.raised_dots)
            end
          end
        end
      end,

      swap = function(self, xl, xr, y)
        local left_gate = self.gate[xl][y]
        local right_gate = self.gate[xr][y]
        assert(left_gate ~= nil)
        assert(right_gate ~= nil)

        if not self:is_swappable(left_gate, right_gate) then
          return false
        end

        left_gate:swap_with_right()
        right_gate:swap_with_left()

        self:set(xr, y, left_gate)
        self:set(xl, y, right_gate)

        -- c x
        -- c _ _ x
        if (left_gate:is_c()) then
          if left_gate.xx == xr then
            left_gate.xx = xl
          end
          local x_gate = self.gate[left_gate.xx][y]
          assert(x_gate:is_cnot_x())
          x_gate.cx = xr
        end
        -- _ _ x c
        -- x _ _ c
        if (right_gate:is_c()) then
          if right_gate.xx == xl then
            right_gate.xx = xr
          end
          local x_gate = self.gate[right_gate.xx][y]
          assert(x_gate:is_cnot_x())
          x_gate.cx = xl
        end
        -- x c
        -- x _ _ c
        if (left_gate:is_cnot_x()) then
          if left_gate.cx == xr then
            left_gate.cx = xl
          end
          local c_gate = self.gate[left_gate.cx][y]
          assert(c_gate:is_c())
          c_gate.xx = xr
        end
        -- _ _ c x
        -- c _ _ x
        if (right_gate:is_cnot_x()) then
          if right_gate.cx == xl then
            right_gate.cx = xr
          end
          local c_gate = self.gate[right_gate.cx][y]
          assert(c_gate:is_c())
          c_gate.xx = xl
        end        
      end,

      is_swappable = function(self, left_gate, right_gate)
        return (left_gate:is_idle() or left_gate:is_dropped()) and
                 (right_gate:is_idle() or right_gate:is_dropped())
      end,

      reduce = function(self)
        for x = 1, board.cols do
          for y = board.rows - 1, 1, -1 do
            if self.gate[x][y]:is_idle() then
              reduction = gate_reduction_rules:reduce(self, x, y)
              for index, r in pairs(reduction) do
                self.gate[x + r.dx][y + r.dy]:replace_with(r.gate)
              end
            end
          end
        end
      end,

      gates_in_action = function(self)
        local gates = {}

        for x = 1, board.cols do
          for y = 1, board.rows do
            if not self.gate[x][y]:is_idle() then
              add(gates, self.gate[x][y])
            end
          end
        end

        return gates
      end,

      gates_dropped_bottom = function(self)
        local gates = {}

        for x = 1, board.cols do
          for y = 1, board.rows do
            local gate = self.gate[x][y]
            local gate_below = self.gate[x][y + 1]

            if ((not gate:is_i()) and
                gate:is_dropped() and
                gate.tick_drop == 0 and
                (gate_below == nil or (not gate_below:is_dropped()))) then
              gate.x = x
              gate.y = y
              add(gates, gate)
            end
          end
        end

        return gates
      end,

      gates_changing_to_i = function(self)
        local gates = {}

        for x = 1, board.cols do
          for y = 1, board.rows do
            local gate = self.gate[x][y]

            if gate:is_changing_to_i() then
              gate.x = x
              gate.y = y
              add(gates, gate)
            end
          end
        end

        return gates
      end,

      drop_gates = function(self)
        for x = 1, board.cols do
          for y = board.rows - 1, 1, -1 do
            local tmp_y = y

            while ((not self.gate[x][tmp_y]:is_c()) and
                   (not self.gate[x][tmp_y]:is_cnot_x()) and
                    self:is_droppable(x, tmp_y)) do
              self.gate[x][tmp_y + 1] = self.gate[x][tmp_y]
              self.gate[x][tmp_y] = gate.i()
              tmp_y += 1
            end

            if (tmp_y > y) then
              self.gate[x][tmp_y]:dropped()
            end
          end
        end

        -- drop cnot pairs
        for x = 1, board.cols do
          for y = board.rows - 1, 1, -1 do
            local tmp_y = y

            while (self.gate[x][tmp_y]:is_c() and
                   self.gate[x][tmp_y]:is_idle() and
                   self:is_droppable(x, tmp_y) and
                   (not self:overlap_with_cnot(x, tmp_y + 1)) and
                   self:is_droppable(self.gate[x][tmp_y].xx, tmp_y) and
                   (not self:overlap_with_cnot(self.gate[x][tmp_y].xx, tmp_y + 1))) do
              local cnot_c = self.gate[x][tmp_y]
              local cnot_x = self.gate[cnot_c.xx][tmp_y]

              assert(cnot_x:is_cnot_x())

              self.gate[x][tmp_y + 1] = cnot_c
              self.gate[x][tmp_y] = gate.i()
              self.gate[cnot_c.xx][tmp_y + 1] = cnot_x
              self.gate[cnot_c.xx][tmp_y] = gate.i()
              tmp_y += 1
            end

            if (tmp_y > y) then
              self.gate[x][tmp_y]:dropped()
            end
          end
        end
      end,

      is_droppable = function(self, x, y)
        local result = false
        local gate = self.gate[x][y]
        local gate_below = self.gate[x][y + 1]

        return ((not gate:is_i()) and 
                 gate:is_idle() and
                 y + 1 <= board.rows and
                 gate_below:is_i())
      end,

      overlap_with_cnot = function(self, x, y)
        local control_gate = nil
        local x_gate = nil
        local control_gate_x = nil
        local x_gate_x = nil

        for bx = 1, board.cols do
          if self.gate[bx][y]:is_c() then
            control_gate = self.gate[bx][y]
            control_gate_x = bx
          end
          if self.gate[bx][y]:is_cnot_x() then
            x_gate = self.gate[bx][y]
            x_gate_x = bx
          end
        end

        if control_gate == nil and x_gate == nil then
          return false
        end

        if (control_gate_x < x and x < x_gate_x) or
           (x_gate_x < x and x < control_gate_x) then
          return true
        end

        return false
      end,

      insert_gates_at_bottom = function(self)
        for x = 1, board.cols do
          for y = 1, board.rows + board.next_row - 1 do
            if y == 1 and (not self.gate[x][y]:is_i()) then
              self:game_over()
            else
              self.gate[x][y] = self.gate[x][y + 1]
            end
          end
        end

        for x = 1, board.cols do
          repeat
            self:set(x, board.rows + board.next_row, self:_random_gate())
            gate_reduction_rules:reduce(self, x, board.rows - 1, true)
          until (#gate_reduction_rules:reduce(self, x, board.rows, true) == 0)
        end

        -- maybe add cnot
        if rnd(1) < board.cnot_probability then
          local cx = flr(rnd(board.cols)) + 1
          local xx = nil
          repeat
            xx = flr(rnd(board.cols)) + 1
          until xx ~= cx

          local x_gate = gate.x(cx)
          local control_gate = gate.c(xx)
          self:set(xx, board.rows + board.next_row, x_gate)
          self:set(cx, board.rows + board.next_row, control_gate)

          local cnot_left_x = min(cx, xx)
          local cnot_right_x = max(cx, xx)
          for x = cnot_left_x + 1, cnot_right_x - 1 do
            self:set(x, board.rows + board.next_row, gate.i())
          end          
        end
      end,

      update_gates = function(self)
        for x = 1, board.cols do
          for y = 1, board.rows do
            self.gate[x][y]:update()
          end
        end
      end,

      raise_one_dot = function(self)
        self.raised_dots += 1
        if self.raised_dots == 8 then
          self.raised_dots = 0
        end
      end,

      game_over = function(self)
        assert(false, "game over")
      end,

      -- private

      _random_gate = function(self)
        local g = nil
        repeat
          g = gate:new(gate.types[flr(rnd(#gate.types)) + 1])
        until ((not g:is_i()) and (not g:is_c()) and (not g:is_swap()))

        return g
      end,
    }

    b:init(top, left)

    return b
  end,
}

wire = {
  _sprite = 65,

  draw = function(self, x, y)
    spr(self._sprite, x, y)
  end,
}

gate = {
  types = {"h", "x", "y", "z", "s", "t", "c", "swap", "i"},

  sprites = {
    ["idle"] = {
      ["h"] = 0,
      ["x"] = 1,
      ["y"] = 2,
      ["z"] = 3,
      ["s"] = 4,
      ["t"] = 5,
      ["c"] = 6,
      ["swap"] = 7,
    },
    ["dropped"] = {
      ["h"] = 16,
      ["x"] = 17,
      ["y"] = 18,
      ["z"] = 19,
      ["s"] = 20,
      ["t"] = 21,
      ["c"] = 22,
      ["swap"] = 23,
    },
    ["jumping"] = {
      ["h"] = 48,
      ["x"] = 49,
      ["y"] = 50,
      ["z"] = 51,
      ["s"] = 52,
      ["t"] = 53,
      ["c"] = 54,
      ["swap"] = 55,
    },
    ["falling"] = {
      ["h"] = 32,
      ["x"] = 33,
      ["y"] = 34,
      ["z"] = 35,
      ["s"] = 36,
      ["t"] = 37,
      ["c"] = 38,
      ["swap"] = 39,
    },    
    ["match_up"] = {
      ["h"] = 8,
      ["x"] = 9,
      ["y"] = 10,
      ["z"] = 11,
      ["s"] = 12,
      ["t"] = 13,
      ["c"] = 14,
      ["swap"] = 15,
    },
    ["match_middle"] = {
      ["h"] = 24,
      ["x"] = 25,
      ["y"] = 26,
      ["z"] = 27,
      ["s"] = 28,
      ["t"] = 29,
      ["c"] = 30,
      ["swap"] = 31,
    },     
    ["match_down"] = {
      ["h"] = 40,
      ["x"] = 41,
      ["y"] = 42,
      ["z"] = 43,
      ["s"] = 44,
      ["t"] = 45,
      ["c"] = 46,
      ["swap"] = 47,
    },    
  },

  size = 8,

  num_frames_swap = 4,
  num_frames_match = 60,

  new = function(self, type)
    return {
      type = type,
      replace_with_type = nil,
      _state = "idle",

      draw = function(self, x, y)
        if self:is_i() then return end

        if self:is_cnot_x() then
          pal(colors.light_grey, colors.brown)
          pal(colors.dark_blue, colors.light_grey)
        end

        spr(self:_sprite(), x, y)

        pal(colors.light_grey, colors.light_grey)
        pal(colors.dark_blue, colors.dark_blue)
      end,

      replace_with = function(self, other)
        assert(not self:is_i())
        assert(other.type)

        if self._state != "idle" then
          return
        end

        self.replace_with_type = other.type
        self:change_state("match")
        self.tick_match = 0
      end,

      dropped = function(self)
        self:change_state("dropped")
      end,

      change_state = function(self, new_state)
        assert(new_state)

        self._state = new_state
      end,

      swap_with_left = function(self)
        self:change_state("swapping_with_left")
      end,

      swap_with_right = function(self)
        self:change_state("swapping_with_right")
      end,

      update = function(self)
        if self:is_idle() then
          return
        elseif self:is_swapping() then
          if self.tick_swap == nil then
            self.tick_swap = 0
          elseif self.tick_swap < gate.num_frames_swap then
            self.tick_swap += 1
          else
            self:change_state("idle")
          end
        elseif self:is_match() then
          if self.tick_match == nil then
            self.tick_match = 0
          elseif self.tick_match < gate.num_frames_match then
            self.tick_match += 1
          else
            self.type = self.replace_with_type
            self:change_state("idle")
          end
        elseif self:is_dropped() then
          if self.tick_drop == nil then
            self.tick_drop = 0
          else
            self.tick_drop += 1
            if self.tick_drop == 12 then
               self.tick_drop = nil
               self:change_state("idle")
            end
          end
        else
          assert(false, "we should never get here")
        end
      end,

      is_idle = function(self)
        return self._state == "idle"
      end,

      is_swapping = function(self)
        return self:is_swapping_with_left() or self:is_swapping_with_right()
      end,

      is_swapping_with_left = function(self)
        return self._state == "swapping_with_left"
      end,

      is_swapping_with_right = function(self)
        return self._state == "swapping_with_right"
      end,

      is_match = function(self)
        return self._state == "match"
      end,

      is_dropped = function(self)
        return self._state == "dropped"
      end,

      is_changing_to_i = function(self)
        return self.tick_match == gate.num_frames_match - 1 and self.replace_with_type == "i"
      end,

      is_h = function(self)
        return self.type == "h"
      end,

      is_x = function(self)
        return self.type == "x" and self.cx == nil
      end,

      is_cnot_x = function(self)
        return self.type == "x" and self.cx != nil
      end,

      is_y = function(self)
        return self.type == "y"
      end,

      is_z = function(self)
        return self.type == "z"
      end,

      is_s = function(self)
        return self.type == "s"
      end,

      is_t = function(self)
        return self.type == "t"
      end,

      is_c = function(self)
        -- assert(self.xx)
        return self.type == "c"
      end,

      is_swap = function(self)
        return self.type == "swap"
      end,

      is_i = function(self)      
        return self.type == "i"
      end,

      -- private

      _sprite = function(self)
        if self:is_idle() then
          return gate.sprites.idle[self.type]
        elseif self:is_swapping() then
          return gate.sprites.idle[self.type]
        elseif self:is_match() then
          local icon = self.tick_match % 12
          if icon == 0 or icon == 1 or icon == 2 then
            return gate.sprites.match_up[self.type]
          elseif icon == 3 or icon == 4 or icon == 5 then
            return gate.sprites.match_middle[self.type]
          elseif icon == 6 or icon == 7 or icon == 8 then
            return gate.sprites.match_down[self.type]
          elseif icon == 9 or icon == 10 or icon == 11 then
            return gate.sprites.match_middle[self.type]
          end
        elseif self:is_dropped() then
          if self.tick_drop < 5 then
            return gate.sprites.dropped[self.type]
          elseif self.tick_drop < 7 then
            return gate.sprites.jumping[self.type]
          elseif self.tick_drop < 11 then
            return gate.sprites.falling[self.type]
          end        
          return gate.sprites.dropped[self.type]
        else
          assert(false, "we should never get here")
        end
      end
    }
  end,
}

gate.x = function(cx)
  local x = gate:new("x")
  if cx ~= nil then
    x.cx = cx
  end

  return x
end

gate.y = function()
  return gate:new("y")
end

gate.z = function()
  return gate:new("z")
end

gate.s = function()
  return gate:new("s")
end

gate.c = function(xx)
  local c = gate:new("c")
  c.xx = xx
  return c
end

gate.swap = function()
  return gate:new("swap")
end

gate.i = function()
  return gate:new("i")
end

-- player's cursor class

player_cursor = {
  _sprites = {
    ["corner"] = 66,
    ["middle"] = 67
  },

  new = function(self, x, y, board)
    local c = {
      init = function(self, x, y, board)
        self.x = x
        self.y = y
        self.board = board
        self._color = colors.dark_green
        self._tick = 0
        self:_change_state("idle")
      end,

      move_left = function(self)
        if self.x == 1 then
          self:flash()
        else
          self.x -= 1
        end
      end,

      move_right = function(self)
        if self.x == board.cols - 1 then
          self:flash()
        else
          self.x += 1
        end
      end,

      move_up = function(self)
        if self.y == 1 then
          self:flash()
        else
          self.y -= 1
        end
      end,

      move_down = function(self)
        if self.y == board.rows then
          self:flash()
        else
          self.y += 1
        end
      end,

      flash = function(self)
        self:_change_state("flash")
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

      draw = function(self, raised_dots)
        -- top left
        local xtl = self.board.left + (self.x - 1) * gate.size - 5
        local ytl = self.board.top + (self.y - 1) * gate.size - 5

        -- top right
        local xtr = self.board.left + self.x * gate.size + 4
        local ytr = ytl

        -- bottom left
        local xbl = xtl
        local ybl = self.board.top + self.y * gate.size - 4

        -- bottom right
        local xbr = self.board.left + self.x * gate.size + 4
        local ybr = ybl

        -- top middle
        local xtm = self.board.left + (self.x - 1) * gate.size + 4
        local ytm = ytl

        -- bottom middle
        local xbm = self.board.left + (self.x - 1) * gate.size + 4
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

        if self:is_flash() then
          pal(self._color, colors.red)
        end

        spr(player_cursor._sprites.corner, xtl, ytl - raised_dots)
        spr(player_cursor._sprites.corner, xtr, ytr - raised_dots, 1, 1, true, false)
        spr(player_cursor._sprites.corner, xbl, ybl - raised_dots, 1, 1, false, true)
        spr(player_cursor._sprites.corner, xbr, ybr - raised_dots, 1, 1, true, true)
        spr(player_cursor._sprites.middle, xtm, ytm - raised_dots)
        spr(player_cursor._sprites.middle, xbm, ybm - raised_dots, 1, 1, false, true)

        pal(self._color, self._color)
      end,

      is_idle = function(self)
        return self._state == "idle"
      end,

      is_flash = function(self)
        return self._state == "flash"
      end,

      is_shrunk = function(self)
        return self._state == "shrunk"
      end,

      -- private

      _change_state = function(self, new_state)
        assert(new_state)
        assert(new_state == "idle" or new_state == "shrunk" or new_state == "flash")

        if new_state == "idle" then
          assert(self._state == nil or self:is_shrunk() or self:is_flash())
        end
        if new_state == "shrunk" then
          assert(self:is_idle() or self:is_flash())
        end

        self._state = new_state
      end,
    }

    c:init(x, y, board)

    return c
  end,
}

game = {
  init = function(self)
    self.board = board:new(32, 3)
    self.player_cursor = player_cursor:new(1, 1, self.board)
    self.tick = 0
    self.num_raise_gates = 0
  end,

  update = function(self, board)
    self.tick += 1

    dropping_particle:update()

    if btnp(0) then
      self.player_cursor:move_left()
    end

    if btnp(1) then
      self.player_cursor:move_right()
    end

    if btnp(2) then
      self.player_cursor:move_up()
    end

    if btnp(3) then
      self.player_cursor:move_down()
    end

    if (btnp(4)) then
      local swapped = self.board:swap(self.player_cursor.x, self.player_cursor.x + 1, self.player_cursor.y)
      if swapped == false then
        self.player_cursor:flash()
      end
    end

    self.board:reduce()
    self.board:drop_gates()
    self.board:update_gates()

    foreach(self.board:gates_dropped_bottom(), function(each)
      local x = self.board.left + (each.x - 1) * gate.size
      local y = self.board.top + (each.y - 1) * gate.size

      dropping_particle:create(x + 1, y + 7, 0, colors.white)
      dropping_particle:create(x + 3, y + 7, 0, colors.white)
      dropping_particle:create(x + 5, y + 7, 0, colors.white)
    end)

    foreach(self.board:gates_changing_to_i(), function(each)
      for x = 0, 7 do
        for y = 0, 7 do
          if x % 3 == 0 and y % 3 == 0 then
            local px = self.board.left + (each.x - 1) * gate.size + x
            local py = self.board.top + (each.y - 1) * gate.size + y

            dropping_particle:create(px, py, 1, colors.blue)
            dropping_particle:create(px, py, 0, colors.dark_purple)
          end
        end
      end
    end)

    self.player_cursor:update()
    local left_gate = self.board.gate[self.player_cursor.x][self.player_cursor.y]
    local right_gate = self.board.gate[self.player_cursor.x + 1][self.player_cursor.y]
    if not self.board:is_swappable(left_gate, right_gate) then
      self.player_cursor:flash()
    end

    if self.tick == 30 then
      if #self.board:gates_in_action() == 0 then
        self.num_raise_gates += 1
        self.board:raise_one_dot()
        if self.num_raise_gates == 8 then
          self.num_raise_gates = 0
          self.board:insert_gates_at_bottom()
          self.player_cursor:move_up()
        end
      end

      self.tick = 0
    end
  end,

  draw_stats = function(self)
    cursor(0, 0)
    color(7)
    print("cpu: " .. stat(1) * 100)
    print("fps: " .. stat(7))
  end,

  draw = function(self)
    cls()

    self.board:draw()
    self.player_cursor:draw(self.board.raised_dots)
    self:draw_stats()
    dropping_particle:draw()
  end,    
}

function _init()
  game:init()
end

function _update60()
-- function _update()
  game:update()
end

function _draw()
  game:draw()
end
__gfx__
066666000066600006666600066666000444440002222200000000000000000007ccc70000c7c00007ccc700077777000c777700077777000000000000000000
616661600661660061666160611111604466664026666620000000000c101c00c7ccc7c00cc7cc00cc7c7cc0cccc7cc0c7ccccc0ccc7ccc0000000000c101c00
6166616066616660661616606666166046444440222622200044400001c1c100c77777c0c77777c0ccc7ccc0ccc7ccc0cc777cc0ccc7ccc000ccc00001c1c100
61111160611111606661666066616660446664402226222000444000001c1000c7ccc7c0ccc7ccc0ccc7ccc0cc7cccc0ccccc7c0ccc7ccc000ccc000001c1000
6166616066616660666166606616666044444640222622200044400001c1c100c7ccc7c0ccc7ccc0ccc7ccc0c77777c0c7777cc0ccc7ccc000ccc00001c1c100
616661600661660066616660611111604666644022262220000000000c101c00ccccccc00ccccc00ccccccc0ccccccc0ccccccc0ccccccc0000000000c101c00
06666600006660000666660006666600044444000222220000000000000000000ccccc0000ccc0000ccccc000ccccc000ccccc000ccccc000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666600006660000666660006666600044444000222220000000000000000000ccccc0000ccc0000ccccc000ccccc000ccccc000ccccc000000000000000000
666666600666660066666660666666604444444022222220000000000c101c00c7ccc7c00cc7cc00c7ccc7c0c77777c0cc7777c0c77777c0000000000c101c00
6666666066666660666666606666666044444440222222200044400001c1c100c7ccc7c0ccc7ccc0cc7c7cc0cccc7cc0c7ccccc0ccc7ccc000ccc00001c1c100
61666160666166606166616061111160446666402666662000444000001c1000c77777c0c77777c0ccc7ccc0ccc7ccc0cc777cc0ccc7ccc000ccc000001c1000
6166616066616660661616606666166046444440222622200044400001c1c100c7ccc7c0ccc7ccc0ccc7ccc0cc7cccc0ccccc7c0ccc7ccc000ccc00001c1c100
611111600111110066616660661166604466664022262220000000000c101c00c7ccc7c00cc7cc00ccc7ccc0c77777c0c7777cc0ccc7ccc0000000000c101c00
01161100006160000661660001111100066666000226220000000000000000000ccccc0000ccc0000ccccc000ccccc000ccccc000ccccc000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01666100006160000166610001111100046666000666660000000000000000000ccccc0000ccc0000ccccc000ccccc000ccccc000ccccc000000000000000000
616661600661660066161660666616604644444022262220000000000c101c00ccccccc00ccccc00ccccccc0ccccccc0ccccccc0ccccccc0000000000c101c00
6111116061111160666166606661666044666440222622200044400001c1c100c7ccc7c0ccc7ccc0c7ccc7c0c77777c0cc7777c0c77777c000ccc00001c1c100
61666160666166606661666066166660444446402226222000444000001c1000c7ccc7c0ccc7ccc0cc7c7cc0cccc7cc0c7ccccc0ccc7ccc000ccc000001c1000
6166616066616660666166606111116046666440222622200044400001c1c100c77777c0c77777c0ccc7ccc0ccc7ccc0cc777cc0ccc7ccc000ccc00001c1c100
666666600666660066666660666666604444444022222220000000000c101c00c7ccc7c00cc7cc00ccc7ccc0cc7cccc0ccccc7c0ccc7ccc0000000000c101c00
066666000066600006666600066666000444440002222200000000000000000007ccc70000c7c0000cc7cc000777770007777c000cc7cc000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111100001110000661660006616600046664000226220000000000000000000000000000000000000000000000000000000000000000000000000000000000
616661600661660066616660661666604444464022262220000000000c101c000000000000000000000000000000000000000000000000000000000000000000
6166616066616660666166606111116046666440222622200044400001c1c1000000000000000000000000000000000000000000000000000000000000000000
66666660666666606666666066666660444444402222222000444000001c10000000000000000000000000000000000000000000000000000000000000000000
6666666066666660666666606666666044444440222222200044400001c1c1000000000000000000000000000000000000000000000000000000000000000000
666666600666660066666660666666604444444022222220000000000c101c000000000000000000000000000000000000000000000000000000000000000000
06666600006660000666660006666600044444000222220000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50505050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05050505000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50505050000500000033333033333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05050505000500000037773037777730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50505050000500000037333033373330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05050505000500000037300000373000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50505050000500000033300000333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05050505000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
