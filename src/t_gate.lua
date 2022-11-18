---@diagnostic disable: global-in-nil-env

require("gate_class")

function t_gate()
  local t = setmetatable({
    type = "t",
  }, { __index = gate_class() }):_init()

  return t
end
