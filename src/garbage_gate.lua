local gate = require("gate")

function garbage_gate(span)
  --#if assert
  assert(span)
  --#endif

  local garbage = gate('g', span)
  garbage._sprite_middle = 87
  garbage._sprite_left = 86
  garbage._sprite_right = 88

  return garbage
end
