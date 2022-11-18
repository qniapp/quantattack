---@diagnostic disable: global-in-nil-env

require("gate_class")

function s_gate()
  local s = setmetatable({
    type = "s",

    is_single_gate = function()
      return true
    end
  }, { __index = gate_class() }):_init()

  return s
end
