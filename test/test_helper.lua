require("lib/helpers")
require("lib/board")

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function wait_swap_to_finish(board)
  for _ = 1, block_class.block_swap_animation_frame_count + 1 do
    board:update()
  end
end

function control_block(other_x)
  local control = block_class("control")
  control.other_x = other_x
  return control
end

function cnot_x_block(other_x)
  local cnot_x = block_class("cnot_x")
  cnot_x.other_x = other_x
  return cnot_x
end

function swap_block(other_x)
  local swap = block_class("swap")
  swap.other_x = other_x
  return swap
end
