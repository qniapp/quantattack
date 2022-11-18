---@diagnostic disable: global-in-nil-env

require("gate_class")

function y_gate()
  local y = setmetatable({
  }, { __index = gate_class("y") }):_init()

  return y
end
