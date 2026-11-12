# Ultimate setup for quantattack

- `settings.json`: worktree setup (pico-boots submodule).
- `worktree-setup.sh`: runs in every new worktree.
- `test.sh`: runs the busted unit tests on Lua 5.4 from the per-user rocks tree `~/.luarocks54`.
  `.busted` preloads `test/pico8_compat.lua`, the PICO-8 builtins (`split`) that pico-boots' test API lacks.

Linux cartridge builds (no PICO-8 launch): run `.ultimate/bin/qa-setup` once, then
`.ultimate/bin/qa-build <cart|all> [debug|release]` (default: debug) to build and install
under `~/.lexaloffle/pico-8/carts/quantattack/v<version>_<config>/`.
`qa-build count` builds release carts and prints shrinko8 token counts.

Headless play and behaviour checks (skill: `skills/quantattack-play/SKILL.md`): `qa-build all harness`
builds the release code wrapped by `harness/` (fixed seed, scripted buttons, a screen hash per frame);
`bin/qa-run` plays a cart with a script (PICO-8 always headless and muted), saving traces and
screenshots; `bin/qa-check` plays `qa/scenarios/` and compares with `qa/golden/`.
Setup needs Git, Node/npm (via mise), rsync and `/usr/bin/python3` with venv/pip; pinned
picotool and shrinko8 live in `~/.local/share/quantattack-tools/venv`, with no shell changes.
A venv-local `python3.6 -> python3` link supports pico-boots' unchanged shebangs.
Build symbols match the Rakefile, including `sash` for endless/rush. Data is built in;
the only named data cart, `quantattack_replay.p8`, is created by the game at runtime.

Machine prerequisites (Linux): `pico8` 0.2.7 on PATH (`~/.local/bin/pico8`), and
`luarocks --lua-version 5.4 --tree ~/.luarocks54 install busted luacov bit32`.
