local gate = require("gate")

function wait_swap_to_finish(board)
  for _i = 1, 1 + gate.swap_animation_frame_count do
    board:update()
  end
end
