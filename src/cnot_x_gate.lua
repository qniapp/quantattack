---@diagnostic disable: global-in-nil-env

require("gate_class")

function cnot_x_gate(other_x)
  local cnot_x = setmetatable({
    other_x = other_x
  }, { __index = gate_class("cnot_x") }):_init()

  return cnot_x
end
