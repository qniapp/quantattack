local gate = require("lib/gate")

function wait_swap_to_finish(board)
  for _i = 1, 1 + gate_swap_animation_frame_count do
    board:update()
  end
end

function i_gate()
  return gate("i")
end

function h_gate()
  return gate("h")
end

function x_gate()
  return gate("x")
end

function y_gate()
  return gate("y")
end

function z_gate()
  return gate("z")
end

function s_gate()
  return gate("s")
end

function t_gate()
  return gate("t")
end

function control_gate(other_x)
  local control = gate('control')
  control.other_x = other_x
  return control
end

function cnot_x_gate(other_x)
  local cnot_x = gate('cnot_x')
  cnot_x.other_x = other_x
  return cnot_x
end

function swap_gate(other_x)
  local swap = gate('swap')
  swap.other_x = other_x
  return swap
end

function garbage_match_gate()
  return gate("!")
end
