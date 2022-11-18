---@diagnostic disable: global-in-nil-env

require("gate_class")

function swap_gate(other_x)
  local swap = setmetatable({
    other_x = other_x,
    --#if debug
    type_string = "S",
    --#endif
  }, { __index = gate_class("swap") }):_init()

  return swap
end
