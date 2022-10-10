require("engine/core/class")

local quantum_gate = require("quantum_gate")
local control_gate = derived_class(quantum_gate)

function control_gate:_init(cnot_x_x)
  assert(cnot_x_x)

  quantum_gate._init(self, 'control')
  self.cnot_x_x = cnot_x_x
  self._sprites = {
    idle = 6,
    jumping = 54,
    falling = 38,
    match_up = 14,
    match_middle = 30,
    match_down = 46
  }
end

function control_gate:before_update(self)
  if self.tick_connection == nil then
    self.tick_connection = 0
    if self.connection == nil then
      self.connection = flr(rnd(2)) == 0
    end
    if self.connection then
      self.connection_duration = flr(rnd(5)) * 30
    else
      self.connection_duration = flr(rnd(5)) + 5
    end
  elseif self.tick_connection == self.connection_duration then
    self.tick_connection = nil
    self.connection = not self.connection
  else
    self.tick_connection = self.tick_connection + 1
  end
end

return control_gate
