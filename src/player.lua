---@diagnostic disable: lowercase-global, global-in-nil-env

require("engine/input/input")

function create_player()
  local player = setmetatable({
    init = function(_ENV)
      steps, score = 0, 0
    end,

    update = function(_ENV)
      left, right, up, down, x, o = btnp(button_ids.left), btnp(button_ids.right),
          btnp(button_ids.up), btnp(button_ids.down), btn(button_ids.x), btnp(button_ids.o)
    end
  }, { __index = _ENV })

  player:init()

  return player
end
