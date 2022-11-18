---@diagnostic disable: global-in-nil-env

require("gate_class")

function s_gate()
  local s = setmetatable({
  }, { __index = gate_class("s") }):_init()

  return s
end
