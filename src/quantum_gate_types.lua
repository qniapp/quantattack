_gate_types = { h_gate, x_gate, y_gate, z_gate, s_gate, t_gate }

-- gate states

function is_reducible(gate)
  return gate:is_garbage_gate() or
      ((not gate:is_i()) and (not gate:is_busy()))
end

function is_disappearing(gate)
  return gate._state == "disappear"
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
