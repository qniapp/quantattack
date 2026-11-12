# Ultimate setup for quantattack

- `settings.json`: worktree setup (pico-boots submodule). The lander check (`sh .ultimate/test.sh`) is added once the unit tests pass on Linux.
- `worktree-setup.sh`: runs in every new worktree.
- `test.sh`: runs the busted unit tests on Lua 5.4 from the per-user rocks tree `~/.luarocks54`.

Machine prerequisites (Linux): `pico8` 0.2.7 on PATH (`~/.local/bin/pico8`), and
`luarocks --lua-version 5.4 --tree ~/.luarocks54 install busted luacov bit32`.
