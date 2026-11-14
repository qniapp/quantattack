-- Calibration cart for qa-prof: qa_pre.lua, this file, qa_prof.lua, then qa_prof_cal_end.lua.
-- 1000 calls of the empty qa_cal.b, timed here before qa_prof.lua wraps it and again after;
-- qa_prof.lua's own "p qa_cal.b" line says how much of the wrapped time it counts in the callee.
qa_cal = { b = function() end }

function qa_cal_time()
  local s = stat(1)
  for i = 1, 1000 do
    qa_cal.b()
  end
  return stat(1) - s
end

qa_cal_plain = qa_cal_time()
function _update60() end
function _draw() end
