---@diagnostic disable: global-in-nil-env

require("gate_class")

function h_gate()
  local h = setmetatable({
    type = "h",
  }, { __index = gate_class() }):_init()

  return h
end
