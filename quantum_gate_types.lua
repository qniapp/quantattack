_gate_types = {h_gate, x_gate, y_gate, z_gate, s_gate, t_gate}

function is_i(gate)      
  return gate._type == "i"
end

function is_h(gate)
  return gate._type == "h"
end

function is_x(gate)
  return gate._type == "x"
end

function is_cnot_x(gate)
  return gate._type == "cnot_x"
end

function is_y(gate)
  return gate._type == "y"
end

function is_z(gate)
  return gate._type == "z"
end

function is_s(gate)
  return gate._type == "s"
end

function is_t(gate)
  return gate._type == "t"
end

function is_control(gate)
  return gate._type == "control"
end

function is_swap(gate)
  return gate._type == "swap"
end

function is_garbage_unitary(gate)
  return gate._type == "garbage"
end

-- gate states

function is_idle(gate)
  return gate._state == "idle"
end

function is_reducible(gate)
  return is_garbage_unitary(gate) or
         ((not is_i(gate)) and (not is_busy(gate)))
end

function is_swapping(gate)
  return is_swapping_with_left(gate) or is_swapping_with_right(gate)
end

function is_swapping_with_left(gate)
  return gate._state == "swapping_with_left"
end

function is_swapping_with_right(gate)
  return gate._state == "swapping_with_right"
end

function is_match(gate)
  return gate._state == "match"
end

function is_dropped(gate)
  return gate._state == "dropped"
end

function is_disappearing(gate)
  return gate._state == "disappear"
end

function is_busy(gate)
  return not (is_idle(gate) or is_dropped(gate))
end

function is_match_type_i(gate)
  return gate.match_type == "hh" or
         gate.match_type == "xx" or
         gate.match_type == "yy" or
         gate.match_type == "zz" or
         gate.match_type == "swap swap"
end

function random_gate()
  return _gate_types[flr(rnd(#_gate_types)) + 1]:new()
end