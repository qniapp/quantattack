
gate_reduction_rules = {
  reduce = function(self, board, x, y, include_next)
    include_next = include_next or false

    if include_next then
      if y + 1 > board.rows_plus_next_rows then
        return {}
      end
    else
      if y + 1 > board.rows then
        return {}
      end    
    end

    local gate = board:reducible_gate_at(x, y)
    local gate_y1 = board:reducible_gate_at(x, y + 1)

    if (gate:is_h() and
        gate_y1:is_h()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() },
      }
    end

    if (gate:is_x() and
        gate_y1:is_x()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() },
      }
    end

    if (gate:is_y() and
        gate_y1:is_y()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() },
      }
    end

    if (gate:is_z() and
        gate_y1:is_z()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() },
      }
    end

    if (gate:is_z() and
        gate_y1:is_x()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:y() },
      }
    end

    if (gate:is_x() and
        gate_y1:is_z()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:y() },
      }
    end

    if (gate:is_s() and
        gate_y1:is_s()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:z() },
      }
    end

    if (gate:is_t() and
        gate_y1:is_t()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:s() },
      }
    end

    if (gate:is_swap() and
        gate_y1:is_swap() and
        board:reducible_gate_at(gate.other_x, y + 1):is_swap()) then 
      local dx = gate.other_x - x
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() }, { ["dx"] = dx, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() }, { ["dx"] = dx, ["dy"] = 1, ["gate"] = quantum_gate:i() },
      }  
    end

    if include_next then
      if y + 2 > board.rows_plus_next_rows then
        return {}
      end       
    else
      if y + 2 > board.rows then
        return {}
      end    
    end

    local gate_y2 = board:reducible_gate_at(x, y + 2)

    if (gate:is_h() and
        gate_y1:is_x() and
        gate_y2:is_h()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 2, ["gate"] = quantum_gate:z() },
      }      
    end 

    if (gate:is_h() and
        gate_y1:is_z() and
        gate_y2:is_h()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 2, ["gate"] = quantum_gate:x() },
      }
    end 

    if (gate:is_s() and
        gate_y1:is_z() and
        gate_y2:is_s()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 2, ["gate"] = quantum_gate:z() },
      }      
    end

    -- c -- x   x -- c
    -- x -- c   c -- x  --> 
    -- c -- x,  x -- c       swap -- swap
    if (gate:is_control() and
       (gate_y1:is_cnot_x()) and
        gate_y2:is_control() and
        board:reducible_gate_at(gate.cnot_x_x, y + 1):is_control() and
        board:reducible_gate_at(gate.cnot_x_x, y + 2):is_cnot_x()) then
      local dx = gate.cnot_x_x - x
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() }, { ["dx"] = dx, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() }, { ["dx"] = dx, ["dy"] = 1, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 2, ["gate"] = quantum_gate:swap(x + dx) }, { ["dx"] = dx, ["dy"] = 2, ["gate"] = quantum_gate:swap(x) },
      }  
    end

    -- todo
    -- h    h
    -- c -- x  -->
    -- h    h       x -- c

    return {}
  end,
}