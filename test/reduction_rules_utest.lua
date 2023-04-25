require("engine/test/bustedhelper")
require("test/test_helper")
require("lib/board")

-- TODO: assert.is_i とかをほかのテストでも使えるようにする

-- https://github.com/lunarmodules/say
local say = require("say")

local function is_i(_state, arguments)
  if not type(arguments[1]) == "table" or #arguments ~= 1 then
    return false
  end

  return arguments[1].type == "i"
end

say:set("assertion.is_i.positive", "Expected %s \nto be an I block")
say:set("assertion.is_i.negative", "Expected %s \n not to be an I block")
assert:register("assertion", "is_i", is_i, "assertion.is_i.positive", "assertion.is_i.negative")

local function is_h(_state, arguments)
  if not type(arguments[1]) == "table" or #arguments ~= 1 then
    return false
  end

  return arguments[1].type == "h"
end

say:set("assertion.is_h.positive", "Expected %s \nto be an H block")
say:set("assertion.is_h.negative", "Expected %s \n not to be an H block")
assert:register("assertion", "is_h", is_h, "assertion.is_h.positive", "assertion.is_h.negative")

local function is_x(_state, arguments)
  if not type(arguments[1]) == "table" or #arguments ~= 1 then
    return false
  end

  return arguments[1].type == "x"
end

say:set("assertion.is_x.positive", "Expected %s \nto be an X block")
say:set("assertion.is_x.negative", "Expected %s \n not to be an X block")
assert:register("assertion", "is_x", is_x, "assertion.is_x.positive", "assertion.is_x.negative")

local function is_y(_state, arguments)
  if not type(arguments[1]) == "table" or #arguments ~= 1 then
    return false
  end

  return arguments[1].type == "y"
end

say:set("assertion.is_y.positive", "Expected %s \nto be a Y block")
say:set("assertion.is_y.negative", "Expected %s \n not to be a Y block")
assert:register("assertion", "is_y", is_y, "assertion.is_y.positive", "assertion.is_y.negative")

local function is_z(_state, arguments)
  if not type(arguments[1]) == "table" or #arguments ~= 1 then
    return false
  end

  return arguments[1].type == "z"
end

say:set("assertion.is_z.positive", "Expected %s \nto be a Z block")
say:set("assertion.is_z.negative", "Expected %s \n not to be a Z block")
assert:register("assertion", "is_z", is_z, "assertion.is_z.positive", "assertion.is_z.negative")

local function is_s(_state, arguments)
  if not type(arguments[1]) == "table" or #arguments ~= 1 then
    return false
  end

  return arguments[1].type == "s"
end

say:set("assertion.is_s.positive", "Expected %s \nto be an S block")
say:set("assertion.is_s.negative", "Expected %s \n not to be an S block")
assert:register("assertion", "is_s", is_s, "assertion.is_s.positive", "assertion.is_s.negative")

local function is_control(_state, arguments)
  if not type(arguments[1]) == "table" or
      #arguments ~= 2 then
    return false
  end

  return arguments[1].type == "control" and
      arguments[1].other_x == arguments[2]
end

say:set("assertion.is_control.positive", "Expected %s \nto be a CONTROL block")
say:set("assertion.is_control.negative", "Expected %s \n not to be a CONTROL block")
assert:register("assertion", "is_control", is_control, "assertion.is_control.positive", "assertion.is_control.negative")

local function is_cnot_x(_state, arguments)
  if not type(arguments[1]) == "table" or
      #arguments ~= 2 then
    return false
  end

  return arguments[1].type == "cnot_x" and
      arguments[1].other_x == arguments[2]
end

say:set("assertion.is_cnot_x.positive", "Expected %s \nto be a X (CNOT) block")
say:set("assertion.is_cnot_x.negative", "Expected %s \n not to be a X (CNOT) block")
assert:register("assertion", "is_cnot_x", is_cnot_x, "assertion.is_cnot_x.positive", "assertion.is_cnot_x.negative")

local function is_swap(_state, arguments)
  if not type(arguments[1]) == "table" or
      #arguments ~= 2 then
    return false
  end

  return arguments[1].type == "swap" and
      arguments[1].other_x == arguments[2]
end

say:set("assertion.is_swap.positive", "Expected %s \nto be a SWAP block")
say:set("assertion.is_swap.negative", "Expected %s \n not to be a SWAP block")
assert:register("assertion", "is_swap", is_swap, "assertion.is_swap.positive", "assertion.is_swap.negative")

local function becomes_i(_, arguments)
  if not type(arguments[1]) == "table" or
      #arguments ~= 1 or
      arguments[1].new_block == nil then
    return false
  end

  return arguments[1].new_block.type == "i"
end

say:set("assertion.becomes_i.positive", "Expected %s \nto become an I block")
say:set("assertion.becomes_i.negative", "Expected %s \n not to become an I block")
assert:register("assertion", "becomes_i", becomes_i, "assertion.becomes_i.positive", "assertion.becomes_i.negative")

local function becomes_x(_, arguments)
  if not type(arguments[1]) == "table" or
      #arguments ~= 1 or
      arguments[1].new_block == nil then
    return false
  end

  return arguments[1].new_block.type == "x"
end

say:set("assertion.becomes_x.positive", "Expected %s \nto become an X block")
say:set("assertion.becomes_x.negative", "Expected %s \n not to become an X block")
assert:register("assertion", "becomes_x", becomes_x, "assertion.becomes_x.positive", "assertion.becomes_x.negative")

local function becomes_y(_, arguments)
  if not type(arguments[1]) == "table" or
      #arguments ~= 1 or
      arguments[1].new_block == nil then
    return false
  end

  return arguments[1].new_block.type == "y"
end

say:set("assertion.becomes_y.positive", "Expected %s \nto become a Y block")
say:set("assertion.becomes_y.negative", "Expected %s \n not to become a Y block")
assert:register("assertion", "becomes_y", becomes_y, "assertion.becomes_y.positive", "assertion.becomes_y.negative")

local function becomes_z(_, arguments)
  if not type(arguments[1]) == "table" or
      #arguments ~= 1 or
      arguments[1].new_block == nil then
    return false
  end

  return arguments[1].new_block.type == "z"
end

say:set("assertion.becomes_z.positive", "Expected %s \nto become a Z block")
say:set("assertion.becomes_z.negative", "Expected %s \n not to become a Z block")
assert:register("assertion", "becomes_z", becomes_z, "assertion.becomes_z.positive", "assertion.becomes_z.negative")

local function becomes_s(_, arguments)
  if not type(arguments[1]) == "table" or
      #arguments ~= 1 or
      arguments[1].new_block == nil then
    return false
  end

  return arguments[1].new_block.type == "s"
end

say:set("assertion.becomes_s.positive", "Expected %s \nto become an S block")
say:set("assertion.becomes_s.negative", "Expected %s \n not to become an S block")
assert:register("assertion", "becomes_s", becomes_s, "assertion.becomes_s.positive", "assertion.becomes_s.negative")

local function becomes_control(_, arguments)
  if not type(arguments[1]) == "table" or
      #arguments ~= 2 or
      arguments[1].new_block == nil then
    return false
  end

  return arguments[1].new_block.type == "control"
      and arguments[1].new_block.other_x == arguments[2]
end

say:set("assertion.becomes_control.positive", "Expected %s \nto become a CONTROL block")
say:set("assertion.becomes_control.negative", "Expected %s \n not to become a CONTROL block")
assert:register("assertion", "becomes_control", becomes_control, "assertion.becomes_control.positive",
  "assertion.becomes_control.negative")

local function becomes_cnot_x(_, arguments)
  if not type(arguments[1]) == "table" or
      #arguments ~= 2 or
      arguments[1].new_block == nil then
    return false
  end

  return arguments[1].new_block.type == "cnot_x"
      and arguments[1].new_block.other_x == arguments[2]
end

say:set("assertion.becomes_cnot_x.positive", "Expected %s \nto become a CNOT_X block")
say:set("assertion.becomes_cnot_x.negative", "Expected %s \n not to become a CNOT_X block")
assert:register("assertion", "becomes_cnot_x", becomes_cnot_x, "assertion.becomes_cnot_x.positive",
  "assertion.becomes_cnot_x.negative")

local function becomes_swap(_, arguments)
  if not type(arguments[1]) == "table" or
      #arguments ~= 2 or
      arguments[1].new_block == nil then
    return false
  end

  return arguments[1].new_block.type == "swap"
      and arguments[1].new_block.other_x == arguments[2]
end

say:set("assertion.becomes_swap.positive", "Expected %s \nto become a SWAP block")
say:set("assertion.becomes_swap.negative", "Expected %s \n not to become a SWAP block")
assert:register("assertion", "becomes_swap", becomes_swap, "assertion.becomes_swap.positive",
  "assertion.becomes_swap.negative")

describe('ブロックの簡約パターン', function()
  local board

  local put = function(x, y, block_type, other_x)
    board:put(x, y, block_class(block_type))
    board:block_at(x, y).other_x = other_x
  end

  local reduce_blocks = function()
    board:reduce_blocks()
  end

  local block_at = function(x, y)
    return board:block_at(x, y)
  end

  before_each(function()
    board = board_class()
  end)

  -----------------------------------------------------------------------------
  -- 10 Points
  -----------------------------------------------------------------------------

  -- ┌───┐
  -- │ H │        I
  -- ├───┤ ───▶
  -- │ H │        I
  -- └───┘
  it('HH ─▶ I', function()
    put(1, 2, "h")
    put(1, 1, "h")

    reduce_blocks()

    assert.becomes_i(block_at(1, 2))
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ X │        I
  -- ├───┤ ───▶
  -- │ X │        I
  -- └───┘
  it('XX ─▶ I', function()
    put(1, 2, "x")
    put(1, 1, "x")

    reduce_blocks()

    assert.becomes_i(block_at(1, 2))
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ Y │        I
  -- ├───┤ ───▶
  -- │ Y │        I
  -- └───┘
  it('YY ─▶ I', function()
    put(1, 2, "y")
    put(1, 1, "y")

    reduce_blocks()

    assert.becomes_i(block_at(1, 2))
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ Z │        I
  -- ├───┤ ───▶
  -- │ Z │        I
  -- └───┘
  it('ZZ ─▶ I', function()
    put(1, 2, "z")
    put(1, 1, "z")

    reduce_blocks()

    assert.becomes_i(block_at(1, 2))
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ S │        I
  -- ├───┤ ───▶ ┌───┐
  -- │ S │      │ Z │
  -- └───┘      └───┘
  it('SS ─▶ Z', function()
    put(1, 2, "s")
    put(1, 1, "s")

    reduce_blocks()

    assert.becomes_i(block_at(1, 2))
    assert.becomes_z(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ T │        I
  -- ├───┤ ───▶ ┌───┐
  -- │ T │      │ S │
  -- └───┘      └───┘
  it('TT ─▶ S', function()
    put(1, 2, "t")
    put(1, 1, "t")

    reduce_blocks()

    assert.becomes_i(block_at(1, 2))
    assert.becomes_s(block_at(1, 1))
  end)

  -----------------------------------------------------------------------------
  -- 20 Points
  -----------------------------------------------------------------------------

  -- ┌───┐
  -- │ H │        I
  -- ├───┤ ───▶
  -- │ X │        I
  -- ├───┤ ───▶ ┌───┐
  -- │ H │      │ Z │
  -- └───┘      └───┘
  it('HXH ─▶ Z', function()
    put(1, 3, "h")
    put(1, 2, "x")
    put(1, 1, "h")

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(1, 2))
    assert.becomes_z(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ H │        I
  -- ├───┤ ───▶
  -- │ Y │        I
  -- ├───┤ ───▶ ┌───┐
  -- │ H │      │ Y │
  -- └───┘      └───┘
  it('HYH ─▶ Y', function()
    put(1, 3, "h")
    put(1, 2, "y")
    put(1, 1, "h")

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(1, 2))
    assert.becomes_y(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ H │        I
  -- ├───┤ ───▶
  -- │ Z │        I
  -- ├───┤ ───▶ ┌───┐
  -- │ H │      │ X │
  -- └───┘      └───┘
  it('HZH ─▶ X', function()
    put(1, 3, "h")
    put(1, 2, "z")
    put(1, 1, "h")

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(1, 2))
    assert.becomes_x(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ S │        I
  -- ├───┤ ───▶
  -- │ Z │        I
  -- ├───┤ ───▶ ┌───┐
  -- │ S │      │ Z │
  -- └───┘      └───┘
  it('SZS ─▶ Z', function()
    put(1, 3, "s")
    put(1, 2, "z")
    put(1, 1, "s")

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(1, 2))
    assert.becomes_z(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ T │        I
  -- ├───┤ ───▶
  -- │ S │        I
  -- ├───┤ ───▶ ┌───┐
  -- │ T │      │ Z │
  -- └───┘      └───┘
  it('TST ─▶ Z', function()
    put(1, 3, "t")
    put(1, 2, "s")
    put(1, 1, "t")

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(1, 2))
    assert.becomes_z(block_at(1, 1))
  end)

  -----------------------------------------------------------------------------
  -- 30 Points
  -----------------------------------------------------------------------------

  -- ┌───┐
  -- │ T │        I
  -- ├───┤ ───▶
  -- │ Z │        I
  -- ├───┤ ───▶
  -- │ S │        I
  -- ├───┤ ───▶
  -- │ T │        I
  -- └───┘
  it('TZST ─▶ I', function()
    put(1, 4, "t")
    put(1, 3, "z")
    put(1, 2, "s")
    put(1, 1, "t")

    reduce_blocks()

    assert.becomes_i(block_at(1, 4))
    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(1, 2))
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ T │        I
  -- ├───┤ ───▶
  -- │ S │        I
  -- ├───┤ ───▶
  -- │ Z │        I
  -- ├───┤ ───▶
  -- │ T │        I
  -- └───┘
  it('TSZT ─▶ I', function()
    put(1, 4, "t")
    put(1, 3, "s")
    put(1, 2, "z")
    put(1, 1, "t")

    reduce_blocks()

    assert.becomes_i(block_at(1, 4))
    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(1, 2))
    assert.becomes_i(block_at(1, 1))
  end)

  -----------------------------------------------------------------------------
  -- 40 Points
  -----------------------------------------------------------------------------

  -- ┌───┐    ┌───┐
  -- │ C ├────┤ X │        I   I
  -- ├───┤    ├───┤ ───▶
  -- │ C ├────┤ X │        I   I
  -- └───┘    └───┘
  it('C-X C-X ─▶ I', function()
    put(1, 2, "control", 3)
    put(3, 2, "cnot_x", 1)
    put(1, 1, "control", 3)
    put(3, 1, "cnot_x", 1)

    reduce_blocks()

    assert.becomes_i(block_at(1, 2))
    assert.becomes_i(block_at(3, 2))
    assert.becomes_i(block_at(1, 1))
    assert.becomes_i(block_at(3, 1))
  end)

  -- ┌───┐    ┌───┐
  -- │ X ├────┤ C │        I   I
  -- ├───┤    ├───┤ ───▶
  -- │ X ├────┤ C │        I   I
  -- └───┘    └───┘
  it('X-C X-C ─▶ I', function()
    put(1, 2, "cnot_x", 3)
    put(3, 2, "control", 1)
    put(1, 1, "cnot_x", 3)
    put(3, 1, "control", 1)

    reduce_blocks()

    assert.becomes_i(block_at(1, 2))
    assert.becomes_i(block_at(3, 2))
    assert.becomes_i(block_at(1, 1))
    assert.becomes_i(block_at(3, 1))
  end)

  -----------------------------------------------------------------------------
  -- 50 Points
  -----------------------------------------------------------------------------

  -- ┌───┐
  -- │ H │                 I
  -- └───┘
  --   X────────X   ───▶   X────────X
  --          ┌───┐
  --          │ H │                 I
  --          └───┘
  it('H X-X H ─▶ X-X', function()
    put(1, 3, "h")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(3, 1, "h")

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(3, 1))
  end)

  --          ┌───┐
  --          │ H │                 I
  --          └───┘
  --   X────────X   ───▶   X────────X
  -- ┌───┐
  -- │ H │                 I
  -- └───┘
  it('H X-X H ─▶ X-X (左右反転)', function()
    put(3, 3, "h")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(1, 1, "h")

    reduce_blocks()

    assert.becomes_i(block_at(3, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ X │                 I
  -- └───┘
  --   X────────X   ───▶   X────────X
  --          ┌───┐
  --          │ X │                 I
  --          └───┘
  it('X X-X X ─▶ X-X', function()
    put(1, 3, "x")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(3, 1, "x")

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(3, 1))
  end)

  --          ┌───┐
  --          │ X │                 I
  --          └───┘
  --   X────────X   ───▶   X────────X
  -- ┌───┐
  -- │ X │                 I
  -- └───┘
  it('X X-X X ─▶ X-X (左右反転)', function()
    put(3, 3, "x")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(1, 1, "x")

    reduce_blocks()

    assert.becomes_i(block_at(3, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ Y │                 I
  -- └───┘
  --   X────────X   ───▶   X────────X
  --          ┌───┐
  --          │ Y │                 I
  --          └───┘
  it('Y X-X Y ─▶ X-X', function()
    put(1, 3, "y")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(3, 1, "y")

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(3, 1))
  end)

  --          ┌───┐
  --          │ Y │                 I
  --          └───┘
  --   X────────X   ───▶   X────────X
  -- ┌───┐
  -- │ Y │                 I
  -- └───┘
  it('Y X-X Y ─▶ X-X (左右反転)', function()
    put(3, 3, "y")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(1, 1, "y")

    reduce_blocks()

    assert.becomes_i(block_at(3, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ Z │                 I
  -- └───┘
  --   X────────X   ───▶   X────────X
  --          ┌───┐
  --          │ Z │                 I
  --          └───┘
  it('Z X-X Z ─▶ X-X', function()
    put(1, 3, "z")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(3, 1, "z")

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(3, 1))
  end)

  --          ┌───┐
  --          │ Z │                 I
  --          └───┘
  --   X────────X   ───▶   X────────X
  -- ┌───┐
  -- │ Z │                 I
  -- └───┘
  it('Z X-X Z ─▶ X-X (左右反転)', function()
    put(3, 3, "z")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(1, 1, "z")

    reduce_blocks()

    assert.becomes_i(block_at(3, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐               ┌───┐
  -- │ S │               │ Z │
  -- └───┘               └───┘
  --   X────────X   ───▶   X────────X
  --          ┌───┐
  --          │ S │                 I
  --          └───┘
  it('S X-X S ─▶ Z X-X', function()
    put(1, 3, "s")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(3, 1, "s")

    reduce_blocks()

    assert.becomes_z(block_at(1, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(3, 1))
  end)

  --          ┌───┐               ┌───┐
  --          │ S │               │ Z │
  --          └───┘               └───┘
  --   X────────X   ───▶   X────────X
  -- ┌───┐
  -- │ S │                 I
  -- └───┘
  it('S X-X S ─▶ Z X-X (左右反転)', function()
    put(3, 3, "s")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(1, 1, "s")

    reduce_blocks()

    assert.becomes_z(block_at(3, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐               ┌───┐
  -- │ T │               │ S │
  -- └───┘               └───┘
  --   X────────X   ───▶   X────────X
  --          ┌───┐
  --          │ T │                 I
  --          └───┘
  it('T X-X T ─▶ S X-X', function()
    put(1, 3, "t")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(3, 1, "t")

    reduce_blocks()

    assert.becomes_s(block_at(1, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(3, 1))
  end)

  --          ┌───┐               ┌───┐
  --          │ T │               │ S │
  --          └───┘               └───┘
  --   X────────X   ───▶   X────────X
  -- ┌───┐
  -- │ T │                 I
  -- └───┘
  it('T X-X T ─▶ S X-X (左右反転)', function()
    put(3, 3, "t")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(1, 1, "t")

    reduce_blocks()

    assert.becomes_s(block_at(3, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
  end)

  -----------------------------------------------------------------------------
  -- 60 Points
  -----------------------------------------------------------------------------

  -- ┌───┐               ┌───┐
  -- │ H │               │ Z │
  -- └───┘               └───┘
  --   X────────X   ───▶   X────────X
  --          ┌───┐
  --          │ X │                 I
  --          ├───┤
  --          │ H │                 I
  --          └───┘
  it('H X-X XH ─▶ Z X-X', function()
    put(1, 4, "h")
    put(1, 3, "swap", 3)
    put(3, 3, "swap", 1)
    put(3, 2, "x")
    put(3, 1, "h")

    reduce_blocks()

    assert.becomes_z(block_at(1, 4))
    assert.is_swap(block_at(1, 3), 3)
    assert.is_swap(block_at(3, 3), 1)
    assert.becomes_i(block_at(3, 2))
    assert.becomes_i(block_at(3, 1))
  end)

  --          ┌───┐               ┌───┐
  --          │ H │               │ Z │
  --          └───┘               └───┘
  --   X────────X   ───▶   X────────X
  -- ┌───┐
  -- │ X │                 I
  -- ├───┤
  -- │ H │                 I
  -- └───┘
  it('H X-X XH ─▶ Z X-X (左右反転)', function()
    put(3, 4, "h")
    put(1, 3, "swap", 3)
    put(3, 3, "swap", 1)
    put(1, 2, "x")
    put(1, 1, "h")

    reduce_blocks()

    assert.becomes_z(block_at(3, 4))
    assert.is_swap(block_at(1, 3), 3)
    assert.is_swap(block_at(3, 3), 1)
    assert.becomes_i(block_at(1, 2))
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ H │                 I
  -- ├───┤               ┌───┐
  -- │ X │               │ Z │
  -- └───┘               └───┘
  --   X────────X   ───▶   X────────X
  --          ┌───┐
  --          │ H │                 I
  --          └───┘
  it('HX X-X H ─▶ Z X-X', function()
    put(1, 4, "h")
    put(1, 3, "x")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(3, 1, "h")

    reduce_blocks()

    assert.becomes_i(block_at(1, 4))
    assert.becomes_z(block_at(1, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(3, 1))
  end)

  --          ┌───┐
  --          │ H │                 I
  --          ├───┤               ┌───┐
  --          │ X │               │ Z │
  --          └───┘               └───┘
  --   X────────X   ───▶   X────────X
  -- ┌───┐
  -- │ H │                 I
  -- └───┘
  it('HX X-X H ─▶ Z X-X (左右反転)', function()
    put(3, 4, "h")
    put(3, 3, "x")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(1, 1, "h")

    reduce_blocks()

    assert.becomes_i(block_at(3, 4))
    assert.becomes_z(block_at(3, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐               ┌───┐
  -- │ H │               │ Y │
  -- └───┘               └───┘
  --   X────────X   ───▶   X────────X
  --          ┌───┐
  --          │ Y │                 I
  --          ├───┤
  --          │ H │                 I
  --          └───┘
  it('H X-X YH ─▶ Y X-X', function()
    put(1, 4, "h")
    put(1, 3, "swap", 3)
    put(3, 3, "swap", 1)
    put(3, 2, "y")
    put(3, 1, "h")

    reduce_blocks()

    assert.becomes_y(block_at(1, 4))
    assert.is_swap(block_at(1, 3), 3)
    assert.is_swap(block_at(3, 3), 1)
    assert.becomes_i(block_at(3, 2))
    assert.becomes_i(block_at(3, 1))
  end)

  --          ┌───┐               ┌───┐
  --          │ H │               │ Y │
  --          └───┘               └───┘
  --   X────────X   ───▶   X────────X
  -- ┌───┐
  -- │ Y │                 I
  -- ├───┤
  -- │ H │                 I
  -- └───┘
  it('H X-X YH ─▶ Y X-X (左右反転)', function()
    put(3, 4, "h")
    put(1, 3, "swap", 3)
    put(3, 3, "swap", 1)
    put(1, 2, "y")
    put(1, 1, "h")

    reduce_blocks()

    assert.becomes_y(block_at(3, 4))
    assert.is_swap(block_at(1, 3), 3)
    assert.is_swap(block_at(3, 3), 1)
    assert.becomes_i(block_at(1, 2))
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ H │                 I
  -- ├───┤               ┌───┐
  -- │ Y │               │ Y │
  -- └───┘               └───┘
  --   X────────X   ───▶   X────────X
  --          ┌───┐
  --          │ H │                 I
  --          └───┘
  it('HY X-X H ─▶ Y X-X', function()
    put(1, 4, "h")
    put(1, 3, "y")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(3, 1, "h")

    reduce_blocks()

    assert.becomes_i(block_at(1, 4))
    assert.becomes_y(block_at(1, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(3, 1))
  end)

  --          ┌───┐
  --          │ H │                 I
  --          ├───┤               ┌───┐
  --          │ Y │               │ Y │
  --          └───┘               └───┘
  --   X────────X   ───▶   X────────X
  -- ┌───┐
  -- │ H │                 I
  -- └───┘
  it('HY X-X H ─▶ Y X-X (左右反転)', function()
    put(3, 4, "h")
    put(3, 3, "y")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(1, 1, "h")

    reduce_blocks()

    assert.becomes_i(block_at(3, 4))
    assert.becomes_y(block_at(3, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐               ┌───┐
  -- │ H │               │ X │
  -- └───┘               └───┘
  --   X────────X   ───▶   X────────X
  --          ┌───┐
  --          │ Z │                 I
  --          ├───┤
  --          │ H │                 I
  --          └───┘
  it('H X-X ZH ─▶ X X-X', function()
    put(1, 4, "h")
    put(1, 3, "swap", 3)
    put(3, 3, "swap", 1)
    put(3, 2, "z")
    put(3, 1, "h")

    reduce_blocks()

    assert.becomes_x(block_at(1, 4))
    assert.is_swap(block_at(1, 3), 3)
    assert.is_swap(block_at(3, 3), 1)
    assert.becomes_i(block_at(3, 2))
    assert.becomes_i(block_at(3, 1))
  end)

  --          ┌───┐               ┌───┐
  --          │ H │               │ X │
  --          └───┘               └───┘
  --   X────────X   ───▶   X────────X
  -- ┌───┐
  -- │ Z │                 I
  -- ├───┤
  -- │ H │                 I
  -- └───┘
  it('H X-X ZH ─▶ X X-X (左右反転)', function()
    put(3, 4, "h")
    put(1, 3, "swap", 3)
    put(3, 3, "swap", 1)
    put(1, 2, "z")
    put(1, 1, "h")

    reduce_blocks()

    assert.becomes_x(block_at(3, 4))
    assert.is_swap(block_at(1, 3), 3)
    assert.is_swap(block_at(3, 3), 1)
    assert.becomes_i(block_at(1, 2))
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ H │                 I
  -- ├───┤               ┌───┐
  -- │ Z │               │ X │
  -- └───┘               └───┘
  --   X────────X   ───▶   X────────X
  --          ┌───┐
  --          │ H │                 I
  --          └───┘
  it('HZ X-X H ─▶ X X-X', function()
    put(1, 4, "h")
    put(1, 3, "z")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(3, 1, "h")

    reduce_blocks()

    assert.becomes_i(block_at(1, 4))
    assert.becomes_x(block_at(1, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(3, 1))
  end)

  --          ┌───┐
  --          │ H │                 I
  --          ├───┤               ┌───┐
  --          │ Z │               │ X │
  --          └───┘               └───┘
  --   X────────X   ───▶   X────────X
  -- ┌───┐
  -- │ H │                 I
  -- └───┘
  it('HZ X-X H ─▶ X X-X (左右反転)', function()
    put(3, 4, "h")
    put(3, 3, "z")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(1, 1, "h")

    reduce_blocks()

    assert.becomes_i(block_at(3, 4))
    assert.becomes_x(block_at(3, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
  end)

  -----------------------------------------------------------------------------
  -- 70 Points
  -----------------------------------------------------------------------------

  -- ┌───┐    ┌───┐
  -- │ C ├────┤ X │        I        I
  -- ├───┤    ├───┤ ───▶
  -- │ X ├────┤ C │        I        I
  -- ├───┤    ├───┤ ───▶ ┌───┐    ┌───┐
  -- │ C ├────┤ X │      │ S ├────┤ S │
  -- └───┘    └───┘      └───┘    └───┘
  it('C-X X-C C-X ─▶ X-X', function()
    put(1, 3, "control", 3)
    put(3, 3, "cnot_x", 1)
    put(1, 2, "cnot_x", 3)
    put(3, 2, "control", 1)
    put(1, 1, "control", 3)
    put(3, 1, "cnot_x", 1)

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(3, 3))
    assert.becomes_i(block_at(1, 2))
    assert.becomes_i(block_at(3, 2))
    assert.becomes_swap(block_at(1, 1), 3)
    assert.becomes_swap(block_at(3, 1), 1)
  end)

  -- ┌───┐    ┌───┐
  -- │ X ├────┤ C │        I        I
  -- ├───┤    ├───┤ ───▶
  -- │ C ├────┤ X │        I        I
  -- ├───┤    ├───┤ ───▶ ┌───┐    ┌───┐
  -- │ X ├────┤ C │      │ S ├────┤ S │
  -- └───┘    └───┘      └───┘    └───┘
  it('X-C C-X X-C ─▶ X-X', function()
    put(1, 3, "cnot_x", 3)
    put(3, 3, "control", 1)
    put(1, 2, "control", 3)
    put(3, 2, "cnot_x", 1)
    put(1, 1, "cnot_x", 3)
    put(3, 1, "control", 1)

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(3, 3))
    assert.becomes_i(block_at(1, 2))
    assert.becomes_i(block_at(3, 2))
    assert.becomes_swap(block_at(1, 1), 3)
    assert.becomes_swap(block_at(3, 1), 1)
  end)

  -- ┌───┐    ┌───┐
  -- │ X │    │ X │        I        I
  -- ├───┤    ├───┤      ┌───┐    ┌───┐
  -- │ C ├────┤ X │ ───▶ │ C ├────┤ X │
  -- ├───┤    └───┘      └───┘    └───┘
  -- │ X │                 I
  -- └───┘
  it('XX C-X X ─▶ C-X', function()
    put(1, 3, "x")
    put(3, 3, "x")
    put(1, 2, "control", 3)
    put(3, 2, "cnot_x", 1)
    put(1, 1, "x")

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(3, 3))
    assert.is_control(block_at(1, 2), 3)
    assert.is_cnot_x(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐    ┌───┐
  -- │ X │    │ X │        I        I
  -- ├───┤    ├───┤      ┌───┐    ┌───┐
  -- │ X ├────┤ C │ ───▶ │ X ├────┤ C │
  -- └───┘    ├───┤      └───┘    └───┘
  --          │ X │                 I
  --          └───┘
  it('XX X-C X ─▶ X-C', function()
    put(1, 3, "x")
    put(3, 3, "x")
    put(1, 2, "cnot_x", 3)
    put(3, 2, "control", 1)
    put(3, 1, "x")

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(3, 3))
    assert.is_cnot_x(block_at(1, 2), 3)
    assert.is_control(block_at(3, 2), 1)
    assert.becomes_i(block_at(3, 1))
  end)

  -- ┌───┐    ┌───┐
  -- │ Y │    │ X │        I        I
  -- ├───┤    ├───┤      ┌───┐    ┌───┐
  -- │ C ├────┤ X │ ───▶ │ C ├────┤ X │
  -- ├───┤    └───┘      └───┘    └───┘
  -- │ Y │                 I
  -- └───┘
  it('YX C-X Y ─▶ C-X', function()
    put(1, 3, "y")
    put(3, 3, "x")
    put(1, 2, "control", 3)
    put(3, 2, "cnot_x", 1)
    put(1, 1, "y")

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(3, 3))
    assert.is_control(block_at(1, 2), 3)
    assert.is_cnot_x(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐    ┌───┐
  -- │ X │    │ Y │        I        I
  -- ├───┤    ├───┤      ┌───┐    ┌───┐
  -- │ X ├────┤ C │ ───▶ │ X ├────┤ C │
  -- └───┘    ├───┤      └───┘    └───┘
  --          │ Y │                 I
  --          └───┘
  it('XY X-C Y ─▶ X-C', function()
    put(1, 3, "x")
    put(3, 3, "y")
    put(1, 2, "cnot_x", 3)
    put(3, 2, "control", 1)
    put(3, 1, "y")

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(3, 3))
    assert.is_cnot_x(block_at(1, 2), 3)
    assert.is_control(block_at(3, 2), 1)
    assert.becomes_i(block_at(3, 1))
  end)

  -- ┌───┐    ┌───┐
  -- │ Y │    │ Z │        I        I
  -- ├───┤    ├───┤      ┌───┐    ┌───┐
  -- │ X ├────┤ C │ ───▶ │ X ├────┤ C │
  -- ├───┤    └───┘      └───┘    └───┘
  -- │ Y │                 I
  -- └───┘
  it('YZ X-C Y ─▶ X-C', function()
    put(1, 3, "y")
    put(3, 3, "z")
    put(1, 2, "cnot_x", 3)
    put(3, 2, "control", 1)
    put(1, 1, "y")

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(3, 3))
    assert.is_cnot_x(block_at(1, 2), 3)
    assert.is_control(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐    ┌───┐
  -- │ Z │    │ Y │        I        I
  -- ├───┤    ├───┤      ┌───┐    ┌───┐
  -- │ C ├────┤ X │ ───▶ │ C ├────┤ X │
  -- └───┘    ├───┤      └───┘    └───┘
  --          │ Y │                 I
  --          └───┘
  it('ZY C-X Y ─▶ C-X', function()
    put(1, 3, "z")
    put(3, 3, "y")
    put(1, 2, "control", 3)
    put(3, 2, "cnot_x", 1)
    put(3, 1, "y")

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(3, 3))
    assert.is_control(block_at(1, 2), 3)
    assert.is_cnot_x(block_at(3, 2), 1)
    assert.becomes_i(block_at(3, 1))
  end)

  -- ┌───┐    ┌───┐
  -- │ Z │    │ Z │        I        I
  -- ├───┤    ├───┤      ┌───┐    ┌───┐
  -- │ C ├────┤ X │ ───▶ │ C ├────┤ X │
  -- └───┘    ├───┤      └───┘    └───┘
  --          │ Z │                 I
  --          └───┘
  it('ZZ C-X Z ─▶ C-X', function()
    put(1, 3, "z")
    put(3, 3, "z")
    put(1, 2, "control", 3)
    put(3, 2, "cnot_x", 1)
    put(3, 1, "z")

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(3, 3))
    assert.is_control(block_at(1, 2), 3)
    assert.is_cnot_x(block_at(3, 2), 1)
    assert.becomes_i(block_at(3, 1))
  end)

  -- ┌───┐    ┌───┐
  -- │ Z │    │ Z │        I        I
  -- ├───┤    ├───┤      ┌───┐    ┌───┐
  -- │ X ├────┤ C │ ───▶ │ X ├────┤ C │
  -- ├───┤    └───┘      └───┘    └───┘
  -- │ Z │                 I
  -- └───┘
  it('ZZ X-C Z ─▶ X-C', function()
    put(1, 3, "z")
    put(3, 3, "z")
    put(1, 2, "cnot_x", 3)
    put(3, 2, "control", 1)
    put(1, 1, "z")

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(3, 3))
    assert.is_cnot_x(block_at(1, 2), 3)
    assert.is_control(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
  end)

  --          ┌───┐
  --          │ X │                 I
  -- ┌───┐    ├───┤      ┌───┐    ┌───┐
  -- │ C ├────┤ X │ ───▶ │ C ├────┤ X │
  -- └───┘    ├───┤      └───┘    └───┘
  --          │ X │                 I
  --          └───┘
  it('X C-X X ─▶ C-X', function()
    put(3, 3, "x")
    put(1, 2, "control", 3)
    put(3, 2, "cnot_x", 1)
    put(3, 1, "x")

    reduce_blocks()

    assert.becomes_i(block_at(3, 3))
    assert.is_control(block_at(1, 2), 3)
    assert.is_cnot_x(block_at(3, 2), 1)
    assert.becomes_i(block_at(3, 1))
  end)

  -- ┌───┐
  -- │ X │                 I
  -- ├───┤    ┌───┐      ┌───┐    ┌───┐
  -- │ X ├────┤ C │ ───▶ │ X ├────┤ C │
  -- ├───┤    └───┘      └───┘    └───┘
  -- │ X │                 I
  -- └───┘
  it('X X-C X ─▶ X-C', function()
    put(1, 3, "x")
    put(1, 2, "cnot_x", 3)
    put(3, 2, "control", 1)
    put(1, 1, "x")

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.is_cnot_x(block_at(1, 2), 3)
    assert.is_control(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ Z │                 I
  -- ├───┤    ┌───┐      ┌───┐    ┌───┐
  -- │ C ├────┤ X │ ───▶ │ C ├────┤ X │
  -- ├───┤    └───┘      └───┘    └───┘
  -- │ Z │                 I
  -- └───┘
  it('Z C-X Z ─▶ C-X', function()
    put(1, 3, "z")
    put(1, 2, "control", 3)
    put(3, 2, "cnot_x", 1)
    put(1, 1, "z")

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.is_control(block_at(1, 2), 3)
    assert.is_cnot_x(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
  end)

  --          ┌───┐
  --          │ Z │                 I
  -- ┌───┐    ├───┤      ┌───┐    ┌───┐
  -- │ X ├────┤ C │ ───▶ │ X ├────┤ C │
  -- └───┘    ├───┤      └───┘    └───┘
  --          │ Z │                 I
  --          └───┘
  it('Z X-C Z ─▶ X-C', function()
    put(3, 3, "z")
    put(1, 2, "cnot_x", 3)
    put(3, 2, "control", 1)
    put(3, 1, "z")

    reduce_blocks()

    assert.becomes_i(block_at(3, 3))
    assert.is_cnot_x(block_at(1, 2), 3)
    assert.is_control(block_at(3, 2), 1)
    assert.becomes_i(block_at(3, 1))
  end)

  -- ┌───┐    ┌───┐
  -- │ S ├────┤ S │        I   I
  -- ├───┤    ├───┤ ───▶
  -- │ S ├────┤ S │        I   I
  -- └───┘    └───┘
  it('X-X X-X ─▶ I', function()
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(1, 1, "swap", 3)
    put(3, 1, "swap", 1)

    reduce_blocks()

    assert.becomes_i(block_at(1, 2))
    assert.becomes_i(block_at(3, 2))
    assert.becomes_i(block_at(1, 1))
    assert.becomes_i(block_at(3, 1))
  end)

  -- ┌───┐
  -- │ H │                 I
  -- ├───┤               ┌───┐
  -- │ Z │               │ X │
  -- ├───┤    ┌───┐      ├───┤    ┌───┐
  -- │ S ├────┤ S │ ───▶ │ S ├────┤ S │
  -- └───┘    ├───┤      └───┘    └───┘
  --          │ H │                 I
  --          └───┘
  it('HZ X-X H ─▶ X X-X', function()
    put(1, 4, "h")
    put(1, 3, "z")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(3, 1, "h")

    reduce_blocks()

    assert.becomes_i(block_at(1, 4))
    assert.becomes_x(block_at(1, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(3, 1))
  end)

  --          ┌───┐
  --          │ H │                 I
  --          ├───┤               ┌───┐
  --          │ Z │               │ X │
  -- ┌───┐    ├───┤      ┌───┐    ├───┤
  -- │ S ├────┤ S │ ───▶ │ S ├────┤ S │
  -- ├───┤    └───┘      └───┘    └───┘
  -- │ H │                 I
  -- └───┘
  it('HZ X-X H ─▶ X X-X (左右反転)', function()
    put(3, 4, "h")
    put(3, 3, "z")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(1, 1, "h")

    reduce_blocks()

    assert.becomes_i(block_at(3, 4))
    assert.becomes_x(block_at(3, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ S │                 I
  -- ├───┤               ┌───┐
  -- │ Z │               │ Z │
  -- ├───┤    ┌───┐      ├───┤    ┌───┐
  -- │ S ├────┤ S │ ───▶ │ S ├────┤ S │
  -- └───┘    ├───┤      └───┘    └───┘
  --          │ S │                 I
  --          └───┘
  it('SZ X-X S ─▶ Z X-X', function()
    put(1, 4, "s")
    put(1, 3, "z")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(3, 1, "s")

    reduce_blocks()

    assert.becomes_i(block_at(1, 4))
    assert.becomes_z(block_at(1, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(3, 1))
  end)

  --          ┌───┐
  --          │ S │                 I
  --          ├───┤               ┌───┐
  --          │ Z │               │ Z │
  -- ┌───┐    ├───┤      ┌───┐    ├───┤
  -- │ S ├────┤ S │ ───▶ │ S ├────┤ S │
  -- ├───┤    └───┘      └───┘    └───┘
  -- │ S │                 I
  -- └───┘
  it('SZ X-X S ─▶ Z X-X (左右反転)', function()
    put(3, 4, "s")
    put(3, 3, "z")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(1, 1, "s")

    reduce_blocks()

    assert.becomes_i(block_at(3, 4))
    assert.becomes_z(block_at(3, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐               ┌───┐
  -- │ S │               │ Z │
  -- ├───┤    ┌───┐      ├───┤    ┌───┐
  -- │ S ├────┤ S │ ───▶ │ S ├────┤ S │
  -- └───┘    ├───┤      └───┘    └───┘
  --          │ Z │                 I
  --          ├───┤
  --          │ S │                 I
  --          └───┘
  it('S X-X ZS ─▶ Z X-X', function()
    put(1, 4, "s")
    put(1, 3, "swap", 3)
    put(3, 3, "swap", 1)
    put(3, 2, "z")
    put(3, 1, "s")

    reduce_blocks()

    assert.becomes_z(block_at(1, 4))
    assert.is_swap(block_at(1, 3), 3)
    assert.is_swap(block_at(3, 3), 1)
    assert.becomes_i(block_at(3, 2))
    assert.becomes_i(block_at(3, 1))
  end)

  --          ┌───┐               ┌───┐
  --          │ S │               │ Z │
  -- ┌───┐    ├───┤      ┌───┐    ├───┤
  -- │ S ├────┤ S │ ───▶ │ S ├────┤ S │
  -- ├───┤    └───┘      └───┘    └───┘
  -- │ Z │                 I
  -- ├───┤
  -- │ S │                 I
  -- └───┘
  it('S X-X ZS ─▶ Z X-X (左右反転)', function()
    put(3, 4, "s")
    put(1, 3, "swap", 3)
    put(3, 3, "swap", 1)
    put(1, 2, "z")
    put(1, 1, "s")

    reduce_blocks()

    assert.becomes_z(block_at(3, 4))
    assert.is_swap(block_at(1, 3), 3)
    assert.is_swap(block_at(3, 3), 1)
    assert.becomes_i(block_at(1, 2))
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ T │                 I
  -- ├───┤               ┌───┐
  -- │ S │               │ Z │
  -- ├───┤    ┌───┐      ├───┤    ┌───┐
  -- │ S ├────┤ S │ ───▶ │ S ├────┤ S │
  -- └───┘    ├───┤      └───┘    └───┘
  --          │ T │                 I
  --          └───┘
  it('TS X-X T ─▶ Z X-X', function()
    put(1, 4, "t")
    put(1, 3, "s")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(3, 1, "t")

    reduce_blocks()

    assert.becomes_i(block_at(1, 4))
    assert.becomes_z(block_at(1, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(3, 1))
  end)

  --          ┌───┐
  --          │ T │                 I
  --          ├───┤               ┌───┐
  --          │ S │               │ Z │
  -- ┌───┐    ├───┤      ┌───┐    ├───┤
  -- │ S ├────┤ S │ ───▶ │ S ├────┤ S │
  -- ├───┤    └───┘      └───┘    └───┘
  -- │ T │                 I
  -- └───┘
  it('TS X-X T ─▶ Z X-X (左右反転)', function()
    put(3, 4, "t")
    put(3, 3, "s")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(1, 1, "t")

    reduce_blocks()

    assert.becomes_i(block_at(3, 4))
    assert.becomes_z(block_at(3, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐               ┌───┐
  -- │ T │               │ Z │
  -- ├───┤    ┌───┐      ├───┤    ┌───┐
  -- │ S ├────┤ S │ ───▶ │ S ├────┤ S │
  -- └───┘    ├───┤      └───┘    └───┘
  --          │ S │                 I
  --          ├───┤
  --          │ T │                 I
  --          └───┘
  it('T X-X ST ─▶ Z X-X', function()
    put(1, 4, "t")
    put(1, 3, "swap", 3)
    put(3, 3, "swap", 1)
    put(3, 2, "s")
    put(3, 1, "t")

    reduce_blocks()

    assert.becomes_z(block_at(1, 4))
    assert.is_swap(block_at(1, 3), 3)
    assert.is_swap(block_at(3, 3), 1)
    assert.becomes_i(block_at(3, 2))
    assert.becomes_i(block_at(3, 1))
  end)

  --          ┌───┐               ┌───┐
  --          │ T │               │ Z │
  -- ┌───┐    ├───┤      ┌───┐    ├───┤
  -- │ S ├────┤ S │ ───▶ │ S ├────┤ S │
  -- ├───┤    └───┘      └───┘    └───┘
  -- │ S │                 I
  -- ├───┤
  -- │ T │                 I
  -- └───┘
  it('T X-X ST ─▶ Z X-X (左右反転)', function()
    put(3, 4, "t")
    put(1, 3, "swap", 3)
    put(3, 3, "swap", 1)
    put(1, 2, "s")
    put(1, 1, "t")

    reduce_blocks()

    assert.becomes_z(block_at(3, 4))
    assert.is_swap(block_at(1, 3), 3)
    assert.is_swap(block_at(3, 3), 1)
    assert.becomes_i(block_at(1, 2))
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ T │                 I
  -- ├───┤    ┌───┐      ┌───┐    ┌───┐
  -- │ S ├────┤ S │ ───▶ │ S ├────┤ S │
  -- └───┘    ├───┤      └───┘    └───┘
  --          │ Z │                 I
  --          ├───┤
  --          │ S │                 I
  --          ├───┤
  --          │ T │                 I
  --          └───┘
  it('T X-X ZST ─▶ X-X', function()
    put(1, 5, "t")
    put(1, 4, "swap", 3)
    put(3, 4, "swap", 1)
    put(3, 3, "z")
    put(3, 2, "s")
    put(3, 1, "t")

    reduce_blocks()

    assert.becomes_i(block_at(1, 5))
    assert.is_swap(block_at(1, 4), 3)
    assert.is_swap(block_at(3, 4), 1)
    assert.becomes_i(block_at(3, 3))
    assert.becomes_i(block_at(3, 2))
    assert.becomes_i(block_at(3, 1))
  end)

  --          ┌───┐
  --          │ T │                 I
  -- ┌───┐    ├───┤      ┌───┐    ┌───┐
  -- │ S ├────┤ S │ ───▶ │ S ├────┤ S │
  -- ├───┤    └───┘      └───┘    └───┘
  -- │ Z │                 I
  -- ├───┤
  -- │ S │                 I
  -- ├───┤
  -- │ T │                 I
  -- └───┘
  it('T X-X ZST ─▶ X-X (左右反転)', function()
    put(3, 5, "t")
    put(1, 4, "swap", 3)
    put(3, 4, "swap", 1)
    put(1, 3, "z")
    put(1, 2, "s")
    put(1, 1, "t")

    reduce_blocks()

    assert.becomes_i(block_at(3, 5))
    assert.is_swap(block_at(1, 4), 3)
    assert.is_swap(block_at(3, 4), 1)
    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(1, 2))
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ T │                 I
  -- ├───┤
  -- │ Z │                 I
  -- ├───┤    ┌───┐      ┌───┐    ┌───┐
  -- │ S ├────┤ S │ ───▶ │ S ├────┤ S │
  -- └───┘    ├───┤      └───┘    └───┘
  --          │ S │                 I
  --          ├───┤
  --          │ T │                 I
  --          └───┘
  it('TZ X-X ST ─▶ X-X', function()
    put(1, 5, "t")
    put(1, 4, "z")
    put(1, 3, "swap", 3)
    put(3, 3, "swap", 1)
    put(3, 2, "s")
    put(3, 1, "t")

    reduce_blocks()

    assert.becomes_i(block_at(1, 5))
    assert.becomes_i(block_at(1, 4))
    assert.is_swap(block_at(1, 3), 3)
    assert.is_swap(block_at(3, 3), 1)
    assert.becomes_i(block_at(3, 2))
    assert.becomes_i(block_at(3, 1))
  end)

  --          ┌───┐
  --          │ T │                 I
  --          ├───┤
  --          │ Z │                 I
  -- ┌───┐    ├───┤      ┌───┐    ┌───┐
  -- │ S ├────┤ S │ ───▶ │ S ├────┤ S │
  -- ├───┤    └───┘      └───┘    └───┘
  -- │ S │                 I
  -- ├───┤
  -- │ T │                 I
  -- └───┘
  it('TZ X-X ST ─▶ X-X (左右反転)', function()
    put(3, 5, "t")
    put(3, 4, "z")
    put(1, 3, "swap", 3)
    put(3, 3, "swap", 1)
    put(1, 2, "s")
    put(1, 1, "t")

    reduce_blocks()

    assert.becomes_i(block_at(3, 5))
    assert.becomes_i(block_at(3, 4))
    assert.is_swap(block_at(1, 3), 3)
    assert.is_swap(block_at(3, 3), 1)
    assert.becomes_i(block_at(1, 2))
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐
  -- │ T │                 I
  -- ├───┤    ┌───┐      ┌───┐    ┌───┐
  -- │ S ├────┤ S │ ───▶ │ S ├────┤ S │
  -- └───┘    ├───┤      └───┘    └───┘
  --          │ S │                 I
  --          ├───┤
  --          │ Z │                 I
  --          ├───┤
  --          │ T │                 I
  --          └───┘
  it('T X-X SZT ─▶ X-X', function()
    put(1, 5, "t")
    put(1, 4, "swap", 3)
    put(3, 4, "swap", 1)
    put(3, 3, "s")
    put(3, 2, "z")
    put(3, 1, "t")

    reduce_blocks()

    assert.becomes_i(block_at(1, 5))
    assert.is_swap(block_at(1, 4), 3)
    assert.is_swap(block_at(3, 4), 1)
    assert.becomes_i(block_at(3, 3))
    assert.becomes_i(block_at(3, 2))
    assert.becomes_i(block_at(3, 1))
  end)


  --          ┌───┐
  --          │ T │                 I
  -- ┌───┐    ├───┤      ┌───┐    ┌───┐
  -- │ S ├────┤ S │ ───▶ │ S ├────┤ S │
  -- ├───┤    └───┘      └───┘    └───┘
  -- │ S │                 I
  -- ├───┤
  -- │ Z │                 I
  -- ├───┤
  -- │ T │                 I
  -- └───┘
  it('T X-X SZT ─▶ X-X (左右反転)', function()
    put(3, 5, "t")
    put(1, 4, "swap", 3)
    put(3, 4, "swap", 1)
    put(1, 3, "s")
    put(1, 2, "z")
    put(1, 1, "t")

    reduce_blocks()

    assert.becomes_i(block_at(3, 5))
    assert.is_swap(block_at(1, 4), 3)
    assert.is_swap(block_at(3, 4), 1)
    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(1, 2))
    assert.becomes_i(block_at(1, 1))
  end)

  --          ┌───┐
  --          │ T │                 I
  --          ├───┤
  --          │ Z │                 I
  --          ├───┤
  --          │ S │                 I
  -- ┌───┐    ├───┤      ┌───┐    ┌───┐
  -- │ S ├────┤ S │ ───▶ │ S ├────┤ S │
  -- ├───┤    └───┘      └───┘    └───┘
  -- │ T │                 I
  -- └───┘
  it('TZS X-X T ─▶ X-X (左右反転)', function()
    put(3, 5, "t")
    put(3, 4, "z")
    put(3, 3, "s")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(1, 1, "t")

    reduce_blocks()

    assert.becomes_i(block_at(3, 5))
    assert.becomes_i(block_at(3, 4))
    assert.becomes_i(block_at(3, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐    ┌───┐      ┌───┐
  -- │ H │    │ Z │      │ H │      I
  -- ├───┤    ├───┤      ├───┤    ┌───┐
  -- │ X ├────┤ C │ ───▶ │ X ├────┤ C │
  -- ├───┤    ├───┤      ├───┤    └───┘
  -- │ H │    │ Z │      │ H │      I
  -- └───┘    └───┘      └───┘
  it('HZ X-C HZ ─▶ H X-C H', function()
    put(1, 3, "h")
    put(3, 3, "z")
    put(1, 2, "cnot_x", 3)
    put(3, 2, "control", 1)
    put(1, 1, "h")
    put(3, 1, "z")

    reduce_blocks()

    assert.is_h(block_at(1, 3))
    assert.becomes_i(block_at(3, 3))
    assert.is_cnot_x(block_at(1, 2), 3)
    assert.is_control(block_at(3, 2), 1)
    assert.is_h(block_at(1, 1))
    assert.becomes_i(block_at(3, 1))
  end)

  -- ┌───┐
  -- │ T │                 I
  -- ├───┤
  -- │ Z │                 I
  -- ├───┤
  -- │ S │                 I
  -- ├───┤    ┌───┐      ┌───┐    ┌───┐
  -- │ S ├────┤ S │ ───▶ │ S ├────┤ S │
  -- └───┘    ├───┤      └───┘    └───┘
  --          │ T │                 I
  --          └───┘
  it('TZS X-X T ─▶ X-X', function()
    put(1, 5, "t")
    put(1, 4, "z")
    put(1, 3, "s")
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(3, 1, "t")

    reduce_blocks()

    assert.becomes_i(block_at(1, 5))
    assert.becomes_i(block_at(1, 4))
    assert.becomes_i(block_at(1, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(3, 1))
  end)

  -- ┌───┐    ┌───┐               ┌───┐
  -- │ Z │    │ H │        I      │ H │
  -- ├───┤    ├───┤      ┌───┐    ├───┤
  -- │ C ├────┤ X │ ───▶ │ C ├────┤ X │
  -- ├───┤    ├───┤      └───┘    ├───┤
  -- │ Z │    │ H │        I      │ H │
  -- └───┘    └───┘               └───┘
  it('HZ X-C HZ ─▶ H X-C H (左右反転)', function()
    put(3, 3, "h")
    put(1, 3, "z")
    put(3, 2, "cnot_x", 1)
    put(1, 2, "control", 3)
    put(3, 1, "h")
    put(1, 1, "z")

    reduce_blocks()

    assert.is_h(block_at(3, 3))
    assert.becomes_i(block_at(1, 3))
    assert.is_cnot_x(block_at(3, 2), 1)
    assert.is_control(block_at(1, 2), 3)
    assert.is_h(block_at(3, 1))
    assert.becomes_i(block_at(1, 1))
  end)

  -- ┌───┐    ┌───┐
  -- │ C ├────┤ X │        I        I
  -- ├───┤    ├───┤      ┌───┐    ┌───┐
  -- │ S ├────┤ S │ ───▶ │ S ├────┤ S │
  -- ├───┤    ├───┤      └───┘    └───┘
  -- │ X ├────┤ C │        I        I
  -- └───┘    └───┘
  it('C-X X-X X-C ─▶ X-X', function()
    put(1, 3, "control", 3)
    put(3, 3, "cnot_x", 1)
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(1, 1, "cnot_x", 3)
    put(3, 1, "control", 1)

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(3, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
    assert.becomes_i(block_at(3, 1))
  end)

  -- ┌───┐    ┌───┐
  -- │ X ├────┤ C │        I        I
  -- ├───┤    ├───┤      ┌───┐    ┌───┐
  -- │ S ├────┤ S │ ───▶ │ S ├────┤ S │
  -- ├───┤    ├───┤      └───┘    └───┘
  -- │ C ├────┤ X │        I        I
  -- └───┘    └───┘
  it('X-C X-X C-X ─▶ X-X', function()
    put(1, 3, "cnot_x", 3)
    put(3, 3, "control", 1)
    put(1, 2, "swap", 3)
    put(3, 2, "swap", 1)
    put(1, 1, "control", 3)
    put(3, 1, "cnot_x", 1)

    reduce_blocks()

    assert.becomes_i(block_at(1, 3))
    assert.becomes_i(block_at(3, 3))
    assert.is_swap(block_at(1, 2), 3)
    assert.is_swap(block_at(3, 2), 1)
    assert.becomes_i(block_at(1, 1))
    assert.becomes_i(block_at(3, 1))
  end)
end)
