-- quantattack test harness, part 2 of 2. Protocol (driven by .ultimate/bin/qa-run):
-- each frame reads 2 bytes of stdin into the button state (0x5f4c: player 0, 0x5f4d: player 1),
-- runs the cart's update and draw, then prints one line "qa <hash>" of the screen.
-- Sound state (stat(46..57)) is left out: PICO-8 mixes audio on a real-time thread, so it differs
-- between identical runs. When bit 7 of the second byte is set, the 8 KiB screen
-- follows that line as raw bytes. A frame that jumps to another cart prints nothing (load()
-- does not return); the "qa:start" line of the next cart (qa_pre.lua) tells qa-run.
-- Draw runs from update, once per update: PICO-8 skips _draw on slow frames by wall-clock
-- time, which would make traces differ between runs. Kept tiny: vs_qpu has few tokens left.
local update, draw = _update60, _draw
_draw = nil

function _update60()
  serial(0x804, 0x5f4c, 2)
  for i = 0, 15 do
    qa_held[i] = btn(i % 8, i / 8) and (qa_held[i] or 0) + 1 or 0
  end
  update()
  draw()
  local s = 0
  for a = 0x6000, 0x7ffc, 4 do
    s = rotl(bxor(s, peek4(a)), 5)
  end
  printh("qa " .. tostr(s, true))
  if peek(0x5f4d) > 127 then
    serial(0x805, 0x6000, 8192)
  end
end
