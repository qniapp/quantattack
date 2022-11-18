---@diagnostic disable: global-in-nil-env

require("gate_class")

function x_gate()
  local x = setmetatable({
    type = "x",
  }, { __index = gate_class() }):_init()

  return x
end
