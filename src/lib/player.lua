---@diagnostic disable: lowercase-global, global-in-nil-env

function create_player()
  local player = setmetatable({
    init = function(_ENV)
      steps, score = 0, 0
    end,

    update = function(_ENV)
      left, right, up, down, x, o = btnp(0), btnp(1), btnp(2), btnp(3), btnp(5), btn(4)
    end
  }, { __index = _ENV })

  player:init()

  return player
end
