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
- `.ultimate/bin/qa-build <cart|all> [debug|release|harness]` builds to `build/v<version>_<config>/`.
  Both it and the Rakefile build with `scripts/build_cart.py` (preprocess, bundle `require`s,
  `shrinko8 --minify-safe-only`). It installs debug and release carts into the PICO-8 carts folder.
- `.ultimate/bin/qa-build count` prints release token counts. The limit is 8192. vs_qpu is
  closest, at 7941.
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
  layout in the real cart; see `scenarios/swap_swap.txt`. A `harness/qa_<cart>.lua` is appended to
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
.ultimate/bin/qa-check            # all scenarios, about 2.5 min; exit 1 on the first differing frame
.ultimate/bin/qa-check endless    # just one scenario
```

`qa-check` rebuilds the harness carts and plays every script in `.ultimate/qa/scenarios/` (the
first line names the cart and param). It compares each trace with `.ultimate/qa/golden/`. The
scenarios cover every mode, both vs_qpu ends, two-player input, retry after game over, and the
title to endless to title cart jumps.

- Each hash covers the whole screen of that frame, so any change in game logic, randomness or
  drawing shows up within a few frames. For example, a swap animation one frame longer differs
  at frame 241.
- Sound is not compared. PICO-8 mixes audio on a real-time thread, so `stat(46..57)` differ
  between identical runs. Check sound changes by reading the code.
- CPU load is compared too. Each frame's `stat(1)` goes to `cpu.txt`, and `qa-check` fails when
  a frame goes over 1 (a dropped frame in a real run) that was at most 0.99 in
  `golden/<scenario>.cpu.txt`. Use `qa-run slow GOLDEN NEW` to compare two runs. The current game
  already goes over 1 on some frames (vs_human about 2100, qpu_vs_qpu about 2000). The game is frozen, so leave those alone;
  only frames that newly go over 1 count. `stat(1)` varies by up to about 0.001 between identical runs,
  and a garbage collection pause occasionally lands on a neighbouring frame (0.90 to 1.84 with
  identical pixels). So when a scenario shows new slow frames, `qa-check` replays it once and fails
  only on frames that are newly slow in both runs.
- Real-time behaviour the harness pins down (frame skipping, `t()` drift on slow machines)
  is not covered.
- `--record` rewrites the goldens. Record only from the reference behaviour, for example on
  `main` before a refactor, never to make a failing check pass. A new scenario needs its
  golden recorded on the reference commit first. The one exception so far: a gameplay fix the
  user approved (issue #125) re-recorded only the CPU goldens whose spikes moved, with pixel
  goldens untouched.

## When the harness cart is too large

The harness adds about 135 tokens. vs_qpu's harness build is 8076 of 8192. If a game change
pushes a harness cart over the limit, `qa-run` fails with `program too large` in its log. Shrink
the harness first; never change the game to make room.
