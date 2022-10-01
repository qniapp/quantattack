local y_gate = require("engine/y_gate")
local z_gate = require("engine/z_gate")
local s_gate = require("engine/s_gate")

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

function is_cnot_x(gate)
  return gate.type == "cnot_x"
end

gate_reduction_rules = {
  reduce = function(self, board, x, y, include_next)
    include_next = include_next or false
    local y1 = y + 1
    local y2 = y + 2
    local y3 = y + 3

    if include_next then
      if y1 > board.rows_plus_next_rows then
        return { to = {} }
      end
    else
      if y1 > board.rows then
        return { to = {} }
      end
    end

    local gate = board:reducible_gate_at(x, y)
    local gate_y1 = board:reducible_gate_at(x, y1)
    if (is_i(gate_y1)) then
      return { to = {} }
    end

    if (is_h(gate) and
        is_h(gate_y1)) then
      -- h  -->  i
      -- h       i
      return {
        type = "hh",
        score = 100,
        to = { {},
          { dy = 1 } },
      }
    end

    if is_x(gate) then
      if is_x(gate_y1) then
        -- x  -->  i
        -- x       i
        return {
          type = "xx",
          score = 100,
          to = { {},
            { dy = 1 } },
        }
      end
      if is_z(gate_y1) then
        -- x  -->
        -- z       y
        return {
          type = "xz",
          score = 200,
          to = { {},
            { dy = 1, gate = y_gate:new() } },
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
        to = { {},
          { dy = 1 } },
      }
    end

    if is_z(gate) then
      if is_z(gate_y1) then
        -- z  -->  i
        -- z       i
        return {
          type = "zz",
          score = 100,
          to = { {},
            { dy = 1 } },
        }
      elseif is_x(gate_y1) then
        -- z  -->
        -- x       y
        return {
          type = "zx",
          score = 200,
          to = { {},
            { dy = 1, gate = y_gate:new() } },
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
        to = { {},
          { dy = 1, gate = z_gate:new() } },
      }
    end

    if (is_t(gate) and
        is_t(gate_y1)) then
      -- t  -->
      -- t       s
      return {
        type = "tt",
        score = 200,
        to = { {},
          { dy = 1, gate = s_gate:new() } },
      }
    end

    if (is_swap(gate) and is_swap(board:reducible_gate_at(gate.other_x, y)) and
        is_swap(gate_y1) and is_swap(board:reducible_gate_at(gate.other_x, y1))) then
      -- s-s  -->  i i
      -- s-s       i i
      local dx = gate.other_x - x
      return {
        type = "swap swap",
        score = 600,
        to = { {}, { dx = dx },
          { dy = 1 }, { dx = dx, dy = 1 } },
      }
    end

    -- c-x   x-c      i i
    -- c-x   x-c  --> i i
    if (is_control(gate) and is_cnot_x(board:reducible_gate_at(gate.cnot_x_x, y)) and
        is_control(gate_y1) and (gate_y1.cnot_x_x == gate.cnot_x_x) and
        is_cnot_x(board:reducible_gate_at(gate.cnot_x_x, y1))) then
      local dx = gate.cnot_x_x - x
      return {
        type = "cnot x2",
        score = 200,
        to = { {}, { dx = dx },
          { dy = 1 }, { dx = dx, dy = 1 } },
      }
    end

    if include_next then
      if y2 > board.rows_plus_next_rows then
        return { to = {} }
      end
    else
      if y2 > board.rows then
        return { to = {} }
      end
    end

    local gate_y2 = board:reducible_gate_at(x, y2)

    if (is_h(gate) and
        is_x(gate_y1) and
        is_h(gate_y2)) then
      return {
        type = "hxh",
        score = 400,
        to = { {},
          { dy = 1 },
          { dy = 2, gate = z_gate:new() } },
      }
    end

    if (is_h(gate) and
        is_z(gate_y1) and
        is_h(gate_y2)) then
      return {
        type = "hzh",
        score = 400,
        to = { {},
          { dy = 1 },
          { dy = 2, gate = x_gate:new() } },
      }
    end

    if (is_s(gate) and
        is_z(gate_y1) and
        is_s(gate_y2)) then
      return {
        type = "szs",
        score = 400,
        to = { {},
          { dy = 1 },
          { dy = 2, gate = z_gate:new() } },
      }
    end

    -- c-x   x-c
    -- x-c   c-x  -->
    -- c-x,  x-c       s-s
    if (is_control(gate) and is_cnot_x(board:reducible_gate_at(gate.cnot_x_x, y)) and
        is_cnot_x(gate_y1) and is_control(board:reducible_gate_at(gate.cnot_x_x, y1)) and
        is_control(gate_y2) and is_cnot_x(board:reducible_gate_at(gate.cnot_x_x, y2))) then
      local dx = gate.cnot_x_x - x
      return {
        type = "cnot x3",
        score = 800,
        to = { {}, { dx = dx },
          { dy = 1 }, { dx = dx, dy = 1 },
          { dy = 2, gate = swap_gate:new(x + dx) }, { dx = dx, dy = 2, gate = swap_gate:new(x) } },
      }
    end

    -- h h
    -- c-x  -->  x-c
    -- h h
    if (is_h(gate) and is_control(gate_y1) and is_h(board:reducible_gate_at(gate_y1.cnot_x_x, y)) and
        is_cnot_x(board:reducible_gate_at(gate_y1.cnot_x_x, y1)) and
        is_h(gate_y2) and is_h(board:reducible_gate_at(gate_y1.cnot_x_x, y2))) then
      local dx = gate_y1.cnot_x_x - x
      return {
        type = "hh cnot hh",
        score = 800,
        to = { {}, { dx = dx },
          { dy = 1, gate = cnot_x_gate:new(x + dx) }, { dx = dx, dy = 1, gate = control_gate:new(x) },
          { dy = 2 }, { dx = dx, dy = 2 } },
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
        to = { {}, { dx = dx }, { dy = 2 } },
      }
    end

    -- z z
    -- c-x  -->  c-x
    --   z
    if (is_z(gate) and is_control(gate_y1) and is_z(board:reducible_gate_at(gate_y1.cnot_x_x, y)) and
        is_cnot_x(board:reducible_gate_at(gate_y1.cnot_x_x, y1)) and
        is_z(board:reducible_gate_at(gate_y1.cnot_x_x, y2))) then
      local dx = gate_y1.cnot_x_x - x
      return {
        type = "zz cnot z",
        score = 800,
        to = { {}, { dx = dx }, { dx = dx, dy = 2 } },
      }
    end

    -- x
    -- x-c  -->  x-c
    -- x
    if (is_x(gate) and
        is_cnot_x(gate_y1) and is_control(board:reducible_gate_at(gate_y1.cnot_c_x, y1)) and
        is_x(gate_y2)) then
      local dx = gate_y1.cnot_c_x - x
      return {
        type = "x cnot x",
        score = 800,
        to = { {}, { dy = 2 } },
      }
    end

    -- z
    -- c-x  -->  c-x
    -- z
    if (is_z(gate) and
        is_control(gate_y1) and is_cnot_x(board:reducible_gate_at(gate_y1.cnot_x_x, y1)) and
        is_z(gate_y2)) then
      local dx = gate_y1.cnot_x_x - x
      return {
        type = "z cnot z",
        score = 800,
        to = { {}, { dy = 2 } },
      }
    end

    -- z
    -- h x       h
    -- x-c  -->  x-c
    -- h x       h
    local x2 = gate_y2.cnot_c_x
    if (y <= 9 and is_z(gate) and
        is_h(gate_y1) and is_cnot_x(gate_y2) and is_x(board:reducible_gate_at(x2, y1)) and
        is_control(board:reducible_gate_at(x2, y2)) and
        is_h(board:reducible_gate_at(x, y3)) and is_x(board:reducible_gate_at(x2, y3))) then
      local dx = gate_y2.cnot_c_x - x
      return {
        type = "xz cz x",
        score = 800,
        to = { {},
          { dx = dx, dy = 1 },
          { dx = dx, dy = 3 } }
      }
    end

    return { to = {} }
  end,
}

return gate_reduction_rules
