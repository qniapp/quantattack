gate_reduction_rules = {
  reduce = function(self, board, x, y, include_next)
    include_next = include_next or false

    if include_next then
      if y + 1 > board.rows_plus_next_rows then
        return {to = {}}
      end
    else
      if y + 1 > board.rows then
        return {to = {}}
      end    
    end

    local gate = board:reducible_gate_at(x, y)
    local gate_y1 = board:reducible_gate_at(x, y + 1)
    if (is_i(gate_y1)) return {to = {}}

    if (is_h(gate) and
        is_h(gate_y1)) then
      -- h  -->  i
      -- h       i        
      return {
        type = "hh",
        score = 100,
        to = {{ dx = 0, dy = 0, gate = i_gate:new() },
              { dx = 0, dy = 1, gate = i_gate:new() }},
      }
    end

    if is_x(gate) then
      if is_x(gate_y1) then
        -- x  -->  i
        -- x       i        
        return {
          type = "xx",
          score = 100,
          to = {{ dx = 0, dy = 0, gate = i_gate:new() },
                { dx = 0, dy = 1, gate = i_gate:new() }},
        }
      end
      if is_z(gate_y1) then
        -- x  -->  
        -- z       y        
        return {
          type = "xz",
          score = 200,
          to = {{ dx = 0, dy = 0, gate = i_gate:new() },
                { dx = 0, dy = 1, gate = y_gate:new() }},
        }
      end
    end

    if (is_y(gate) and
        is_y(gate_y1)) then
      -- y  -->  i
      -- y       i           
      return {
        type = "yy",
        score = 100,
        to = {{ dx = 0, dy = 0, gate = i_gate:new() },
              { dx = 0, dy = 1, gate = i_gate:new() }},
      }
    end

    if is_z(gate) then
      if is_z(gate_y1) then
        -- z  -->  i
        -- z       i        
        return {
          type = "zz",
          score = 100,
          to = {{ dx = 0, dy = 0, gate = i_gate:new() },
                { dx = 0, dy = 1, gate = i_gate:new() }},
        }
      elseif is_x(gate_y1) then
        -- z  -->  
        -- x       y        
        return {
          type = "zx",
          score = 200,
          to = {{ dx = 0, dy = 0, gate = i_gate:new() },
                { dx = 0, dy = 1, gate = y_gate:new() }},
        }
      end
    end

    if (is_s(gate) and
        is_s(gate_y1)) then
      -- s  --> 
      -- s       z        
      return {
        type = "ss",
        score = 200,
        to = {{ dx = 0, dy = 0, gate = i_gate:new() },
              { dx = 0, dy = 1, gate = z_gate:new() }},
      }
    end

    if (is_t(gate) and
        is_t(gate_y1)) then
      -- t  -->  
      -- t       s        
      return {
        type = "tt",
        score = 200,
        to = {{ dx = 0, dy = 0, gate = i_gate:new() },
              { dx = 0, dy = 1, gate = s_gate:new() }},
      }
    end

    if (is_swap(gate) and is_swap(board:reducible_gate_at(gate.other_x, y)) and
        is_swap(gate_y1) and is_swap(board:reducible_gate_at(gate.other_x, y + 1))) then 
      -- s-s  -->  i i
      -- s-s       i i        
      local dx = gate.other_x - x
      return {
        type = "swap swap",
        score = 600,
        to = {{ dx = 0, dy = 0, gate = i_gate:new() }, { dx = dx, dy = 0, gate = i_gate:new() },
              { dx = 0, dy = 1, gate = i_gate:new() }, { dx = dx, dy = 1, gate = i_gate:new() }},
      }  
    end

    -- c-x   x-c      i i
    -- c-x   x-c  --> i i
    if (is_control(gate) and is_cnot_x(board:reducible_gate_at(gate.cnot_x_x, y)) and
        is_control(gate_y1) and (gate_y1.cnot_x_x == gate.cnot_x_x) and is_cnot_x(board:reducible_gate_at(gate.cnot_x_x, y + 1))) then
      local dx = gate.cnot_x_x - x
      return {
        type = "cnot x2",
        score = 200,
        to = {{ dx = 0, dy = 0, gate = i_gate:new() }, { dx = dx, dy = 0, gate = i_gate:new() },
              { dx = 0, dy = 1, gate = i_gate:new() }, { dx = dx, dy = 1, gate = i_gate:new() }},
      }  
    end

    if include_next then
      if y + 2 > board.rows_plus_next_rows then
        return {to = {}}
      end       
    else
      if y + 2 > board.rows then
        return {to = {}}
      end    
    end

    local gate_y2 = board:reducible_gate_at(x, y + 2)
    if (is_i(gate_y2)) return {to = {}}

    if (is_h(gate) and
        is_x(gate_y1) and
        is_h(gate_y2)) then
      return {
        type = "hxh",
        score = 400,
        to = {{ dx = 0, dy = 0, gate = i_gate:new() },
              { dx = 0, dy = 1, gate = i_gate:new() },
              { dx = 0, dy = 2, gate = z_gate:new() }},
      }      
    end 

    if (is_h(gate) and
        is_z(gate_y1) and
        is_h(gate_y2)) then
      return {
        type = "hzh",
        score = 400,
        to = {{ dx = 0, dy = 0, gate = i_gate:new() },
              { dx = 0, dy = 1, gate = i_gate:new() },
              { dx = 0, dy = 2, gate = x_gate:new() }},
      }
    end 

    if (is_s(gate) and
        is_z(gate_y1) and
        is_s(gate_y2)) then
      return {
        type = "szs",
        score = 400,
        to = {{ dx = 0, dy = 0, gate = i_gate:new() },
              { dx = 0, dy = 1, gate = i_gate:new() },
              { dx = 0, dy = 2, gate = z_gate:new() }},
      }      
    end

    -- c-x   x-c
    -- x-c   c-x  --> 
    -- c-x,  x-c       s-s
    if (is_control(gate) and is_cnot_x(board:reducible_gate_at(gate.cnot_x_x, y)) and
        is_cnot_x(gate_y1) and is_control(board:reducible_gate_at(gate.cnot_x_x, y + 1)) and
        is_control(gate_y2) and is_cnot_x(board:reducible_gate_at(gate.cnot_x_x, y + 2))) then
      local dx = gate.cnot_x_x - x
      return {
        type = "cnot x3",
        score = 800,
        to = {{ dx = 0, dy = 0, gate = i_gate:new() }, { dx = dx, dy = 0, gate = i_gate:new() },
              { dx = 0, dy = 1, gate = i_gate:new() }, { dx = dx, dy = 1, gate = i_gate:new() },
              { dx = 0, dy = 2, gate = swap_gate:new(x + dx) }, { dx = dx, dy = 2, gate = swap_gate:new(x) }},
      }  
    end

    -- h h
    -- c-x  -->
    -- h h       x-c
    if (is_h(gate) and is_control(gate_y1) and is_h(board:reducible_gate_at(gate_y1.cnot_x_x, y)) and
        is_cnot_x(board:reducible_gate_at(gate_y1.cnot_x_x, y + 1)) and
        is_h(gate_y2) and is_h(board:reducible_gate_at(gate_y1.cnot_x_x, y + 2))) then
      local dx = gate_y1.cnot_x_x - x
      return {
        type = "hh cnot hh",
        score = 800,
        to = {{ dx = 0, dy = 0, gate = i_gate:new() }, { dx = dx, dy = 0, gate = i_gate:new() },
              { dx = 0, dy = 1, gate = i_gate:new() }, { dx = dx, dy = 1, gate = i_gate:new() },
              { dx = 0, dy = 2, gate = cnot_x_gate:new(x + dx) }, { dx = dx, dy = 2, gate = control_gate:new(x) }},
      }  
    end

    return {to = {}}
  end,
}