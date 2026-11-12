# Ultimate setup for quantattack

- `settings.json`: worktree setup (pico-boots submodule) and the lander check `sh .ultimate/test.sh`.
- `worktree-setup.sh`: runs in every new worktree.
- `test.sh`: runs the busted unit tests on Lua 5.4 from the per-user rocks tree `~/.luarocks54`.
  `.busted` preloads `test/pico8_compat.lua`, the PICO-8 builtins (`split`) that pico-boots' test API lacks.

Machine prerequisites (Linux): `pico8` 0.2.7 on PATH (`~/.local/bin/pico8`), and
`luarocks --lua-version 5.4 --tree ~/.luarocks54 install busted luacov bit32`.
