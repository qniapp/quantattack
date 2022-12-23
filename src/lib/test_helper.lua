local block = require("lib/block")

function wait_swap_to_finish(board)
  for _i = 1, 1 + block.block_swap_animation_frame_count do
    board:update()
  end
end

function y_block()
  return block("y")
end

function z_block()
  return block("z")
end

function s_block()
  return block("s")
end

function t_block()
  return block("t")
end

function control_block(other_x)
  local control = block('control')
  control.other_x = other_x
  return control
end

function cnot_x_block(other_x)
  local cnot_x = block('cnot_x')
  cnot_x.other_x = other_x
  return cnot_x
end

function swap_block(other_x)
  local swap = block('swap')
  swap.other_x = other_x
  return swap
end

function garbage_match_block()
  return block("?")
end
