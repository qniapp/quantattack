-- state-machines-du -------------------------------------------------------
-- copyright (c) 2021 jason delaat
-- mit license: https://github.com/jasondelaat/pico8-tools/blob/release/license
----------------------------------------------------------------------------
-- simple state machine manager with draw and update functions.
-- token count: 107
------------------------------------------------------------------------
state_machine = {}

function state_machine:new()
  return {
    _current_state=nil,
    add_state=state_machine.add_state,
    set_state=state_machine.set_state,
    get_state=state_machine.get_state,
    update=state_machine.update,
    draw=state_machine.draw
  }
end

function state_machine:add_state(name, transition, update, draw)
  self[name] = {transition=transition, update=update, draw=draw}
end

function state_machine:set_state(name)
  self._current_state = name
end

function state_machine:get_state()
  return self[self._current_state]
end

function state_machine:update(obj)
  local new_state = self:get_state().transition(obj)
  if new_state != self._current_state then
     self:set_state(new_state)
  end
  self:get_state().update(obj)
end

function state_machine:draw(obj)
  self:get_state().draw(obj)
end