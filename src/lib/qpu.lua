---@diagnostic disable: lowercase-global, global-in-nil-env

function is_single_block(_ENV)
  return type == 'h' or type == 'x' or type == 'y' or type == 'z' or type == 's' or type == 't'
end

local function _is_empty(board, block_x, block_y)
  if block_x < 1 or board.cols < block_x or board.rows < block_y then
    return false
  end

  return board.blocks[block_y][block_x].state == "idle" and board:is_empty(block_x, block_y)
end

local function _is_match(board, block_x, block_y, block)
  if board.rows < block_y then
    return false
  end

  local other_block = board.blocks[block_y][block_x]
  return other_block.type == block.type and other_block.state == "idle"
end

local function _is_swappable(board, block_x, block_y)
  if block_x < 1 or board.cols < block_x then
    return false
  end

  local block = board.blocks[block_y][block_x]
  return block.state == "idle" and (board:is_empty(block_x, block_y) or is_single_block(block))
end

-- singleton
qpu_class = new_class()

-- 新しい QPU プレーヤーを返す
--
-- level 3: easy, 2: normal, 1: hard
function qpu_class._init(_ENV, _board, _level)
  -- raise はテスト用で、false にすると QPU プレーヤーは x を押さない
  -- 通常は常に true
  board, cursor, level, sleep, raise =
  _board, _board and _board.cursor or nil, _level or 2, true, true
  init(_ENV)
end

function qpu_class.init(_ENV)
  score, commands = 0, {}
end

function qpu_class.update(_ENV)
  left, right, up, down, x, o, next_command = false, false, false, false, false, false, commands[1]

  if next_command then
    del(commands, next_command)
    _ENV[next_command] = true
  else
    if raise and board.top_block_y < 7 then
      add(commands, "o")
      add_sleep_command(_ENV, 3)
    else
      return for_all_reducible_blocks(_ENV, _reduce_cnot) or
          for_all_reducible_blocks(_ENV, _flatten_block) or
          board.contains_q_block or
          for_all_reducible_blocks(_ENV, _reduce_single_block)
    end
  end
end

function qpu_class._flatten_block(_ENV, each, each_x, each_y)
  -- 二列目より上のブロックについて、空のブロックがあればそこに落とす
  if 1 < each_y and is_single_block(each) then
    if find_left_and_right(_ENV, _is_empty, each, false, true) then
      return true
    end
  end
end

function qpu_class._reduce_single_block(_ENV, each, each_x, each_y)
  if is_single_block(each) then
    -- 下の行とマッチするか走査
    if each_y > 1 then
      if find_left_and_right(_ENV, _is_match, each) then
        return true
      end
    end

    -- 上の行とマッチするか走査
    if each_y < board.rows then
      if find_left_and_right(_ENV, _is_match, each, true) then
        return true
      end
    end
  end
end

function qpu_class._reduce_cnot(_ENV, each, each_x, each_y)
  local upper_block, lower_block =
  each_y < board.rows and board:reducible_block_at(each_x, each_y + 1) or block_class("i"),
      each_y > 1 and board:reducible_block_at(each_x, each_y - 1) or block_class("i")

  if not is_single_block(each) then
    -- d-2. 上の X-C を左にずらす
    --
    -- [X--]-C
    --  X-C  ■
    if each.type == "cnot_x" and each.other_x == each_x + 2 and
        lower_block.type == "cnot_x" and
        lower_block.other_x == each_x + 1 then
      move_and_swap(_ENV, each_x + 1, each_y)
      return true
    end

    -- e-2. 下の X-C を左にずらす
    --
    --  X-C  ■
    -- [X--]-C
    if each.type == "cnot_x" and each.other_x == each_x + 2 and
        upper_block.type == "cnot_x" and
        upper_block.other_x == each_x + 1 then
      move_and_swap(_ENV, each_x + 1, each_y)
      return true
    end

    -- a. CNOT を縮める
    --
    --   [X-]--C
    --   [C-]--X
    if (each.type == "cnot_x" or each.type == "control") and each_x + 1 < each.other_x then
      move_and_swap(_ENV, each_x, each_y)
      return true
    end

    -- b. CNOT を同じ方向 (右がC) にそろえる
    --
    --   C-X --> X-C
    --   X-C --> X-C
    if each.type == "control" and each.other_x == each_x + 1 then
      move_and_swap(_ENV, each_x, each_y)
      return true
    end

    -- c. CNOT を右に移動
    --
    --   X-[C ]
    if each_x < board.cols and
        each.type == "control" and each.other_x < each_x and _is_empty(board, each_x + 1, each_y) then
      move_and_swap(_ENV, each_x, each_y)
      return true
    end

    -- d-1. 上の X-C を左にずらす
    --
    -- [  X]-C
    --  X-C  ■
    if each_x > 1 and each_y > 1 and
        _is_empty(board, each_x - 1, each_y) and each.type == "cnot_x" and each.other_x == each_x + 1 and
        lower_block.type == "control" and
        lower_block.other_x == each_x - 1 then
      move_and_swap(_ENV, each_x - 1, each_y)
      return true
    end

    -- e. 下の X-C を左にずらす
    --
    --  X-C  ■
    -- [  X]-C
    if each_x > 1 and
        _is_empty(board, each_x - 1, each_y) and each.type == "cnot_x" and each.other_x == each_x + 1 and
        upper_block.type == "control" and
        upper_block.other_x == each_x - 1 then
      move_and_swap(_ENV, each_x - 1, each_y)
      return true
    end
  end
end

function qpu_class.find_left_and_right(_ENV, f, block, upper)
  local block_x, block_y, other_row_block_y, find_left, find_right =
  block.x, block.y, block.y + (upper and 1 or -1), true, true

  for dx = 1, board.cols - 1 do
    if not (find_left or find_right) then
      return false
    end

    if find_left then
      if _is_swappable(board, block_x - dx, block_y) then
        if f(board, block_x - dx, other_row_block_y, block) then
          move_and_swap(_ENV, block_x - 1, block_y)
          return true
        end
      else
        find_left = false
      end
    end

    if find_right then
      if _is_empty(board, block_x + dx, block_y) then
        if f(board, block_x + dx, other_row_block_y, block) then
          move_and_swap(_ENV, block_x, block_y)
          return true
        end
      else
        find_right = false
      end
    end
  end

  return false
end

function qpu_class.move_and_swap(_ENV, block_x, block_y)
  add_move_command(_ENV, block_x < cursor.x and "left" or "right", abs(cursor.x - block_x))
  add_move_command(_ENV, block_y < cursor.y and "down" or "up", abs(cursor.y - block_y))
  add_swap_command(_ENV)
end

function qpu_class.add_move_command(_ENV, direction, count)
  for _ = 1, count do
    add(commands, direction)

    if sleep then
      add_sleep_command(_ENV, ceil_rnd(level * 8))
    end
  end
end

function qpu_class.add_swap_command(_ENV)
  add(commands, "x")
  -- NOTE: ブロックの入れ替えコマンドを送った後は、
  -- 必ず次のように入れ替え完了するまで sleep する。
  -- これをしないと「左に連続して移動して落とす」などの
  -- 操作がうまく行かない。
  add_sleep_command(_ENV, 3)
end

function qpu_class.add_sleep_command(_ENV, count)
  for _ = 1, count do
    add(commands, "sleep")
  end
end

function qpu_class.for_all_reducible_blocks(_ENV, f)
  for each_y = 12, 1, -1 do
    for each_x = 1, board.cols do
      local each = board.reducible_blocks[each_y][each_x]
      if each and f(_ENV, each, each_x, each_y) then
        return true
      end
    end
  end

  return false
end
