-- quantattack profiler harness: `qa-build <cart> prof` puts it in place of qa_post.lua (see qa-prof).
-- Wraps every function stored in a global table (classes, effect sets) and measures, per
-- function, its self time in stat(1) units (its time minus the time of wrapped functions it
-- calls) and its calls. It prints "p <name> <self> <calls> <wrapped calls made>" for each function
-- and "pf <frames>" for the frames those cover, then starts again from 0: every 60 frames (the
-- counters are 16.16 numbers) and before loading another cart. qa-prof plays 60 more frames
-- after the scenario, so its last frames are printed too.
-- Same button protocol as qa_post.lua, without the screen. Kept small: vs_qpu has few tokens left.
-- recs: each wrapped function's { self, calls, wrapped calls made, "p <name> " }.
-- 呼び出し元のレコードから子の所要時間を直接引き、深さごとの配列を省く。
local recs, parent, fr, update, draw, cart_load = {}, split"0,0,0", 0, _update60, _draw, load
local function fin(p, s, ...)
  s = stat(1) - s
  parent[1] += s
  p[1] -= s
  parent = p
  return ...
end
for k, v in pairs(_ENV) do
  if type(v) == "table" then
    for m, f in pairs(v) do
      if type(f) == "function" then
        local r = add(recs, split("0,0,0,p " .. k .. "." .. m .. " "))
        v[m] = function(...)
          r[2] += 1
          local p = parent
          p[3] += 1
          parent = r
          return fin(p, stat(1), f(...))
        end
      end
    end
  end
end
local function flush()
  for r in all(recs) do
    local s = r[4]
    for i = 1, 3 do
      s ..= r[i] .. " "
      r[i] = 0
    end
    printh(s)
  end
  printh("pf " .. fr)
  fr = 0
end
_draw = nil
function load(...)
  flush()
  cart_load(...)
end
function _update60()
  serial(0x804, 0x5f4c, 2)
  for i = 0, 15 do
    qa_held[i] = btn(i % 8, i / 8) and (qa_held[i] or 0) + 1 or 0
  end
  fr += 1
  update()
  draw()
  if (fr == 60) flush()
  printh("qa 0 " .. stat(1))
end
