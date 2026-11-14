---
name: quantattack-play
description: Build, play and look at quantattack (PICO-8) headless with scripted input, and prove a change keeps game behaviour identical with golden frame traces. Use before and after any change to src/, data/, the build or the cart layout, to play a mode and screenshot it, or to count tokens.
---

# Play and verify quantattack

All commands run from the repository root. Game behaviour must not change (memory
`game-behaviour-frozen`): every change to the game, build or cart layout ends with a green
`qa-check`.

## Never open a window, never play sound

The user said: 「pico-8 はヘッドレスで起動できるならそうしてください。音量もミュートできるならそうしてください。画面をひらいてしまうとこちらの画面が見えなくなってしまうので。」

So never run `pico8` yourself. Launch it only through `.ultimate/bin/qa-run` (and `qa-check`,
which calls it). They always set `SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy`, so no window
opens and no sound plays. Screenshots and GIFs come from the cart's screen memory, not from a
window. Don't use Xvfb or xdotool, and don't take screenshots of the desktop.

## Set up and build

- `.ultimate/bin/qa-setup` installs the pinned shrinko8 in a per-user venv. Run it once per
  machine, and again if a build says `Run .ultimate/bin/qa-setup first`.
- `.ultimate/bin/qa-build <cart|all> [debug|release|harness|prof]` builds to `build/v<version>_<config>/`.
  Both it and the Rakefile build with `scripts/build_cart.py` (preprocess, bundle `require`s,
  `shrinko8 --minify-safe-only`). It installs debug and release carts into the PICO-8 carts folder.
- src/ is standard Lua, because the unit tests run it on Lua 5.4. `build_cart.py` writes
  `x = x + e` as PICO-8's `x += e` (one token less, same cycles) where that cannot change the
  result, so write the long form in src/.
- `.ultimate/bin/qa-build count` prints release token counts. The limit is 8192. vs_qpu is
  closest.
- The carts are listed in `data/cartridges.txt`: title, tutorial, rush, endless, vs_qpu,
  qpu_vs_qpu, vs_human. `title` jumps to the others with `load()`, and they jump back.

## Play a mode

`qa-run` plays the `harness` build: the release code plus `.ultimate/harness/qa_pre.lua`
(before the cart's main file) and `qa_post.lua` (after it). In that build:

- `srand(0)` fixes the seed;
- buttons come from a script instead of the keyboard;
- update and draw run once per frame, with no frame skipping.

So the same build plus the same script always gives the same frames. Run it with:

```sh
.ultimate/bin/qa-build all harness
.ultimate/bin/qa-run [--param P] [--out DIR] CART SCRIPT   # SCRIPT is a file, or - for stdin
```

Script tokens are separated by spaces, and `#` starts a comment. The game runs at 60 frames per second.

- `N`: wait N frames.
- `x`, `o`, `left`, `right`, `up`, `down`: hold for one frame, which is one press. `x:N` holds
  for N frames. While held, btnp repeats on held frames 31, 39, 47 and so on (PICO-8's default).
  `left+x` holds both together. `p2.x` is player 2 (vs_human).
  Consecutive button tokens stay held, so `x x` is a single 2-frame hold. Use `x 1 x` for two taps.
- `shot`: save the next frame as `DIR/frame-NNNNN.png` (512x512). `rec:N` saves the next N frames
  as a real-time GIF (every second frame). Frame counts must be positive, a `rec` may not start
  inside another, and the script must still have frames after its last `shot`/`rec`.
  A frame that loads another cart draws nothing, so it gets no screenshot. `qa-run` says so.
- `--param` is what the title menu passes to the next cart (`stat(6)`). vs_qpu needs it: 1 is the
  hardest QPU, 3 the easiest. In endless it is an optional starting board
  (`.ultimate/harness/qa_endless.lua`): rows bottom up separated by `|`, cells by `;`, each a block
  type with an optional `,other_x`, e.g. `i;t;swap,4;swap,3;i;i|...`. Use it to reproduce one board
  layout in the real cart; see `scenarios/swap_swap.txt` and `swap_swap_swap.txt`. A `harness/qa_<cart>.lua` is appended to
  that cart's harness build only.

For example, the title demo, then the menu, then endless, then one swap:

```sh
echo '300 shot 1 x 30 right 10 x 400 shot 1 left:3 right 10 x 200 shot 1' | .ultimate/bin/qa-run title -
```

Then read the PNGs in `build/qa/title/` to look at the screen. The default `--out` is
`build/qa/<cart>`, and a run replaces only its own files there. `trace.txt` holds one
`frame hash` line per frame. A frame that loads another cart reads `frame jump`. `log.txt` holds
anything else PICO-8 printed, such as runtime errors.

Timing: frames run in real time, 60 per second, plus about 4 s of startup. Several `qa-run`s
can run in parallel.

## Prove behaviour is unchanged

```sh
.ultimate/bin/qa-check            # all scenarios, about 4 min; exit 1 on the first differing frame
.ultimate/bin/qa-check endless    # just one scenario
```

`qa-check` rebuilds the harness and prof carts and plays every script in `.ultimate/qa/scenarios/` (the
first line names the cart and param). It compares each trace with `.ultimate/qa/golden/`. The
scenarios cover every mode, both vs_qpu ends, two-player input, retry after game over, and the
title to endless to title cart jumps.

- Each hash covers the whole screen of that frame, so any change in game logic, randomness or
  drawing shows up within a few frames. For example, a swap animation one frame longer differs
  at frame 241.
- Sound is not compared. PICO-8 mixes audio on a real-time thread, so `stat(46..57)` differ
  between identical runs. Check sound changes by reading the code.
- CPU load is compared too: the user's rule is that a change must not make the game drop more
  frames. Each frame's `stat(1)` goes to `cpu.txt`. `qa-check` fails when a run has more frames
  over 1 (a dropped frame in a real run) than `golden/<scenario>.cpu.txt`, or more than 0.1% more
  total `stat(1)` (`qa-run slow GOLDEN NEW`). It does not compare which frames go over 1: the game
  already has about 1300 frames in qpu_vs_qpu that read about twice their neighbours, and a
  change of a few hundred cycles moves them to other frames even when every frame got faster.
  `stat(1)` varies by about 0.001 between identical runs, and a garbage collection pause now and
  then lands on another frame, so a failing scenario is replayed once and passes if either run does.
- Function times are compared too (`qa-prof compare`, below): no function may take more than 1%
  (and 0.5 thousandths of a frame) longer per frame than in `golden/<scenario>.prof.txt`. This
  catches a slower spot hidden inside a run that is faster overall.
- Real-time behaviour the harness pins down (frame skipping, `t()` drift on slow machines)
  is not covered.
- `--record` rewrites the goldens. Record only from the reference behaviour, for example on
  `main` before a refactor, never to make a failing check pass. A new scenario needs its
  golden recorded on the reference commit first. The one exception so far: a gameplay fix the
  user approved (issue #125) re-recorded only the CPU goldens whose spikes moved, with pixel
  goldens untouched.

## Measure where the CPU goes

```sh
.ultimate/bin/qa-prof vs_qpu_1 qpu_vs_qpu          # build prof carts, play scenarios (3x slower)
.ultimate/bin/qa-prof show build/prof/vs_qpu_1/prof.txt 20
.ultimate/bin/qa-prof compare .ultimate/qa/golden/vs_qpu_1.prof.txt build/prof/vs_qpu_1/prof.txt
```

The `prof` build wraps every function stored in a global table (classes, effect sets) with
`.ultimate/harness/qa_prof.lua` and measures its own time per frame, in thousandths of a frame
(1000 = `stat(1)` 1.0), and its calls per frame, over every frame of the scenario. The wrappers'
cost is measured by a small calibration cart (`harness/qa_prof_cal*.lua`: an empty function,
unwrapped and wrapped) and subtracted, and the numbers are deterministic. Drawing takes 55-73% of the time
(`board_class.render`, `block_class.render`, `ripple._render`), the board update most of the
rest; reduction and QPU code take a few percent. Before cutting tokens in a function, look at
its share: code that runs rarely can be shortened freely, and code that runs hundreds of times a
frame (`block_at`, `screen_x`, `block_class.render`) must not get slower. In hot code, avoid
new tables, closures and strings each frame.

## When the harness cart is too large

The harness adds about 135 tokens, the prof harness about 310; vs_qpu is the largest. If a game
change pushes a harness or prof cart over the limit, `qa-run` fails with `program too large` in
its log. Shrink the harness first; never change the game to make room.
