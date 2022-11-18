require("gate_class")

function wait_swap_to_finish(board)
  for _i = 1, 1 + gate_swap_animation_frame_count do
    board:update()
  end
end

function h_gate()
  return gate_class("h")
end

function x_gate()
  return gate_class("x")
end
