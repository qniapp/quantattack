---@diagnostic disable: global-in-nil-env

require("gate_class")

function x_gate()
  local x = setmetatable({
    type = "x",

    is_single_gate = function()
      return true
    end
  }, { __index = gate_class() }):_init()

  return x
end
