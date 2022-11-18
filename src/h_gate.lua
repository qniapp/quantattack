---@diagnostic disable: global-in-nil-env

require("gate_class")

function h_gate()
  local h = setmetatable({
  }, { __index = gate_class("h") }):_init()

  return h
end
