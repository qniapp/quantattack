---@diagnostic disable: undefined-global

cartdata("quantattack_0_7_4")

high_score_class = new_class()

function high_score_class:_init(id)
  self.id = id
end

function high_score_class:get()
  return dget(self.id) or 0
end

function high_score_class:put(score)
  if self:get() < score then
    dset(self.id, score)
    return true
  end

  return false
end
