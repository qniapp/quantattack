_gate_types = {h_gate, x_gate, y_gate, z_gate, s_gate, t_gate}

function random_gate()
  return _gate_types[flr(rnd(#_gate_types)) + 1]:new()
end