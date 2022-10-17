local gate = require("gate")

function garbage_gate(span)
  --#if assert
  assert(span)
  --#endif

  local garbage = gate('g', span)
  garbage._sprite_middle = 83
  garbage._sprite_left = 82
  garbage._sprite_right = 84

  return garbage
end
