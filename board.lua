board = {
  default_cols = 6,
  default_rows = 12,
  default_next_rows = 1,

  new = function(self, top, left)
    local b = {
      init = function(self, top, left)
        self.top = top or 0
        self.left = left or 0
        self.cols = board.default_cols
        self.rows = board.default_rows
        self.row_next_gates = self.rows + board.default_next_rows
        self.width = self.cols * quantum_gate.size
        self.height = self.rows * quantum_gate.size
        self._gate = {}
        self.raised_dots = 0

        for y = 1, self.row_next_gates do
          self._gate[y] = {}
          for x = 1, self.cols do
            self:put(x, y, i_gate:new())
          end
        end

        return self
      end,

      initialize_with_random_gates = function(self)
        for x = 1, self.cols do
          for y = self.row_next_gates, 1, -1 do
            if y >= self.rows - 2 or
               (y < self.rows - 2 and y >= 6 and rnd(1) > (y - 11) * -0.1 and (not is_i(self:gate_at(x, y + 1)))) then
              repeat
                self:put(x, y, random_gate())
              until (#gate_reduction_rules:reduce(self, x, y, true).to == 0)
            else
              self:put(x, y, i_gate:new())
            end
          end
        end      
      end,

      gate_at = function(self, x, y)
        -- the following asserts are insanely slow!
        -- !!! comment out at the time of release !!!
        
        -- assert(x >= 1)
        -- assert(x <= self.cols)
        -- assert(y >= 1)
        -- assert(y <= self.row_next_gates)

        local gate = self._gate[y][x]
        assert(gate)

        return gate
      end,

      row = function(self, y)
        return self._gate[y]
      end,

      reducible_gate_at = function(self, x, y)
        local gate = self:gate_at(x, y)

        if (is_reducible(gate)) return gate
        return i_gate:new()
      end,      

      put = function(self, x, y, gate)
        assert(x and x >= 1 and x <= self.cols)
        assert(y and y >= 1 and y <= self.row_next_gates)
        assert(gate._type)

        self._gate[y][x] = gate
      end,
      
      screen_x = function(self, board_x)
        return self.left + (board_x - 1) * quantum_gate.size
      end,

      screen_y = function(self, board_y)
        return self.top + (board_y - 1) * quantum_gate.size - self.raised_dots
      end,

      update = function(self)
        self:reduce()
        self:drop_gates()
        self:update_gates()
      end,

      draw = function(self)
        -- draw wires
        for x = 1, self.cols do
          local screen_x = self:screen_x(x) + 3
          local screen_y_top = self.top - 1
          line(screen_x, screen_y_top,
               screen_x, screen_y_top + self.height,
               colors.dark_grey)
        end

        -- draw cnot and swap connections over wires
        for x = 1, self.cols do
          for y = 1, self.row_next_gates do
            local gate = self:gate_at(x, y)
            local connection_start_x = self:screen_x(x) + 3
            local connection_y = self:screen_y(y) + 3

            -- cnot
            if is_control(gate) then
              if gate.connection and gate.tick_connection and (gate.tick_connection % 4 == 0 or gate.tick_connection % 4 == 1) then
                local connection_end_x = self:screen_x(gate.cnot_x_x) + 3
                local connection_color = flr(rnd(5)) == 0 and colors.dark_purple or colors.yellow
                line(connection_start_x, connection_y, connection_end_x, connection_y, connection_color)
              end
            end            

            -- swap
            if is_swap(gate) then
              if gate.connection and gate.tick_connection and (gate.tick_connection % 4 == 0 or gate.tick_connection % 4 == 1) then
                local connection_end_x = self:screen_x(gate.other_x) + 3
                local connection_color = flr(rnd(5)) == 0 and colors.dark_purple or colors.yellow
                line(connection_start_x, connection_y, connection_end_x, connection_y, connection_color)
              end
            end
          end
        end

        for bx = 1, self.cols do
          for by = 1, self.row_next_gates do
            local x = self:screen_x(bx)
            local y = self:screen_y(by)
            local gate = self:gate_at(bx, by)

            -- draw gates
            if is_swapping_with_left(gate) then
              gate:draw(x + 4, y)
            elseif is_swapping_with_right(gate) then
              gate:draw(x - 4, y)
            else
              gate:draw(x, y)
            end            

            if by == self.row_next_gates then
              spr(64, x, y)
            end              
          end
        end

        -- mask next row below the bottom border
        rectfill(self.left - 1, self.top + self.height,
                 self.left + self.width, self.top + (self.rows + 1) * quantum_gate.size,
                 colors.black)

        -- border left
        line(self.left - 2, self.top - 1,
             self.left - 2, self.top + self.height,
             colors.white)
        -- border bottom
        line(self.left - 2, self.top + self.height,
             self.left + self.width, self.top + self.height, colors.white)
        -- border right
        line(self.left + self.width, self.top - 1,
             self.left + self.width, self.top + self.height, colors.white)
      end,

      swap = function(self, x_left, x_right, y)
        if not self:is_swappable(x_left, x_right, y) then
          return false
        end

        local left_gate = self:gate_at(x_left, y)
        local right_gate = self:gate_at(x_right, y)

        left_gate:start_swap_with_right(x_right)
        right_gate:start_swap_with_left(x_left)

        sfx(game.sfx.swap)        
      end,

      is_swappable = function(self, x_left, x_right, y)
        if self:_overlap_with_garbage_unitary(x_left, y) or
           self:_overlap_with_garbage_unitary(x_right, y) then
          return false
        end

        local left_gate = self:gate_at(x_left, y)
        local right_gate = self:gate_at(x_right, y)

        if not (is_idle(left_gate) or is_dropped(left_gate)) then
          return false
        end
        if not (is_idle(right_gate) or is_dropped(right_gate)) then
          return false
        end
        if is_swapping(left_gate) or is_swapping(right_gate) then
          return false
        end

        -- i c
        if is_i(left_gate) and is_control(right_gate) then
          return true
        end

        -- i x
        if is_i(left_gate) and is_cnot_x(right_gate) then
          return true
        end        

        -- c ?
        if is_control(left_gate) then
          if is_i(right_gate) then -- c i
            return true
          elseif not is_cnot_x(right_gate) then -- c-?-..-x
            return false             
          end
        end

        -- ? c
        if is_control(right_gate) then
          if is_i(left_gate) then -- i c
            return true
          elseif not is_cnot_x(left_gate) then -- x-..?-c
            return false
          end
        end

        -- x ?
        if is_cnot_x(left_gate) then
          if is_i(right_gate) then -- x i          
            return true
          elseif not is_control(right_gate) then -- x-?-..-c
            return false
          end
        end

        -- ? x
        if is_cnot_x(right_gate) then
          if is_i(left_gate) then -- i x
            return true
          elseif not is_control(left_gate) then -- c-..?-x
            return false
          end
        end

        -- c-x
        if is_control(left_gate) and is_cnot_x(right_gate) then
          return left_gate.cnot_x_x == right_gate.cnot_c_x + 1
        end

        -- x-c
        if is_cnot_x(left_gate) and is_control(right_gate) then
          return left_gate.cnot_c_x == right_gate.cnot_x_x + 1
        end

        -- i s
        if is_i(left_gate) and is_swap(right_gate) then
          return true
        end

        -- s ?
        if is_swap(left_gate) then
          if is_i(right_gate) then -- s i
            return true
          elseif not is_swap(right_gate) then -- s-?-..-s
            return false             
          end
        end

        -- ? s
        if is_swap(right_gate) then
          if is_i(left_gate) then -- i s
            return true
          elseif not is_swap(left_gate) then -- s-..?-s
            return false
          end
        end

        -- s-s
        if is_swap(left_gate) and is_swap(right_gate) and
           (left_gate.other_x == right_gate.other_x + 1) then
          return true
        end

        if (is_idle(right_gate) or is_dropped(right_gate)) and 
           (is_idle(left_gate) or is_dropped(left_gate)) then
          return true
        end

        return false
      end,

      reduce = function(self)
        -- reduce non-garbage gates
        for x = 1, self.cols do
          for y = 1, self.rows - 1 do
            if is_reducible(self:gate_at(x, y)) and (not is_garbage_unitary(self:gate_at(x, y))) then
              local reduction = gate_reduction_rules:reduce(self, x, y)
              local delay_disappear = (#reduction.to - 1) * 20 + 20

              for index, r in pairs(reduction.to) do
                local delay_puff = (index - 1) * 20
                local dx = r.dx or 0
                local dy = r.dy or 0
                local gate = r.gate or i_gate:new()
                self:gate_at(x + dx, y + dy):replace_with(gate, reduction.type, delay_puff, delay_disappear)

                if dx == 0 and dy == 0 then
                  player.score += reduction.score / 100
                  score_popup:create(self:screen_x(x) - 2, self:screen_y(y), tostr(reduction.score))
                end

                delay_puff += 20
              end
            end
          end
        end

        -- reduce garbage gates
        for x = 1, self.cols do
          for y = 1, self.rows - 1 do
            local gate = self:gate_at(x, y)
            local match = false

            if is_garbage_unitary(gate) then
              if y < self.rows then
                for gx = x, x + gate._width - 1 do
                  if gx <= self.cols and is_match(self:gate_at(gx, y + 1)) and (not is_garbage_unitary_match(self:gate_at(gx, y + 1))) then
                    match = true
                  end
                end
              end

              if match then
                local delay_disappear = (gate._width - 1) * 20 + 20
                
                for dx = 0, gate._width - 1 do
                  local delay_puff = dx * 20

                  self:put(x + dx, y, garbage_unitary_match:new(gate._width))
                  self:gate_at(x + dx, y):replace_with(random_gate(), "garbage", delay_puff, delay_disappear)
                  delay_puff += 20
                end
              end              
            end
          end
        end
      end,

      gates_busy = function(self)
        local gates = {}

        for x = 1, self.cols do
          for y = 1, self.rows do
            local gate = self:gate_at(x, y)
            if (not is_i(gate)) and is_busy(gate) then
              add(gates, gate)
            end
          end
        end

        return gates
      end,

      bottommost_gates_of_dropped_gates = function(self)
        local gates = {}

        for x = 1, self.cols do
          for y = 1, self.rows do
            local gate = self:gate_at(x, y)
            local gate_below = self:gate_at(x, y + 1)

            if (not is_i(gate)) and
               is_dropped(gate) and gate.tick_drop == 0 and
               (not is_dropped(gate_below)) then
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

        for x = 1, self.cols do
          for y = 1, self.rows do
            local gate = self:gate_at(x, y)

            if gate.puff then
              gate.x = x
              gate.y = y
              add(gates, gate)
            end
          end
        end

        return gates
      end,

      drop_gates = function(self)
        for x = 1, self.cols do
          for y = self.rows - 1, 1, -1 do
            local tmp_y = y
            local gate = self:gate_at(x, tmp_y)

            while ((not is_i(gate)) and
                   (not is_control(gate)) and
                   (not is_cnot_x(gate)) and
                   (not is_swap(gate)) and
                   (not is_garbage_unitary(gate)) and
                   (tmp_y < self.rows) and
                    self:_is_droppable(x, tmp_y)) do
              self:put(x, tmp_y + 1, gate)
              self:put(x, tmp_y, i_gate:new())
              tmp_y += 1
            end

            if tmp_y > y then
              gate:dropped()
            end
          end
        end

        -- drop cnot pairs
        for x = 1, self.cols do
          for y = self.rows - 1, 1, -1 do
            local tmp_y = y
            local gate = self:gate_at(x, tmp_y)

            while self:_is_control_gate_part_of_droppable_cnot(gate, x, tmp_y) do
              local cnot_c = gate
              local cnot_x = self:gate_at(cnot_c.cnot_x_x, tmp_y)

              assert(is_cnot_x(cnot_x))

              self:put(x, tmp_y + 1, cnot_c)
              self:put(x, tmp_y, i_gate:new())
              self:put(cnot_c.cnot_x_x, tmp_y + 1, cnot_x)
              self:put(cnot_c.cnot_x_x, tmp_y, i_gate:new())

              tmp_y += 1
              gate = self:gate_at(x, tmp_y)
            end

            if (tmp_y > y) then
              self:gate_at(x, tmp_y):dropped()
            end
          end
        end

        -- drop swap pairs
        for x = 1, self.cols do
          for y = self.rows - 1, 1, -1 do
            local tmp_y = y
            local gate = self:gate_at(x, tmp_y)

            while self:_is_swap_gate_part_of_droppable_swap_pair(gate, x, tmp_y) do
              local swap_a = gate
              local swap_b = self:gate_at(swap_a.other_x, tmp_y)

              assert(is_swap(swap_b))

              self:put(x, tmp_y + 1, swap_a)
              self:put(x, tmp_y, i_gate:new())
              self:put(swap_a.other_x, tmp_y + 1, swap_b)
              self:put(swap_a.other_x, tmp_y, i_gate:new())

              tmp_y += 1
              gate = self:gate_at(x, tmp_y)
            end

            if tmp_y > y then
              self:gate_at(x, tmp_y):dropped()
            end
          end
        end

        -- drop garbage unitary
        for x = 1, self.cols do
          for y = self.rows - 1, 1, -1 do
            local tmp_y = y
            local gate = self:gate_at(x, tmp_y)

            while self:_is_droppable_garbage_unitary_start(gate, x, tmp_y) do
              self:put(x, tmp_y + 1, gate)
              self:put(x, tmp_y, i_gate:new())

              tmp_y += 1
              gate = self:gate_at(x, tmp_y)
            end

            if (tmp_y > y) then
              self:gate_at(x, tmp_y):dropped()
            end
          end
        end        
      end,

      -- checks if the gate at (x,y) can be dropped down
      --
      --  x
      -- y___  returns true
      --
      --  x
      -- _y__  returns false
      --
      --  x
      -- c--x  returns false
      --
      --  x
      -- s--s  returns false
      --
      _is_droppable = function(self, x, y)
        assert(x and x >= 1 and x <= self.cols)
        assert(y and y >= 1 and y <= self.rows - 1)

        if (y > self.rows - 1) return false

        local gate = self:gate_at(x, y)
        local gate_below = self:gate_at(x, y + 1)

        return ((is_idle(gate) or is_dropped(gate)) and
                is_i(gate_below) and
                is_idle(gate_below) and
                (not self:_overlap_with_cnot(x, y + 1)) and
                (not self:_overlap_with_swap(x, y + 1)) and
                (not self:_overlap_with_garbage_unitary(x, y + 1)))
      end,

      -- checks if
      --   - gate is a control gate and
      --   - the entire cnot including the gate can be dropped down
      --
      --  c---x
      -- x______  returns true
      --
      --  c---x
      -- __x____  returns false
      --
      --   c-x
      -- c-----x  returns false
      --
      --   c-x
      -- s-----s  returns false
      --
      _is_control_gate_part_of_droppable_cnot = function(self, gate, x, y)
        if (not is_control(gate)) return false
        if (y > self.rows - 1) return false

        local min_x = min(x, gate.cnot_x_x)
        local max_x = max(x, gate.cnot_x_x)

        for cnot_x = min_x, max_x do
          if (not self:_is_droppable(cnot_x, y)) return false
        end

        return true
      end,

      -- checks if
      --   - gate is a swap gate and
      --   - the entire swap pair including the gate can be dropped down
      --
      --  s---s
      -- x______  returns true
      --
      --  s---s
      -- __x____  returns false
      --
      --   s-s
      -- c-----x  returns false
      --
      --   s-s
      -- s-----s  returns false
      --
      _is_swap_gate_part_of_droppable_swap_pair = function(self, gate, x, y)
        if (not is_swap(gate)) return false
        if (y > self.rows - 1) return false

        assert(gate.other_x)

        local min_x = min(x, gate.other_x)
        local max_x = max(x, gate.other_x)

        for swap_x = min_x, max_x do
          if (not self:_is_droppable(swap_x, y)) return false
        end

        return true
      end,

      -- checks if
      --   - gate is a garbage unitary and
      --   - the entire garbage unitary including the gate can be dropped down
      --
      --  ggggg
      -- x______  returns true
      --
      --  ggggg
      -- __x____  returns false
      --
      --   ggg
      -- c-----x  returns false
      --
      --   ggg
      -- s-----s  returns false
      --
      _is_droppable_garbage_unitary_start = function(self, gate, x, y)
        if (y > self.rows - 1) return false

        local garbage_unitary_start = nil
        local garbage_start_x = nil

        for tmp_x = 1, self.cols do
          if is_garbage_unitary(self:gate_at(tmp_x, y)) then
            garbage_unitary_start = self:gate_at(tmp_x, y)
            garbage_start_x = tmp_x
          end
        end

        if (garbage_unitary_start == nil) return false

        for garbage_x = garbage_start_x, garbage_start_x + garbage_unitary_start._width - 1 do
          local gate_below = self:gate_at(garbage_x, y + 1)

          if not (is_i(gate_below) and
                  is_idle(gate_below) and
                  (not self:_overlap_with_cnot(garbage_x, y + 1)) and
                  (not self:_overlap_with_swap(garbage_x, y + 1)) and
                  (not self:_overlap_with_garbage_unitary(garbage_x, y + 1))) then
            return false
          end
        end

        return true
      end,

      _overlap_with_cnot = function(self, x, y)
        local row = self:row(y)
        local control_gate_x = find_index(row, function(each)
          return is_control(each) and (not is_match(each))
        end)
        if (control_gate_x == nil) return false

        local control_gate = row[control_gate_x]
        local x_gate_x = control_gate.cnot_x_x

        return (control_gate_x <= x and x <= x_gate_x) or
               (x_gate_x <= x and x <= control_gate_x)
      end,

      _overlap_with_swap = function(self, x, y)
        local row = self:row(y)
        local swap_a_x = find_index(row, function(each)
          return is_swap(each) and (not is_match(each))
        end)
        if (swap_a_x == nil) return false
        local swap_a = row[swap_a_x]
        local swap_b_x = swap_a.other_x

        return (swap_a_x <= x and x <= swap_b_x) or
               (swap_b_x <= x and x <= swap_a_x)
      end,

      _overlap_with_garbage_unitary = function(self, x, y)
        local row = self:row(y)
        local garbage_unitary_start_x = find_index(row, function(each)
          return is_garbage_unitary(each) and (not is_match(each))
        end)
        if (garbage_unitary_start_x == nil) return false
        local garbage_unitary = row[garbage_unitary_start_x]
        local garbage_unitary_end_x = garbage_unitary_start_x + garbage_unitary._width - 1

        return garbage_unitary_start_x <= x and x <= garbage_unitary_end_x
      end,

      is_game_over = function(self)
        for x = 1, self.cols do
          if (not is_i(self:gate_at(x, 1))) return true
        end

        return false
      end,

      insert_gates_at_bottom = function(self)
        for x = 1, self.cols do
          for y = 1, self.row_next_gates - 1 do
            self:put(x, y, self:gate_at(x, y + 1))
          end
        end

        for x = 1, self.cols do
          repeat
            self:put(x, self.row_next_gates, random_gate())
          until (#gate_reduction_rules:reduce(self, x, self.rows, true).to == 0)
        end

        -- maybe add cnot
        if rnd(1) < player:cnot_probability() then
          local cnot_c_x = flr(rnd(self.cols)) + 1
          local cnot_x_x = nil
          repeat
            cnot_x_x = flr(rnd(self.cols)) + 1
          until cnot_x_x != cnot_c_x

          local x_gate = cnot_x_gate:new(cnot_c_x)
          local control_gate = control_gate:new(cnot_x_x)
          self:put(cnot_x_x, self.row_next_gates, x_gate)
          self:put(cnot_c_x, self.row_next_gates, control_gate)

          local cnot_left_x = min(cnot_c_x, cnot_x_x)
          local cnot_right_x = max(cnot_c_x, cnot_x_x)
          for x = cnot_left_x + 1, cnot_right_x - 1 do
            self:put(x, self.row_next_gates, i_gate:new())
          end          
        end
      end,

      update_gates = function(self)
        local gates_to_swap = {}

        for x = 1, self.cols do
          for y = 1, self.row_next_gates do
            local gate = self:gate_at(x, y)
            gate:update()

            -- match
            if is_match(gate) and gate.tick_match == 0 then
              sfx(game.sfx.match)
            end

            -- update paired gates (cnot and swap) properly
            if is_swapping(gate) and gate.tick_swap == quantum_gate._num_frames_swap then
              add(gates_to_swap, { gate = gate, y = y })

              if is_control(gate) then
                if gate.cnot_x_x == gate.swap_new_x and gate.swap_new_x + 1 == x then
                  -- c swapped with left x
                  --    x - c (swap)
                  -- -> c - x
                  gate.cnot_x_x = gate.swap_new_x + 1
                elseif gate.cnot_x_x == gate.swap_new_x and x + 1 == gate.swap_new_x then
                  -- c swapped with right x
                  --    c - x (swap)
                  -- -> x - c
                  gate.cnot_x_x = gate.swap_new_x - 1
                elseif gate.swap_new_x < gate.cnot_x_x then
                  -- c swapped with right gate (not x)
                  --    c - - x (swap)
                  -- -> _ c - x
                  assert(is_cnot_x(self:gate_at(gate.cnot_x_x, y)))
                  self:gate_at(gate.cnot_x_x, y).cnot_c_x = gate.swap_new_x
                elseif gate.cnot_x_x < gate.swap_new_x then
                  -- c swapped with left gate (not x)
                  --    x - - c (swap)
                  -- -> x _ c _
                  assert(is_cnot_x(self:gate_at(gate.cnot_x_x, y)))
                  self:gate_at(gate.cnot_x_x, y).cnot_c_x = gate.swap_new_x
                end
              end

              if is_cnot_x(gate) then
                if gate.cnot_c_x == gate.swap_new_x and gate.swap_new_x + 1 == x then
                  -- x swapped with left c
                  --    c - x (swap)
                  -- -> x - c
                  gate.cnot_c_x = gate.swap_new_x + 1
                elseif gate.cnot_c_x == gate.swap_new_x and x + 1 == gate.swap_new_x then
                  -- x swapped with right c
                  --    x - c (swap)
                  -- -> c - x
                  gate.cnot_c_x = gate.swap_new_x - 1
                elseif gate.swap_new_x < gate.cnot_c_x then
                  -- x swapped with right gate (not c)
                  --    x - - c (swap)
                  -- -> _ x - c
                  assert(is_control(self:gate_at(gate.cnot_c_x, y)))
                  self:gate_at(gate.cnot_c_x, y).cnot_x_x = gate.swap_new_x
                elseif gate.cnot_c_x < gate.swap_new_x then
                  -- x swapped with left gate (not c)
                  --    c - - x (swap)
                  -- -> c - x _
                  assert(is_control(self:gate_at(gate.cnot_c_x, y)))
                  self:gate_at(gate.cnot_c_x, y).cnot_x_x = gate.swap_new_x
                end
              end

              if is_swap(gate) then
                if gate.other_x == gate.swap_new_x and gate.other_x + 1 == x then
                  -- s swapped with left s
                  --    s - s (swap)
                  -- -> s - s
                  gate.other_x = gate.swap_new_x + 1
                elseif gate.other_x == gate.swap_new_x and x + 1 == gate.swap_new_x then
                  -- s swapped with right s
                  --    s - s (swap)
                  -- -> s - s
                  gate.other_x = gate.swap_new_x - 1
                elseif gate.swap_new_x < gate.other_x then
                  -- s swapped with right gate (not s)
                  --    s ? - s (swap)
                  -- -> ? s - s
                  assert(is_swap(self:gate_at(gate.other_x, y)))
                  self:gate_at(gate.other_x, y).other_x = gate.swap_new_x
                elseif gate.other_x < gate.swap_new_x then
                  -- s swapped with left gate (not s)
                  --    s - ? s (swap)
                  -- -> s _ s ?
                  assert(is_swap(self:gate_at(gate.other_x, y)))
                  self:gate_at(gate.other_x, y).other_x = gate.swap_new_x
                end
              end
            end
          end
        end

        foreach(gates_to_swap, function(each)
          self:put(each.gate.swap_new_x, each.y, each.gate)
        end)        
      end,

      add_garbage_unitary = function(self)
        local width = flr(rnd(self.cols - 2)) + 3 -- 3, 4, 5, 6
        local x = flr(rnd(self.cols - width + 1)) + 1

        for dx = 0, width - 1 do
          if (self:_overlap_with_garbage_unitary(x + dx, 1)) return
        end

        self:put(x, 1, garbage_unitary:new(width))
      end,

      game_over = function(self)
        self._state = "game over"
      end,
    }

    return b:init(top, left)
  end,
}
