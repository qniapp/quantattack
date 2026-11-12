#!/bin/sh
# Unit tests with busted on Lua 5.4. busted, luacov and bit32 live in the
# per-user rocks tree ~/.luarocks54 (luarocks --lua-version 5.4 --tree ~/.luarocks54 install busted luacov bit32).
set -e
PATH="$HOME/.luarocks54/bin:$PATH"
eval "$(luarocks --lua-version 5.4 --tree "$HOME/.luarocks54" path)"
./scripts/test.sh "$@"
rm -f luacov.stats.out
