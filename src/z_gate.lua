---@diagnostic disable: global-in-nil-env

require("gate_class")

function z_gate()
  local z = setmetatable({
  }, { __index = gate_class("z") }):_init()

  return z
end
