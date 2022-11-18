---@diagnostic disable: global-in-nil-env

require("gate_class")

function t_gate()
  local t = setmetatable({
  }, { __index = gate_class("t") }):_init()

  return t
end
