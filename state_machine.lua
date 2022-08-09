-- state-machines-st -------------------------------------------------------
-- copyright (c) 2021 jason delaat
-- mit license: https://github.com/jasondelaat/pico8-tools/blob/release/license
----------------------------------------------------------------------------
-- simple state machine manager with setup and teardown functions.
-- token count: 111
------------------------------------------------------------------------
state_machine = {}

function state_machine:new()
   return {
      _current_state=nil,
      add_state=state_machine.add_state,
      set_state=state_machine.set_state,
      get_state=state_machine.get_state,
      update=state_machine.update
   }
end

function state_machine:add_state(name, transition, setup, teardown)
   self[name] = {transition=transition, setup=setup, teardown=teardown}
end

function state_machine:set_state(name)
   if self._current_state == nil then
      self[name].setup()
   end
   self._current_state = name
end

function state_machine:get_state()
   return self[self._current_state]
end

function state_machine:update()
   local state = self:get_state()
   local new_state = state.transition()
   if new_state != self._current_state then
      state.teardown()
      self:set_state(new_state)
      self:get_state().setup()
   end
end