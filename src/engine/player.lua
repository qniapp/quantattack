player = {
  ["min_cnot_probability"] = 0.3,
  ["max_cnot_probability"] = 0.7,
  ["steps_to_increase_cnot_probability"] = 5,
  ["steps"] = 0,
  ["score"] = 0,

  cnot_probability = function(self)
    local p = self.min_cnot_probability +
              flr(self.steps / self.steps_to_increase_cnot_probability) * 0.1

    if p <= self.max_cnot_probability then
      return p
    else
      return self.max_cnot_probability
    end
  end,
}

return player
