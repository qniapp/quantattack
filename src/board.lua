require("engine/application/constants")
require("engine/core/class")

local garbage_gate = require("garbage_gate")
local garbage_match_gate = require("garbage_match_gate")
local i_gate = require("i_gate")
local h_gate = require("h_gate")
local x_gate = require("x_gate")
local y_gate = require("y_gate")
local z_gate = require("z_gate")
local s_gate = require("s_gate")
local t_gate = require("t_gate")
local control_gate = require("control_gate")
local cnot_x_gate = require("cnot_x_gate")
local swap_gate = require("swap_gate")
local board = new_class()

board.cols = 6 -- board の列数
board.rows = 12 -- board の行数
board.row_next_gates = board.rows + 1

function board:_init()
  self._gates = {}
  self.width = board.cols * tile_size
  self.height = board.rows * tile_size
  self.offset_x = 10
  self.offset_y = screen_height - self.height
  self:init()
end

function board:init()
  self.raised_dots = 0

  -- fill the board with I gates
  for x = 1, board.cols do
    self._gates[x] = {}
    for y = 1, board.row_next_gates do
      self:put(x, y, i_gate())
    end
  end
end

function board:initialize_with_random_gates()
  self:init()

  for y = board.row_next_gates, 6, -1 do
    for x = 1, board.cols do
      if y >= board.rows - 2 or
          (y < board.rows - 2 and rnd(1) > (y - 11) * -0.1 and (not self:is_empty(x, y + 1))) then
        repeat
          self:put(x, y, self:_random_single_gate())
        until #self:reduce(x, y, true).to == 0
      end
    end
  end
end

function board:_random_single_gate()
  local single_gate_types = { h_gate, x_gate, y_gate, z_gate, s_gate, t_gate }
  local gate_type = single_gate_types[flr(rnd(#single_gate_types)) + 1]

  return gate_type()
end

function board:is_busy()
  for x = 1, self.cols do
    for y = 1, self.row_next_gates do
      if not self:gate_at(x, y):is_idle() then
        return true
      end
    end
  end

  return false
end

function board:insert_gates_at_bottom(steps)
  -- 各ゲートを 1 つ上にずらす
  for y = 1, self.row_next_gates - 1 do
    for x = 1, self.cols do
      self:put(x, y, self:gate_at(x, y + 1))
      self:remove_gate(x, y + 1)
    end
  end

  local min_cnot_probability = 0.3
  local max_cnot_probability = 0.7
  local p = min_cnot_probability + flr(steps / 5) * 0.1
  p = p > max_cnot_probability and max_cnot_probability or p

  if rnd(1) < p then
    local control_x
    local cnot_x_x
    repeat
      control_x = flr(rnd(board.cols)) + 1
      cnot_x_x = flr(rnd(board.cols)) + 1
    until control_x ~= cnot_x_x

    self:put(control_x, self.row_next_gates, control_gate(cnot_x_x))
    self:put(cnot_x_x, self.row_next_gates, cnot_x_gate(control_x))
  end

  -- 最下段の空いている部分に新しいゲートを置く
  for x = 1, self.cols do
    if self:is_empty(x, self.row_next_gates) then
      repeat
        self:put(x, self.row_next_gates, self:_random_single_gate())
      until #self:reduce(x, self.rows, true).to == 0
    end
  end
end

function board:update()
  local score = 0

  score = score + self:reduce_gates()
  self:drop_gates()
  self:_update_gates()

  return score
end

function board:reduce_gates()
  local score = 0

  for y = 1, board.rows do
    for x = 1, board.cols do
      if self:gate_at(x, y):is_reducible() then
        local reduction = self:reduce(x, y)
        score = score + (#reduction.to == 0 and 0 or (reduction.score or 1)) -- デフォルト 100 点

        for index, r in pairs(reduction.to) do
          local dx = r.dx and reduction.dx or 0
          local dy = r.dy or 0
          local gate = r.gate or i_gate()

          if gate:is_swap() or gate:is_cnot_x() or gate:is_control() then
            if r.dx then
              gate.other_x = x
            else
              gate.other_x = x + reduction.dx
            end
          end

          self:gate_at(x + dx, y + dy):replace_with(gate, index)
        end
      end
    end
  end

  for y = board.rows, 1, -1 do
    for x = 1, board.cols do
      local gate = self:gate_at(x, y)
      local match = false

      if gate:is_garbage() then
        if y < board.rows then
          for gx = x, x + gate.span - 1 do
            local g = self:gate_at(gx, y + 1)
            if g:is_match() and not g:is_garbage_match() then
              match = true
            end
          end
        end

        if match then
          for dx = 0, gate.span - 1 do
            self:put(x + dx, y, garbage_match_gate())
            self:gate_at(x + dx, y):replace_with(self:_random_single_gate(), dx, gate.span)
          end
        end
      end
    end
  end

  return score
end

function board:drop_gates()
  for y = board.rows - 1, 1, -1 do
    for x = 1, board.cols do
      local gate = self:gate_at(x, y)

      if gate:is_droppable(x, y) and self:is_gate_droppable(x, y) then
        if gate.other_x then
          if x < gate.other_x then
            gate:drop()
            self:gate_at(gate.other_x, y):drop()
          end
        else
          gate:drop()
        end
      end
    end
  end
end

-- 指定したゲートが行 y に落とせるかどうかを返す。
-- y を省略した場合、すぐ下の行 y + 1 に落とせるかどうかを返す。
function board:is_gate_droppable(gate_x, gate_y, y)
  --#if assert
  assert(1 <= gate_x)
  assert(gate_x <= board.cols)
  assert(1 <= gate_y)
  assert(gate_y <= board.row_next_gates)
  --#endif

  if gate_y == board.row_next_gates then
    return false
  end

  local gate, start_x, end_x = self:gate_at(gate_x, gate_y)

  if gate.other_x then
    start_x, end_x = min(gate_x, gate.other_x), max(gate_x, gate.other_x)
  else
    start_x, end_x = gate_x, gate_x + gate.span - 1
  end

  for x = start_x, end_x do
    if not self:is_empty(x, y or gate_y + 1) then
      return false
    end
  end

  return true
end

function board:_update_gates()
  -- swap などのペアとなるゲートを正しく落とすために、
  -- 一番下の行から上に向かって順番に update していく
  for y = board.row_next_gates, 1, -1 do
    for x = 1, board.cols do
      self:gate_at(x, y):update(self, x, y)
    end
  end
end

function board:render()
  for x = 1, board.cols do
    -- draw wires
    local line_x = self:screen_x(x) + 3
    line(line_x, self.offset_y,
      line_x, self.offset_y + self.height,
      colors.dark_gray)
  end

  -- draw idle gates
  for x = 1, board.cols do
    for y = 1, board.row_next_gates do
      local gate = self:gate_at(x, y)
      local screen_x = self:screen_x(x)
      local screen_y = self:screen_y(y) + self:dy()

      if gate.other_x and x < gate.other_x then
        local connection_y = self:screen_y(y) + 3
        line(self:screen_x(x) + 3, connection_y,
          self:screen_x(gate.other_x) + 3, connection_y,
          colors.yellow)
      end

      gate:render(screen_x, screen_y)

      -- マスクを描画
      if y == board.row_next_gates then
        -- TODO: 98 を定数にする
        spr(98, screen_x, screen_y)
      end
    end
  end
end

-- (x_left, y) と (x_right, y) のゲートを入れ替える
-- 入れ替えできた場合は true を、そうでない場合は false を返す
function board:swap(x_left, x_right, y)
  --#if assert
  assert(x_left < x_right)
  assert(x_right <= board.cols)
  assert(y <= board.rows)
  --#endif

  local left_gate = self:gate_at(x_left, y)
  local right_gate = self:gate_at(x_right, y)

  if not (left_gate:is_idle() and right_gate:is_idle()) then
    return false
  end

  -- 回路が A--[AB]--B のようになっている場合
  -- [AB] は入れ替えできない
  if left_gate.other_x and right_gate.other_x then
    if left_gate.other_x ~= x_right then
      return false
    end
  end

  -- 回路が A--[A?] のようになっている場合
  -- [A?] は入れ替えできない。
  if left_gate.other_x and left_gate.other_x < x_left and not right_gate:is_i() then
    return false
  end

  -- 回路が [?A]--A のようになっている場合も、
  -- [?A] は入れ替えできない。
  if not left_gate:is_i() and right_gate.other_x and x_right < right_gate.other_x then
    return false
  end

  left_gate:swap_with_right(x_right)
  right_gate:swap_with_left(x_left)

  return true
end

function board:dy()
  return 0
end

function board:screen_x(x)
  return self.offset_x + (x - 1) * tile_size
end

function board:screen_y(y)
  return self.offset_y + (y - 1) * tile_size - self.raised_dots
end

function board:y(screen_y)
  return ceil((screen_y - self.offset_y) / tile_size + 1)
end

function board:gate_at(x, y)
  --#if assert
  assert(1 <= x and x <= board.cols, x)
  assert(1 <= y and y <= board.row_next_gates, y)
  --#endif

  local gate = self._gates[x][y]

  --#if assert
  assert(gate)
  --#endif

  return gate
end

-- x, y が空かどうかを返す
-- おじゃまユニタリと SWAP, CNOT ゲートも考慮する
function board:is_empty(x, y)
  if y > board.row_next_gates then
    return false
  end

  for tmp_x = 1, x - 1 do
    local gate = self:gate_at(tmp_x, y)

    if gate:is_garbage() and (not gate:is_empty()) and x <= tmp_x + gate.span - 1 then
      return false
    end
    if gate.other_x and (not gate:is_empty()) and x < gate.other_x then
      return false
    end
  end

  return self:gate_at(x, y):is_empty()
end

function board:reducible_gate_at(x, y)
  local gate = self:gate_at(x, y)

  if gate:is_reducible() then
    return gate
  end
  return i_gate()
end

function board:put(x, y, gate)
  --#if assert
  assert(x >= 1, x)
  assert(x <= board.cols, x)
  assert(y >= 1, "y = " .. y .. " >= 1")
  assert(y <= board.row_next_gates, "y = " .. y .. " > board.row_next_gates")
  --#endif

  self._gates[x][y] = gate
end

function board:put_random_gate(x, y)
  repeat
    self:put(x, y, self:_random_single_gate())
  until #self:reduce(x, y, true).to == 0
end

function board:remove_gate(x, y)
  self:put(x, y, i_gate())
end

function board:drop_garbage()
  local span = flr(rnd(4)) + 3
  local x = flr(rnd(board.cols - span + 1)) + 1

  for i = x, x + span - 1 do
    if not self:is_empty(x, 1) then
      return
    end
  end

  local garbage = garbage_gate(span)
  self:put(x, 1, garbage)
  garbage:drop()
end

-------------------------------------------------------------------------------
-- gate reduction
-------------------------------------------------------------------------------

function board:reduce(x, y, include_next_gates)
  local rules = {
    h = {
      -- H          I
      -- H  ----->  I
      {
        match = {
          "h",
          "h",
        },
        to = {
          {},
          { dy = 1 }
        }
      },

      -- H          I
      -- X          I
      -- H  ----->  Z
      {
        match = {
          "h",
          "x",
          "h"
        },
        to = {
          {},
          { dy = 1 },
          { dy = 2, gate = z_gate() }
        }
      },

      -- H          I
      -- Z          I
      -- H  ----->  X
      {
        match = {
          "h",
          "z",
          "h"
        },
        to = {
          {},
          { dy = 1 },
          { dy = 2, gate = x_gate() }
        }
      },

      -- H H          I I
      -- C-X  ----->  X-C
      -- H H          I I
      --
      -- H H          I I
      -- X-C  ----->  C-X
      -- H H          I I
      {
        match = {
          "h,h",
          "control,cnot_x",
          "h,h"
        },
        to = {
          {}, { dx = true },
          { dy = 1, gate = cnot_x_gate() }, { dx = true, dy = 1, gate = control_gate() },
          { dy = 2 }, { dx = true, dy = 2 }
        }
      }
    },

    x = {
      -- X          I
      -- X  ----->  I
      {
        match = {
          "x",
          "x",
        },
        to = {
          {},
          { dy = 1 }
        }
      },


      -- X          I
      -- Z  ----->  Y
      {
        match = {
          "x",
          "z",
        },
        to = {
          {},
          { dy = 1, gate = y_gate() }
        }
      },

      -- X X          I I
      -- C-X  ----->  C-X
      -- X            I
      --
      -- X X          I I
      -- X-C  ----->  X-C
      --   X            I
      {
        match = {
          "x,x",
          "control,cnot_x",
          "x"
        },
        to = {
          {}, { dx = true },
          { dy = 2 }
        }
      },

      -- X            I
      -- X-C  ----->  X-C
      -- X            I
      --
      --   X            I
      -- C-X  ----->  C-X
      --   X            I
      {
        match = {
          "x",
          "cnot_x,control",
          "x"
        },
        to = {
          {},
          { dy = 2 }
        }
      }
    },

    y = {
      -- Y          I
      -- Y  ----->  I
      {
        match = {
          "y",
          "y",
        },
        to = {
          {},
          { dy = 1 }
        }
      }
    },

    z = {
      -- Z          I
      -- Z  ----->  I
      {
        match = {
          "z",
          "z",
        },
        to = {
          {},
          { dy = 1 }
        }
      },

      {
        match = {
          "z",
          "x",
        },
        to = {
          {},
          { dy = 1, gate = y_gate() }
        }
      },

      -- Z Z          I I
      -- C-X  ----->  C-X
      --   Z            I
      --
      -- Z Z          I I
      -- X-C  ----->  X-C
      -- Z            I
      {
        match = {
          "z,z",
          "control,cnot_x",
          "i,z"
        },
        to = {
          {}, { dx = true },
          { dx = true, dy = 2 }
        }
      },

      -- Z            I
      -- C-X  ----->  C-X
      -- Z            I
      --
      --   Z            I
      -- X-C  ----->  X-C
      --   Z            I
      {
        match = {
          "z",
          "control,cnot_x",
          "z"
        },
        to = {
          {},
          { dy = 2 }
        }
      }
    },

    s = {
      -- S          I
      -- S  ----->  Z
      {
        match = {
          "s",
          "s",
        },
        to = {
          {},
          { dy = 1, gate = z_gate() }
        }
      },

      -- S          I
      -- Z          I
      -- S  ----->  X
      {
        match = {
          "s",
          "z",
          "s"
        },
        to = {
          {},
          { dy = 1 },
          { dy = 2, gate = z_gate() }
        }
      }
    },

    t = {
      -- T          I
      -- T  ----->  S
      {
        match = {
          "t",
          "t",
        },
        to = {
          {},
          { dy = 1, gate = s_gate() }
        }
      },

      -- T          I
      -- S          I
      -- T  ----->  Z
      {
        match = {
          "t",
          "s",
          "t"
        },
        to = {
          {},
          { dy = 1 },
          { dy = 2, gate = z_gate() }
        }
      },

      -- T          I
      -- Z          I
      -- S          I
      -- T  ----->  I
      {
        match = {
          "t",
          "z",
          "s",
          "t"
        },
        to = {
          {},
          { dy = 1 },
          { dy = 2 },
          { dy = 3 }
        }
      },

      -- T          I
      -- S          I
      -- Z          I
      -- T  ----->  I
      {
        match = {
          "t",
          "s",
          "z",
          "t"
        },
        to = {
          {},
          { dy = 1 },
          { dy = 2 },
          { dy = 3 }
        }
      }
    },

    control = {
      -- C-X          I
      -- C-X  ----->  I
      --
      -- X-C          I
      -- X-C  ----->  I
      {
        match = {
          "control,cnot_x",
          "control,cnot_x"
        },
        to = {
          {}, { dx = true },
          { dy = 1 }, { dx = true, dy = 1 }
        }
      },

      -- C-X          I I
      -- X-C          I I
      -- C-X  ----->  S-S
      --
      -- X-C          I I
      -- C-X          I I
      -- X-C  ----->  S-S
      {
        match = {
          "control,cnot_x",
          "cnot_x,control",
          "control,cnot_x"
        },
        to = {
          {}, { dx = true },
          { dy = 1 }, { dx = true, dy = 1 },
          { dy = 2, gate = swap_gate() }, { dx = true, dy = 2, gate = swap_gate() }
        }
      }
    }
  }

  local reduction = { to = {} }
  local dx

  for _, each in pairs(rules[self:gate_at(x, y)._type] or {}) do
    -- other_x を決める
    local other_x = nil

    for i, match_row in pairs(each.match) do
      local current_y = y + i - 1
      local types = split(match_row)

      if (include_next_gates and current_y > self.row_next_gates) or
          (not include_next_gates and current_y > self.rows) then
        goto next
      end

      if #types == 2 then
        local current_gate = self:reducible_gate_at(x, current_y)

        if current_gate.other_x then
          if current_gate._type == types[1] then
            other_x = current_gate.other_x
            dx = other_x - x
          else
            goto next
          end
        end
      end
    end

    for i, match_row in pairs(each.match) do
      local current_y = y + i - 1
      local types = split(match_row)

      if (include_next_gates and current_y > self.row_next_gates) or
          (not include_next_gates and current_y > self.rows) then
        goto next
      end

      local current_gate = self:reducible_gate_at(x, current_y)
      if current_gate._type ~= types[1] then
        goto next
      end

      if types[2] and other_x then
        local current_other_gate = self:reducible_gate_at(other_x, current_y)
        if current_other_gate._type ~= types[2] then
          goto next
        end
      end
    end

    reduction = { to = each.to, dx = dx }
    goto matched

    ::next::
  end

  ::matched::
  return reduction

  -- -- Z            I
  -- -- C-X  ----->  C-X
  -- -- Z            I
  -- if gate:is_z() and
  --     gate_y1:is_control() and gate_y1_other_gate:is_cnot_x() and
  --     gate_y2:is_z() then
  --   return {
  --     score = 8,
  --     to = { {}, { dy = 2 } },
  --   }
  -- end


  -- --  S-S          I I
  -- --  S-S  ----->  I I
  -- if gate:is_swap() and other_gate:is_swap() and
  --     gate_y1:is_swap() and gate_y1_other_gate:is_swap() and
  --     gate.other_x == gate_y1.other_x then
  --   local dx = gate.other_x - x
  --   return {
  --     score = 30,
  --     to = { {}, { dx = dx },
  --       { dy = 1 }, { dx = dx, dy = 1 } },
  --   }
  -- end

  -- -- Z            I
  -- -- H X          H I
  -- -- X-C  ----->  X-C
  -- -- H X          H I
  -- local x2 = gate_y2.other_x
  -- if y <= 9 and
  --     gate:is_z() and
  --     gate_y1:is_h() and gate_y2:is_cnot_x() and self:reducible_gate_at(x2, y1):is_x() and
  --     self:reducible_gate_at(x2, y2):is_control() and
  --     self:reducible_gate_at(x, y3):is_h() and self:reducible_gate_at(x2, y3):is_x() then
  --   local dx = gate_y2.other_x - x
  --   return {
  --     score = 8,
  --     to = { {},
  --       { dx = dx, dy = 1 },
  --       { dx = dx, dy = 3 } }
  --   }
  -- end

  -- --
  -- -- SWAP gate rules
  -- --
  -- local gate_y2_other_gate_under_swap = i_gate()
  -- if gate_y1:is_swap() then
  --   gate_y2_other_gate_under_swap = self:reducible_gate_at(gate_y1.other_x, y2)
  -- end

  -- --  H            I
  -- --  S-S  ----->  S-S
  -- --    H            I
  -- if gate:is_h() and
  --     gate_y1:is_swap() and gate_y1_other_gate:is_swap() and
  --     gate_y2_other_gate_under_swap:is_h() then
  --   return {
  --     score = 10,
  --     to = { {}, { dx = gate_y1.other_x - x, dy = 2 } }
  --   }
  -- end

  -- --  X            I
  -- --  S-S  ----->  S-S
  -- --    X            I
  -- if gate:is_x() and
  --     gate_y1:is_swap() and gate_y1_other_gate:is_swap() and
  --     gate_y2_other_gate_under_swap:is_x() then
  --   return {
  --     score = 10,
  --     to = { {}, { dx = gate_y1.other_x - x, dy = 2 } }
  --   }
  -- end

  -- --  Y            I
  -- --  S-S  ----->  S-S
  -- --    Y            I
  -- if gate:is_y() and
  --     gate_y1:is_swap() and gate_y1_other_gate:is_swap() and
  --     gate_y2_other_gate_under_swap:is_y() then
  --   return {
  --     score = 10,
  --     to = { {}, { dx = gate_y1.other_x - x, dy = 2 } }
  --   }
  -- end

  -- --  Z            I
  -- --  S-S  ----->  S-S
  -- --    Z            I
  -- if gate:is_z() and
  --     gate_y1:is_swap() and gate_y1_other_gate:is_swap() and
  --     gate_y2_other_gate_under_swap:is_z() then
  --   return {
  --     score = 10,
  --     to = { {}, { dx = gate_y1.other_x - x, dy = 2 } }
  --   }
  -- end

  -- --  S            Z
  -- --  S-S  ----->  S-S
  -- --    S            I
  -- if gate:is_s() and
  --     gate_y1:is_swap() and gate_y1_other_gate:is_swap() and
  --     gate_y2_other_gate_under_swap:is_s() then
  --   return {
  --     score = 12,
  --     to = { { gate = z_gate() }, { dx = gate_y1.other_x - x, dy = 2 } }
  --   }
  -- end

  -- --  T            S
  -- --  S-S  ----->  S-S
  -- --    T            I
  -- if gate:is_t() and
  --     gate_y1:is_swap() and gate_y1_other_gate:is_swap() and
  --     gate_y2_other_gate_under_swap:is_t() then
  --   return {
  --     score = 12,
  --     to = { { gate = s_gate() }, { dx = gate_y1.other_x - x, dy = 2 } }
  --   }
  -- end

  -- --  C-X          I I
  -- --  S-S  ----->  S-S
  -- --  X-C          I I
  -- if gate:is_control() and other_gate:is_cnot_x() and
  --     gate_y1:is_swap() and gate_y1_other_gate:is_swap() and
  --     gate_y2:is_cnot_x() and gate_y2_other_gate:is_control() and
  --     gate.other_x == gate_y1.other_x and gate.other_x == gate_y2.other_x then
  --   local dx = gate.other_x - x
  --   return {
  --     score = 20,
  --     to = { {}, { dx = dx },
  --       { dy = 2 }, { dx = dx, dy = 2 } }
  --   }
  -- end

  -- return default
end

function board:is_game_over()
  if self.raised_dots ~= tile_size - 1 then
    return false
  end

  for x = 1, self.cols do
    if not self:is_empty(x, 1) then
      return true
    end
  end

  return false
end

-------------------------------------------------------------------------------
-- debug
-------------------------------------------------------------------------------

--#if debug
function board:_tostring()
  local str = ''

  for y = 1, board.row_next_gates do
    for x = 1, board.cols do
      str = str .. self:gate_at(x, y):_tostring() .. " "
    end
    str = str .. "\n"
  end

  return str
end

--#endif

return board
