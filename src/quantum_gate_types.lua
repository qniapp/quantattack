_gate_types = { h_gate, x_gate, y_gate, z_gate, s_gate, t_gate }

function is_garbage_gate(gate)
  return gate.type == "g"
end

-- gate states

function is_reducible(gate)
  return is_garbage_gate(gate) or
      ((not gate:is_i()) and (not is_busy(gate)))
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

function is_disappearing(gate)
  return gate._state == "disappear"
end

function is_busy(gate)
  return not (gate:is_idle() or gate:is_dropped())
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
