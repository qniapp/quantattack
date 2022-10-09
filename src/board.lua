require("engine/core/class")

local garbage_gate = require("garbage_gate")
local gate_reduction_rules = require("gate_reduction_rules")
local i_gate = require("i_gate")
local h_gate = require("h_gate")
local x_gate = require("x_gate")
local y_gate = require("y_gate")
local z_gate = require("z_gate")
local s_gate = require("s_gate")
local t_gate = require("t_gate")
local swap_gate = require("swap_gate")
local quantum_gate = require("quantum_gate")

local board = new_class()

board.cols = 6 -- board の列数
board.rows = 12 -- board の行数

function board:_init()
  self.row_next_gates = board.rows + 1
  self._gates = {}
  self._offset_x = 10
  self._offset_y = 10

  -- fill the board with I gates
  for x = 1, board.cols do
    self._gates[x] = {}
    for y = 1, self.row_next_gates do
      self:put(x, y, i_gate())
    end
  end
end

function board:initialize_with_random_gates()
  for y = self.row_next_gates, 6, -1 do
    for x = 1, board.cols do
      if y >= board.rows - 2 or
          (y < board.rows - 2 and rnd(1) > (y - 11) * -0.1 and (not self:is_empty(x, y + 1))) then
        repeat
          self:put(x, y, self:_random_single_gate())
        until #gate_reduction_rules:reduce(self, x, y, true).to == 0
      end
    end
  end

  -- ランダムに swap を 1 つ置く
  local swap_x
  local swap_other_x
  local swap_y
  repeat
    swap_x = flr(rnd(board.cols)) + 1
    swap_other_x = flr(rnd(board.cols)) + 1
    swap_y = flr(rnd(board.rows)) + 1
  until not self:is_empty(swap_x, swap_y + 1) and swap_other_x ~= swap_x

  self:put(swap_x, swap_y, swap_gate(swap_other_x))
  self:put(swap_other_x, swap_y, swap_gate(swap_x))

  if swap_x < swap_other_x then
    for x = swap_x + 1, swap_other_x - 1 do
      self:put(x, swap_y, i_gate())
    end
  else
    for x = swap_other_x + 1, swap_x - 1 do
      self:put(x, swap_y, i_gate())
    end
  end
end

function board:_random_single_gate()
  local single_gate_types = { h_gate, x_gate, y_gate, z_gate, s_gate, t_gate }
  local gate_type = single_gate_types[flr(rnd(#single_gate_types)) + 1]

  return gate_type()
end

function board:update()
  self:reduce()
  self:drop_gates()
  self:_update_gates()
end

function board:reduce()
  for x = 1, board.cols do
    for y = 1, board.rows - 1 do
      if not self:gate_at(x, y):is_reducible() then
        goto next
      end

      local reduction = gate_reduction_rules:reduce(self, x, y)

      for _index, r in pairs(reduction.to) do
        local dx = r.dx or 0
        local dy = r.dy or 0
        local gate = r.gate or i_gate()

        self:gate_at(x + dx, y + dy):replace_with(gate)
      end

      ::next::
    end
  end
end

function board:drop_gates()
  for x = 1, board.cols do
    for y = board.rows - 1, 1, -1 do
      local gate = self:gate_at(x, y)

      if gate:is_placeholder() then
        goto next
      end
      if not gate:is_droppable() then
        goto next
      end

      -- swap ゲートでは、ペアのどちらかが接地している場合は drop しない
      if gate:is_swap() then
        if not (self:is_empty(x, y + 1) and self:is_empty(gate.other_x, y + 1)) then
          goto next
        end
      else
        for tmp_x = x, x + gate.span - 1 do
          if not self:is_empty(tmp_x, y + 1) then
            goto next
          end
        end
      end

      gate:drop(x, y)

      ::next::
    end
  end
end

function board:_update_gates()
  local gates_to_swap = {}

  for x = 1, board.cols do
    for y = board.rows, 1, -1 do
      local gate = self:gate_at(x, y)
      if gate:is_placeholder() then
        goto next
      end

      gate:update(self)

      if gate:is_swap_finished() then
        add(gates_to_swap, { gate = gate, y = y })
      end
      if gate:is_dropped() then
        self:put(x, y, i_gate())
        self:put(x, gate.y, gate)
      end

      ::next::
    end
  end

  foreach(gates_to_swap, function(each)
    self:put(each.gate.new_x_after_swap, each.y, each.gate)
  end)
end

function board:render()
  -- draw idle gates
  for x = 1, board.cols do
    for y = 1, self.row_next_gates do
      local gate = self:gate_at(x, y)
      local screen_x = self:screen_x(x)
      local screen_y = self:screen_y(y) + self:dy()

      if gate:is_swap() and x < gate.other_x then
        local connection_y = self:screen_y(y) + 3
        line(self:screen_x(x) + 3, connection_y,
          self:screen_x(gate.other_x) + 3, connection_y,
          colors.yellow)
      end

      gate:render(screen_x, screen_y)
    end
  end

  -- border left
  line(self._offset_x - 2, self._offset_y,
    self._offset_x - 2, self:screen_y(board.rows + 1),
    colors.white)
  -- border bottom
  line(self._offset_x - 1, self:screen_y(board.rows + 1),
    self._offset_x + board.cols * quantum_gate.size - 1, self:screen_y(board.rows + 1),
    colors.white)
  -- border right
  line(self._offset_x + board.cols * quantum_gate.size, self._offset_y,
    self._offset_x + board.cols * quantum_gate.size, self:screen_y(board.rows + 1),
    colors.white)
  -- mask under the border bottom
  rectfill(self._offset_x - 1, self:screen_y(board.rows + 1) + 1,
    self._offset_x + board.cols * quantum_gate.size - 1, 127,
    colors.black)
end

function board:swap(x_left, x_right, y)
  --#if assert
  assert(x_left < x_right)
  assert(x_right <= board.cols)
  assert(y <= board.rows)
  --#endif

  local left_gate = self:gate_at(x_left, y)
  local right_gate = self:gate_at(x_right, y)

  if not (left_gate:is_swappable() and right_gate:is_swappable()) then
    return false
  end

  -- 回路が [X-X] のようになっている場合 (X は SWAP ゲートを表す)、
  -- 実際には入れ替えしないが true を返す
  if left_gate:is_swap() and right_gate:is_swap() then
    if left_gate.other_x == x_right then
      --#if assert
      assert(right_gate.other_x == x_left)
      --#endif
      return true
    else
      return false
    end
  end

  -- 回路が X--[XH] のようになっている場合
  -- [XH] は入れ替えできない。
  if left_gate:is_swap() and not right_gate:is_i() then
    --#if assert
    assert(left_gate.other_x < x_left)
    --#endif
    return false
  end
  -- 回路が [HX]--X のようになっている場合も、
  -- [HX] は入れ替えできない。
  if right_gate:is_swap() and not left_gate:is_i() then
    --#if assert
    assert(x_right < right_gate.other_x)
    --#endif
    return false
  end

  left_gate:swap_with_right(x_right)
  right_gate:swap_with_left(x_left)

  if left_gate:is_swap() then
    local other_gate = self:gate_at(left_gate.other_x, y)
    other_gate.other_x = other_gate.other_x + 1
  end
  if right_gate:is_swap() then
    local other_gate = self:gate_at(right_gate.other_x, y)
    other_gate.other_x = other_gate.other_x - 1
  end

  return true
end

function board:dy()
  return 0
end

function board:screen_x(x)
  return self._offset_x + (x - 1) * quantum_gate.size
end

function board:screen_y(y)
  return self._offset_y + (y - 1) * quantum_gate.size
end

function board:y(screen_y)
  return ceil((screen_y - self._offset_y) / quantum_gate.size + 1)
end

function board:gate_at(x, y)
  --#if assert
  assert(x >= 1, x)
  assert(x <= board.cols, x)
  assert(y >= 1, "y = " .. y .. " >= 1")
  assert(y <= self.row_next_gates, "y = " .. y .. " > board.row_next_gates")
  --#endif

  local gate = self._gates[x][y]

  --#if assert
  assert(gate)
  --#endif

  return gate
end

-- x, y が空かどうかを返す
-- garbage と swap ゲートも考慮する
function board:is_empty(x, y)
  for tmp_x = 1, x - 1 do
    local gate = self:gate_at(tmp_x, y)

    if gate:is_garbage() and x <= tmp_x + gate.span - 1 then
      return false
    end
    if gate:is_swap() and x <= gate.other_x then
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
  assert(y <= self.row_next_gates, "y = " .. y .. " > board.row_next_gates")
  --#endif

  self._gates[x][y] = gate
end

function board:put_garbage()
  local span = flr(rnd(4)) + 3
  local x = flr(rnd(board.cols - span + 1)) + 1

  self:put(x, 1, garbage_gate(x, span))
end

function board:gates_to_puff()
  local gates = {}

  for x = 1, board.cols do
    for y = 1, board.rows do
      local gate = self:gate_at(x, y)

      if gate.puff then
        gate.x = x
        gate.y = y
        add(gates, gate)
      end
    end
  end

  return gates
end

function board:_tostring()
  local str = ''

  for y = 1, self.row_next_gates do
    for x = 1, board.cols do
      str = str .. self:gate_at(x, y):_tostring() .. " "
    end
    str = str .. "\n"
  end

  return str
end

return board
