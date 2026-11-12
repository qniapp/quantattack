-- luacheck config for PICO-8 Lua (run with `rake lint`)
--
-- The game writes methods as `function class.method(_ENV, ...)`, so bare names
-- inside them are object fields, not globals. luacheck cannot tell the two
-- apart, so global checks (W11x, W12x) are off and only local checks remain:
-- unused variables and values, shadowing, empty blocks, unreachable code.
std = "lua52"
ignore = {
  "1..",      -- globals: meaningless with the _ENV object idiom
  "21./_ENV", -- methods receive _ENV even when they do not use it; `local _ENV = self` scopes field access
  "212/self", -- `function obj:method()` overrides keep the method signature
  "212/each_.*", -- for_all_* callbacks receive (block, x, y)
  "214",      -- `_`-prefixed names are used as constructor arguments, not as "unused" hints
  "542",      -- an empty branch with `-- NOP` documents a state that does nothing
}
max_line_length = false
