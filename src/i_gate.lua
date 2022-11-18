---@diagnostic disable: global-in-nil-env, lowercase-global, unbalanced-assignments

require("gate_class")

function i_gate()
  local i = setmetatable({
    --#if debug
    type_string = "_",
    --#endif

    is_empty = function(_ENV)
      return not is_swapping(_ENV)
    end,

    is_fallable = function()
      return false
    end,

    is_reducible = function()
      return false
    end
  }, { __index = gate_class("i") }):_init()

  return i
end
