---@diagnostic disable: global-in-nil-env

require("gate_class")

function x_gate()
  local x = setmetatable({
  }, { __index = gate_class("x") }):_init()

  return x
end
