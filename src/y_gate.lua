---@diagnostic disable: global-in-nil-env

require("gate_class")

function y_gate()
  local y = setmetatable({
    type = "y",
  }, { __index = gate_class() }):_init()

  return y
end
