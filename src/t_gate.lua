---@diagnostic disable: global-in-nil-env

require("gate_class")

function t_gate()
  local t = setmetatable({
    type = "t",

    is_single_gate = function()
      return true
    end
  }, { __index = gate_class() }):_init()

  return t
end
