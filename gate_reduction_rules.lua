gate_reduction_rules = {
  reduce = function(self, board, x, y, include_next)
    include_next = include_next or false

    if include_next then
      if y + 1 > board.rows_plus_next_rows then
        return {["to"] = {}}
      end
    else
      if y + 1 > board.rows then
        return {["to"] = {}}
      end    
    end

    local gate = board:reducible_gate_at(x, y)
    local gate_y1 = board:reducible_gate_at(x, y + 1)
    if (gate_y1:is_i()) return {["to"] = {}}

    if (gate:is_h() and
        gate_y1:is_h()) then
      -- h  -->  i
      -- h       i        
      return {
        ["type"] = "hh",
        ["score"] = 100,
        ["to"] = {{ ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
                  { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() }},
      }
    elseif gate:is_x() then
      if gate_y1:is_x() then
        -- x  -->  i
        -- x       i        
        return {
          ["type"] = "xx",
          ["score"] = 100,
          ["to"] = {{ ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
                    { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() }},
        }
      end
      if gate_y1:is_z() then
        -- x  -->  
        -- z       y        
        return {
          ["type"] = "xz",
          ["score"] = 200,
          ["to"] = {{ ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
                    { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:y() }},
        }
      end
    elseif (gate:is_y() and
            gate_y1:is_y()) then
      -- y  -->  i
      -- y       i           
      return {
        ["type"] = "yy",
        ["score"] = 100,
        ["to"] = {{ ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
                  { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() }},
      }
    elseif gate:is_z() then
      if gate_y1:is_z() then
        -- z  -->  i
        -- z       i        
        return {
          ["type"] = "zz",
          ["score"] = 100,
          ["to"] = {{ ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
                    { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() }},
        }
      elseif gate_y1:is_x() then
        -- z  -->  
        -- x       y        
        return {
          ["type"] = "zx",
          ["score"] = 200,
          ["to"] = {{ ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
                    { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:y() }},
        }
      end
    elseif (gate:is_s() and
            gate_y1:is_s()) then
      -- s  --> 
      -- s       z        
      return {
        ["type"] = "ss",
        ["score"] = 200,
        ["to"] = {{ ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
                  { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:z() }},
      }
    elseif (gate:is_t() and
            gate_y1:is_t()) then
      -- t  -->  
      -- t       s        
      return {
        ["type"] = "tt",
        ["score"] = 200,
        ["to"] = {{ ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
                  { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:s() }},
      }
    elseif (gate:is_swap() and board:reducible_gate_at(gate.other_x, y):is_swap() and
            gate_y1:is_swap() and board:reducible_gate_at(gate.other_x, y + 1):is_swap()) then 
      -- s-s  -->  i i
      -- s-s       i i        
      local dx = gate.other_x - x
      return {
        ["type"] = "swap swap",
        ["score"] = 600,
        ["to"] = {{ ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() }, { ["dx"] = dx, ["dy"] = 0, ["gate"] = quantum_gate:i() },
                  { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() }, { ["dx"] = dx, ["dy"] = 1, ["gate"] = quantum_gate:i() }},
      }  
    end

    if include_next then
      if y + 2 > board.rows_plus_next_rows then
        return {["to"] = {}}
      end       
    else
      if y + 2 > board.rows then
        return {["to"] = {}}
      end    
    end

    local gate_y2 = board:reducible_gate_at(x, y + 2)
    if (gate_y2:is_i()) return {["to"] = {}}

    if (gate:is_h() and
        gate_y1:is_x() and
        gate_y2:is_h()) then
      return {
        ["type"] = "hxh",
        ["score"] = 400,
        ["to"] = {{ ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
                  { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() },
                  { ["dx"] = 0, ["dy"] = 2, ["gate"] = quantum_gate:z() }},
      }      
    end 

    if (gate:is_h() and
        gate_y1:is_z() and
        gate_y2:is_h()) then
      return {
        ["type"] = "hzh",
        ["score"] = 400,
        ["to"] = {{ ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
                  { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() },
                  { ["dx"] = 0, ["dy"] = 2, ["gate"] = quantum_gate:x() }},
      }
    end 

    if (gate:is_s() and
        gate_y1:is_z() and
        gate_y2:is_s()) then
      return {
        ["type"] = "szs",
        ["score"] = 400,
        ["to"] = {{ ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
                  { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() },
                  { ["dx"] = 0, ["dy"] = 2, ["gate"] = quantum_gate:z() }},
      }      
    end

    -- c-x   x-c
    -- x-c   c-x  --> 
    -- c-x,  x-c       s-s
    if (gate:is_control() and board:reducible_gate_at(gate.cnot_x_x, y):is_cnot_x() and
        gate_y1:is_cnot_x() and board:reducible_gate_at(gate.cnot_x_x, y + 1):is_control() and
        gate_y2:is_control() and board:reducible_gate_at(gate.cnot_x_x, y + 2):is_cnot_x()) then
      local dx = gate.cnot_x_x - x
      return {
        ["type"] = "cnot x3",
        ["score"] = 800,
        ["to"] = {{ ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() }, { ["dx"] = dx, ["dy"] = 0, ["gate"] = quantum_gate:i() },
                  { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() }, { ["dx"] = dx, ["dy"] = 1, ["gate"] = quantum_gate:i() },
                  { ["dx"] = 0, ["dy"] = 2, ["gate"] = quantum_gate:swap(x + dx) }, { ["dx"] = dx, ["dy"] = 2, ["gate"] = quantum_gate:swap(x) }},
      }  
    end

    -- h h
    -- c-x  -->
    -- h h       x-c
    if (gate:is_h() and gate_y1:is_control() and board:reducible_gate_at(gate_y1.cnot_x_x, y):is_h() and
        board:reducible_gate_at(gate_y1.cnot_x_x, y + 1):is_cnot_x() and
        gate_y2:is_h() and board:reducible_gate_at(gate_y1.cnot_x_x, y + 2):is_h()) then
      local dx = gate_y1.cnot_x_x - x
      return {
        ["type"] = "hh cnot hh",
        ["score"] = 800,
        ["to"] = {{ ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() }, { ["dx"] = dx, ["dy"] = 0, ["gate"] = quantum_gate:i() },
                  { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() }, { ["dx"] = dx, ["dy"] = 1, ["gate"] = quantum_gate:i() },
                  { ["dx"] = 0, ["dy"] = 2, ["gate"] = quantum_gate:x(x + dx) }, { ["dx"] = dx, ["dy"] = 2, ["gate"] = quantum_gate:control(x) }},
      }  
    end

    return {["to"] = {}}
  end,
}