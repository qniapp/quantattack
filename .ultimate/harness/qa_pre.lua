-- quantattack test harness, part 1 of 2: `qa-build <cart> harness` puts it before the cart's main code
-- (and qa_post.lua after it). Kept tiny: vs_qpu has only ~175 tokens to spare.
-- Fixed seed: the same build with the same input gives the same run.
srand(0)
printh("qa:start")

-- PICO-8 derives btnp from the real keyboard, so it is replaced from qa_held
-- (frames each button has been held, counted by qa_post.lua): true on the first frame,
-- then after 30 frames every 8, like PICO-8's default repeat at 60 fps.
qa_held = {}

function btnp(i, p)
  i = qa_held[i + (p or 0) * 8]
  return i == 1 or i > 30 and i % 8 == 7
end
