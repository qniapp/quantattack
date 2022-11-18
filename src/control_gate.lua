---@diagnostic disable: global-in-nil-env

require("gate_class")

function control_gate(other_x)
  local control = setmetatable({
    type = "control",
    other_x = other_x
  }, { __index = gate_class() }):_init()

  return control
end
