---@diagnostic disable: undefined-global

cartdata("quantattack_0_2_0")

local high_score = new_class()

function high_score:_init(id)
  self.id = id
end

function high_score:get()
  return dget(self.id) or 0
end

function high_score:put(score)
  if self:get() < score then
    dset(self.id, score)
    return true
  end

  return false
end

return high_score
