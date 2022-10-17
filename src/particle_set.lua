require("engine/core/class")

local puff_particle = require("puff_particle")
local particle_set = new_class()

-- x, y, に data で指定した particle のセットを作る
--
-- data のフォーマット:
-- "radius,color|radius,color|..."
function particle_set:_init(x, y, data)
  for _, particle_data in pairs(split(data, "|")) do
    ---@diagnostic disable-next-line: deprecated
    puff_particle(x, y, unpack(split(particle_data)))
  end
end

return particle_set
