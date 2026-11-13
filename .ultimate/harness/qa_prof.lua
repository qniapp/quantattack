-- quantattack profiler harness: `qa-prof` builds it in place of qa_post.lua (see qa-prof).
-- Wraps every function stored in a global table (classes, effect sets) and measures, per
-- function, its self time in stat(1) units (its time minus the time of wrapped functions it
-- calls) and its calls. Every 60 frames it prints "p <name> <self> <calls> <wrapped calls made>"
-- for each function, then starts again from 0.
-- Same button protocol as qa_post.lua, without the screen hash.
-- qa_cal measures the wrappers' own cost: qa_cal.a calls the empty qa_cal.b 1000 times.
qa_cal = { b = function() end }
function qa_cal.a()
  for i = 1, 1000 do
    qa_cal.b(1, 2)
  end
end
local recs, c, n, d, fr = {}, { [0] = 0 }, { [0] = 0 }, 0, 0
local function fin(r, s, ...)
  s = stat(1) - s
  r[1] += s - c[d]
  r[3] += n[d]
  d -= 1
  c[d] += s
  return ...
end
for k, v in pairs(_ENV) do
  if type(v) == "table" then
    for m, f in pairs(v) do
      if type(f) == "function" then
        local r = { 0, 0, 0, k .. "." .. m }
        add(recs, r)
        v[m] = function(...)
          r[2] += 1
          n[d] += 1
          d += 1
          c[d], n[d] = 0, 0
          return fin(r, stat(1), f(...))
        end
      end
    end
  end
end
for i = 1, 10 do
  qa_cal.a()
end
local update, draw = _update60, _draw
_draw = nil
function _update60()
  serial(0x804, 0x5f4c, 2)
  for i = 0, 15 do
    qa_held[i] = btn(i % 8, i / 8) and (qa_held[i] or 0) + 1 or 0
  end
  update()
  draw()
  fr += 1
  if fr % 60 == 0 then
    for r in all(recs) do
      printh("p " .. r[4] .. " " .. r[1] .. " " .. r[2] .. " " .. r[3])
      r[1], r[2], r[3] = 0, 0, 0
    end
  end
  printh("qa 0 " .. stat(1))
end
