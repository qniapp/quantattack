-- PICO-8 builtins missing from pico-boots' engine/test/pico8api.lua.
-- Loaded by busted before every test file (see .busted), since game modules
-- call them at load time.

function split(str, separator, convert_numbers)
  separator = separator or ","
  local result, start = {}, 1
  while true do
    local stop = string.find(str, separator, start, true)
    local value = string.sub(str, start, stop and stop - 1)
    if convert_numbers ~= false and tonumber(value) then
      value = tonumber(value)
    end
    result[#result + 1] = value
    if not stop then
      return result
    end
    start = stop + #separator
  end
end
