---@diagnostic disable: global-in-nil-env, lowercase-global

local player = new_class()

function player._init(_ENV)
  steps, score = 0, 0
end

function player.update(_ENV)
  left, right, up, down, x, o = btnp(0), btnp(1), btnp(2), btnp(3), btnp(5), btn(4)
end

return player
