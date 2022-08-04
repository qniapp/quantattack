board = {
  -- todo: board.cols をなくす or default_cols にする
  cols = 6,
  rows = 12,
  next_rows = 1,
  cnot_probability = 0.3,

  new = function(self, top, left)
    local b = {
      init = function(self, top, left)
        -- todo: _gate にして直接触れないようにする。代わりに gate_at(x, y) からアクセスさせる。
        self.gate = {}
        self.top = top or 0
        self.left = left or 0
        self.cols = board.cols
        self.rows = board.rows
        self.rows_plus_next_rows = self.rows + board.next_rows
        self._raised_dots = 0

        for x = 1, self.cols do
          self.gate[x] = {}
          for y = self.rows_plus_next_rows, 1, -1 do
            self:set(x, y, quantum_gate:i())
          end
        end

        return self
      end,

      initialize_with_random_gates = function(self)
        for x = 1, board.cols do
          for y = self.rows_plus_next_rows, 1, -1 do
            if y >= board.rows - 2 or
               (y < board.rows - 2 and y >= 6 and rnd(1) > (y - 11) * -0.1 and (not self:gate_at(x, y + 1):is_i())) then
              repeat
                self:set(x, y, self:_random_gate())
              until (#gate_reduction_rules:reduce(self, x, y, true) == 0)
            else
              self:set(x, y, quantum_gate:i())
            end
          end
        end      
      end,

      gate_at = function(self, x, y)
        assert(x >= 1 and x <= self.cols)
        assert(y >= 1 and y <= self.rows_plus_next_rows)

        local gate = self.gate[x][y]
        assert(gate)

        return gate
      end,

      reducible_gate_at = function(self, x, y)
        if self:gate_at(x, y):is_idle() or self:gate_at(x, y):is_dropped() then
          return self:gate_at(x, y)
        else
          return quantum_gate:i()
        end
      end,      

      set = function(self, x, y, gate)
        assert(x >= 1 and x <= self.cols)
        assert(y >= 1 and y <= self.rows_plus_next_rows)

        self.gate[x][y] = gate
      end,
      
      screen_x = function(self, board_x)
        return self.left + (board_x - 1) * quantum_gate.size
      end,

      screen_y = function(self, board_y)
        return self.top + (board_y - 1) * quantum_gate.size - self._raised_dots
      end,

      update = function(self)
        self:reduce()
        self:drop_gates()
        self:update_gates()
      end,

      draw = function(self)
        -- wires
        for i = 1, 6 do
          line(self.left + 3 + (i - 1) * quantum_gate.size, self.top - 1,
               self.left + 3 + (i - 1) * quantum_gate.size, self.top - 1 + self.rows * quantum_gate.size,
               colors.dark_grey)
        end

        -- gates
        for bx = 1, board.cols do
          for by = self.rows_plus_next_rows, 1, -1 do
            local x = self.left + (bx - 1) * quantum_gate.size
            local y = self.top + (by - 1) * quantum_gate.size
            local gate = self:gate_at(bx, by)

            if gate:is_swapping_with_left() then
              gate:draw(x + 4, y - self._raised_dots)
            elseif gate:is_swapping_with_right() then
              gate:draw(x - 4, y - self._raised_dots)
            else
              gate:draw(x, y - self._raised_dots)
            end
          end
        end

        -- draw cnot laser
        for bx = 1, board.cols do
          for by = self.rows_plus_next_rows, 1, -1 do
            local gate = self:gate_at(bx, by)

            if gate:is_c() then
              if gate.laser and gate.tick_laser and (gate.tick_laser % 4 == 0 or gate.tick_laser % 4 == 1) then
                local lx0 = self:screen_x(bx) + 3
                local ly0 = self:screen_y(by) + 3 - self._raised_dots
                local lx1 = self:screen_x(self:gate_at(bx, by).cnot_x_x) + 3
                local ly1 = ly0
                local laser_color = flr(rnd(5)) == 0 and colors.dark_purple or colors.yellow

                line(lx0, ly0, lx1, ly1, laser_color)
              end
            end
          end
        end

        -- draw swap laser
        for bx = 1, board.cols do
          for by = board.rows, 1, -1 do
            local x = self.left + (bx - 1) * quantum_gate.size
            local y = self.top + (by - 1) * quantum_gate.size
            local gate = self:gate_at(bx, by)

            if gate:is_swap() then
              if gate.laser and gate.tick_laser and (gate.tick_laser % 4 == 0 or gate.tick_laser % 4 == 1) then
                local other_x = nil
                for ox = 1, board.cols do
                  if ox ~= bx and self:gate_at(ox, by):is_swap() then
                    other_x = ox
                    break
                  end
                end

                if (other_x) then
                  local lx0 = x + 3
                  local ly0 = y + 3 - self._raised_dots
                  local lx1 = self.left + (other_x - 1) * 8 + 3
                  local ly1 = ly0
                  local laser_color = flr(rnd(5)) == 0 and colors.dark_purple or colors.yellow

                  line(lx0, ly0, lx1, ly1, laser_color)
                end
              end
            end
          end
        end        

        -- draw cnot and swap gates over the cnot and swap laser
        for bx = 1, board.cols do
          for by = self.rows_plus_next_rows, 1, -1 do
            local x = self.left + (bx - 1) * quantum_gate.size
            local y = self.top + (by - 1) * quantum_gate.size
            local gate = self:gate_at(bx, by)

            if gate:is_c() or gate:is_cnot_x() or gate:is_swap() then
              gate:draw(x, y - self._raised_dots)
            end

            if (by == self.rows_plus_next_rows) then
              spr(64, x, y - self._raised_dots)
            end
          end
        end

        -- mask next row outside the border
        rectfill(self.left - 1, self.top + board.rows * quantum_gate.size,
                 self.left + board.cols * quantum_gate.size - 1, self.top + (board.rows + 1) * quantum_gate.size,
                 colors.black)

        -- border left
        line(self.left - 2, self.top - 1,
             self.left - 2, self.top + self.rows * quantum_gate.size,
             colors.white)
        -- border bottom
        line(self.left - 2, self.top + self.rows * quantum_gate.size,
             self.left + self.cols * quantum_gate.size, self.top + self.rows * quantum_gate.size, colors.white)
        -- border right
        line(self.left + self.cols * quantum_gate.size, self.top - 1,
             self.left + self.cols * quantum_gate.size, self.top + self.rows * quantum_gate.size, colors.white)
      end,

      swap = function(self, xl, xr, y)
        local left_gate = self:gate_at(xl, y)
        local right_gate = self:gate_at(xr, y)

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
          if left_gate.cnot_x_x == xr then
            left_gate.cnot_x_x = xl
          end
          local x_gate = self:gate_at(left_gate.cnot_x_x, y)
          assert(x_gate:is_cnot_x())
          x_gate.cnot_c_x = xr
        end
        -- _ _ x c
        -- x _ _ c
        if (right_gate:is_c()) then
          if right_gate.cnot_x_x == xl then
            right_gate.cnot_x_x = xr
          end
          local x_gate = self:gate_at(right_gate.cnot_x_x, y)
          assert(x_gate:is_cnot_x())
          x_gate.cnot_c_x = xl
        end
        -- x c
        -- x _ _ c
        if (left_gate:is_cnot_x()) then
          if left_gate.cnot_c_x == xr then
            left_gate.cnot_c_x = xl
          end
          local cnot_c = self:gate_at(left_gate.cnot_c_x, y)
          assert(cnot_c:is_c())
          cnot_c.cnot_x_x = xr
        end
        -- _ _ c x
        -- c _ _ x
        if (right_gate:is_cnot_x()) then
          if right_gate.cnot_c_x == xl then
            right_gate.cnot_c_x = xr
          end
          local cnot_c = self:gate_at(right_gate.cnot_c_x, y)
          assert(cnot_c:is_c())
          cnot_c.cnot_x_x = xl
        end

        if (left_gate:is_swap()) then
          assert(left_gate.other_x)
        end
        if (right_gate:is_swap()) then
          assert(right_gate.other_x)
        end

        -- s s
        -- s _ _ s
        if (left_gate:is_swap()) then
          if left_gate.other_x == xr then
            left_gate.other_x = xl
          end
          local swap_gate = self:gate_at(left_gate.other_x, y)
          assert(swap_gate:is_swap())
          swap_gate.other_x = xr
        end
        -- _ _ s s
        -- s _ _ s
        if (right_gate:is_swap()) then
          if right_gate.other_x == xl then
            right_gate.other_x = xr
          end
          local swap_gate = self:gate_at(right_gate.other_x, y)
          assert(swap_gate:is_swap())
          swap_gate.other_x = xl
        end
        -- s s
        -- s _ _ s
        if (left_gate:is_swap()) then
          if left_gate.other_x == xr then
            left_gate.other_x = xl
          end
          local swap_gate = self:gate_at(left_gate.other_x, y)
          assert(swap_gate:is_swap())
          swap_gate.other_x = xr
        end
        -- _ _ s s
        -- s _ _ s
        if (right_gate:is_swap()) then
          if right_gate.other_x == xl then
            right_gate.other_x = xr
          end
          local swap_gate = self:gate_at(right_gate.other_x, y)
          assert(swap_gate:is_swap())
          swap_gate.other_x = xl
        end

        sfx(2)        
      end,

      is_swappable = function(self, left_gate, right_gate)
        return (left_gate:is_idle() or left_gate:is_dropped()) and
                 (right_gate:is_idle() or right_gate:is_dropped())
      end,

      reduce = function(self)
        for x = 1, board.cols do
          for y = board.rows - 1, 1, -1 do
            if (not self:gate_at(x, y):is_i()) and self:gate_at(x, y):is_idle() then
              reduction = gate_reduction_rules:reduce(self, x, y)
              local disappearance_delay = (#reduction - 1) * 20 + 20

              for index, r in pairs(reduction) do
                sfx(4)
                local puff_delay = (index - 1) * 20
                self:gate_at(x + r.dx, y + r.dy):replace_with(r.gate, puff_delay, disappearance_delay)
                puff_delay += 20
              end
            end
          end
        end
      end,

      gates_in_action = function(self)
        local gates = {}

        for x = 1, board.cols do
          for y = 1, board.rows do
            if not self:gate_at(x, y):is_idle() then
              add(gates, self:gate_at(x, y))
            end
          end
        end

        return gates
      end,

      bottommost_gates_of_fallen_gates = function(self)
        local gates = {}

        for x = 1, board.cols do
          for y = 1, board.rows do
            local gate = self:gate_at(x, y)
            local gate_below = self:gate_at(x, y + 1)

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

      gates_to_puff = function(self)
        local gates = {}

        for x = 1, board.cols do
          for y = 1, board.rows do
            local gate = self:gate_at(x, y)

            if gate:to_puff() then
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

            while ((not self:gate_at(x, tmp_y):is_c()) and
                   (not self:gate_at(x, tmp_y):is_cnot_x()) and
                   (not self:gate_at(x, tmp_y):is_swap()) and
                    self:is_droppable(x, tmp_y)) do
              self.gate[x][tmp_y + 1] = self:gate_at(x, tmp_y)
              self.gate[x][tmp_y] = quantum_gate:i()
              tmp_y += 1
            end

            if (tmp_y > y) then
              self:gate_at(x, tmp_y):dropped()
            end
          end
        end

        -- drop cnot pairs
        for x = 1, board.cols do
          for y = board.rows - 1, 1, -1 do
            local tmp_y = y
            local gate = self:gate_at(x, tmp_y)

            while (gate:is_c() and
                   gate:is_idle() and
                   self:is_droppable(x, tmp_y) and
                   (not self:overlap_with_cnot(x, tmp_y + 1)) and
                   self:is_droppable(gate.cnot_x_x, tmp_y) and
                   (not self:overlap_with_cnot(gate.cnot_x_x, tmp_y + 1))) do
              local cnot_c = gate
              local cnot_x = self:gate_at(cnot_c.cnot_x_x, tmp_y)

              assert(cnot_x:is_cnot_x())

              self.gate[x][tmp_y + 1] = cnot_c
              self.gate[x][tmp_y] = quantum_gate:i()
              self.gate[cnot_c.cnot_x_x][tmp_y + 1] = cnot_x
              self.gate[cnot_c.cnot_x_x][tmp_y] = quantum_gate:i()

              tmp_y += 1
              gate = self:gate_at(x, tmp_y)
            end

            if (tmp_y > y) then
              self:gate_at(x, tmp_y):dropped()
            end
          end
        end

        -- drop swap pairs
        for x = 1, board.cols do
          for y = board.rows - 1, 1, -1 do
            local tmp_y = y
            local gate = self:gate_at(x, tmp_y)

            while (gate:is_swap() and
                   gate:is_idle() and
                   self:is_droppable(x, tmp_y) and
                   (not self:overlap_with_cnot(x, tmp_y + 1)) and
                   self:is_droppable(gate.other_x, tmp_y) and
                   (not self:overlap_with_cnot(gate.other_x, tmp_y + 1))) do
              local swap_a = gate
              local swap_b = self:gate_at(swap_a.other_x, tmp_y)

              assert(swap_b:is_swap())

              self.gate[x][tmp_y + 1] = swap_a
              self.gate[x][tmp_y] = quantum_gate:i()
              self.gate[swap_a.other_x][tmp_y + 1] = swap_b
              self.gate[swap_a.other_x][tmp_y] = quantum_gate:i()

              tmp_y += 1
              gate = self:gate_at(x, tmp_y)
            end

            if (tmp_y > y) then
              self:gate_at(x, tmp_y):dropped()
            end
          end
        end
      end,

      is_droppable = function(self, x, y)
        local result = false
        local gate = self:gate_at(x, y)
        local gate_below = self:gate_at(x, y + 1)

        return ((not gate:is_i()) and 
                 gate:is_idle() and
                 y + 1 <= board.rows and
                 gate_below:is_i() and
                 gate_below:is_idle())
      end,

      overlap_with_cnot = function(self, x, y)
        local control_gate = nil
        local x_gate = nil
        local control_gate_x = nil
        local x_gate_x = nil

        for bx = 1, board.cols do
          if self:gate_at(bx, y):is_c() then
            control_gate = self:gate_at(bx, y)
            control_gate_x = bx
          end
          if self:gate_at(bx, y):is_cnot_x() then
            x_gate = self:gate_at(bx, y)
            x_gate_x = bx
          end
        end

        if control_gate == nil or x_gate == nil then
          return false
        end

        if (control_gate_x < x and x < x_gate_x) or
           (x_gate_x < x and x < control_gate_x) then
          return true
        end

        return false
      end,

      is_game_over = function(self)
        for x = 1, board.cols do
          if not self:gate_at(x, 1):is_i() then
            return true
          end
        end

        return false
      end,

      insert_gates_at_bottom = function(self)
        for x = 1, board.cols do
          for y = 1, self.rows_plus_next_rows - 1 do
            if y == 1 then
              assert(self:gate_at(x, 1):is_i())
            end

            self.gate[x][y] = self:gate_at(x, y + 1)
          end
        end

        for x = 1, board.cols do
          repeat
            self:set(x, self.rows_plus_next_rows, self:_random_gate())
          until (#gate_reduction_rules:reduce(self, x, board.rows, true) == 0)
        end

        -- maybe add cnot
        if rnd(1) < board.cnot_probability then
          local cnot_c_x = flr(rnd(board.cols)) + 1
          local cnot_x_x = nil
          repeat
            cnot_x_x = flr(rnd(board.cols)) + 1
          until cnot_x_x ~= cnot_c_x

          local x_gate = quantum_gate:x(cnot_c_x)
          local control_gate = quantum_gate:c(cnot_x_x)
          self:set(cnot_x_x, self.rows_plus_next_rows, x_gate)
          self:set(cnot_c_x, self.rows_plus_next_rows, control_gate)

          local cnot_left_x = min(cnot_c_x, cnot_x_x)
          local cnot_right_x = max(cnot_c_x, cnot_x_x)
          for x = cnot_left_x + 1, cnot_right_x - 1 do
            self:set(x, self.rows_plus_next_rows, quantum_gate:i())
          end          
        end
      end,

      update_gates = function(self)
        for x = 1, board.cols do
          for y = 1, self.rows_plus_next_rows do
            self:gate_at(x, y):update()
          end
        end
      end,

      raise_one_dot = function(self)
        self._raised_dots += 1
        if self._raised_dots == 8 then
          self._raised_dots = 0
        end
      end,

      game_over = function(self)
        self._state = "game over"
      end,

      -- private

      _random_gate = function(self)
        local gate = nil

        repeat
          gate = quantum_gate:random()
        until ((not gate:is_i()) and (gate.type ~= "c") and (gate.type ~= "swap"))

        return gate
      end,
    }

    return b:init(top, left)
  end,
}
