require("particle")

-- x, y, に data で指定した particle のセットを作る
--
-- data のフォーマット:
-- "radius,color|radius,color|..."
function create_particle_set(x, y, data)
  for _, particle_data in pairs(split(data, "|")) do
    ---@diagnostic disable-next-line: deprecated
    create_particle(x, y, unpack(split(particle_data)))
  end
end
