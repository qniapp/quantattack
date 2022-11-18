---@diagnostic disable: global-in-nil-env

require("gate_class")

function z_gate()
  local z = setmetatable({
    type = "z",
  }, { __index = gate_class() }):_init()

  return z
end
