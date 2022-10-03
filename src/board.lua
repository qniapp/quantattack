require("engine/core/class")

require("quantum_gate_types")

local quantum_gate = require("quantum_gate")
local gate_reduction_rules = require("gate_reduction_rules")
local garbage_gate = require("garbage_gate")

-- gate states

function is_droppable(gate)
  return not (gate:is_i() or gate:is_dropping() or gate:is_swapping())
end

function is_reducible(gate)
  return not (gate:is_i() or is_busy(gate))
end

function is_busy(gate)
  return not (gate:is_idle() or gate:is_swap_finished())
end

board = {
  default_cols = 6,
  default_rows = 12,

  new = function(_self)
    local board = {
      cols = board.default_cols,
      rows = board.default_rows,
      row_next_gates = 13,
      _gates = {},
      _falling_garbages = {},
      _offset_x = 10,
      _offset_y = 10,

      initialize_with_random_gates = function(self)
        for x = 1, self.cols do
          for y = self.row_next_gates, 1, -1 do
            if y >= self.rows - 2 or
                (y < self.rows - 2 and y >= 6 and rnd(1) > (y - 11) * -0.1 and (not self:gate_at(x, y + 1):is_i())) then
              repeat
                self:put(x, y, quantum_gate:random_single_gate())
              until #gate_reduction_rules:reduce(self, x, y, true).to == 0
            else
              self:put(x, y, quantum_gate("i"))
            end
          end
        end
      end,

      update = function(self)
        self:reduce()
        self:_drop_gates()
        self:_update_falling_garbages()
        self:_update_gates()
      end,

      reduce = function(self)
        for x = 1, self.cols do
          for y = 1, self.rows - 1 do
            if (not is_reducible(self:gate_at(x, y))) then
              goto next
            end

            local reduction = gate_reduction_rules:reduce(self, x, y)

            for _index, r in pairs(reduction.to) do
              local dx = r.dx or 0
              local dy = r.dy or 0
              local gate = r.gate or quantum_gate("i")

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
            if (gate.type == "?") then
              goto next
            end
            if (gate.type == "g") then
              goto next
            end
            if (not is_droppable(gate)) then
              goto next
            end

            if self:gate_at(x, y + 1):is_i() then
              local stop_y = y
              while self:gate_at(x, stop_y + 1):is_i() or self:gate_at(x, stop_y + 1):is_dropping() do
                stop_y = stop_y + 1
              end
              gate:drop(self:screen_y(y), self:screen_y(stop_y))
              self:put(x, stop_y, quantum_gate("?"))
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
            if (gate.type == "?") then
              goto next
            end

            gate:update()

            if gate:is_swap_finished() then
              add(gates_to_swap, { gate = gate, y = y })
            end
            if gate:is_dropped() then
              self:put(x, self:y(gate.stop_screen_y), gate)
              self:put(x, self:y(gate.start_screen_y), quantum_gate("i"))
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
            if (not gate) then
              goto next
            end

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
        if (#self._falling_garbages ~= 0) then
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

        if (is_reducible(gate)) then
          return gate
        end
        return quantum_gate("i")
      end,

      put = function(self, x, y, gate)
        self._gates[x][y] = gate
      end,

      put_garbage = function(self)
        local width = flr(rnd(4)) + 3

        add(self._falling_garbages, garbage_gate(width, self))
      end,

      gate_top_y = function(self, x_start, x_end)
        for y = 1, self.rows do
          for x = x_start, x_end do
            if not self:gate_at(x, y):is_i() then
              return y
            end
          end

          for x = 1, self.cols do
            local gate = self:gate_at(x, y)
            if (gate.type ~= "g") then
              goto next
            end

            for gx = x, x + gate.width - 1, 1 do
              if (x_start <= gx and gx <= x_end) then
                return y
              end
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
      for y = 1, board.row_next_gates do
        board._gates[x][y] = quantum_gate("i")
      end
    end

    -- board:initialize_with_random_gates()

    return board
  end
}

return board
