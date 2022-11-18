---@diagnostic disable: global-in-nil-env

require("gate_class")

function garbage_match_gate(other_x)
  local garbage_match = setmetatable({
    type = "!",

    is_fallable = function()
      return false
    end,

    is_reducible = function()
      return false
    end
  }, { __index = gate_class() }):_init()

  return garbage_match
end
