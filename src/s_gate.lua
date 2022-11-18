---@diagnostic disable: global-in-nil-env

require("gate_class")

function s_gate()
  local s = setmetatable({
    type = "s",
  }, { __index = gate_class() }):_init()

  return s
end
