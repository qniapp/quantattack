do
  local original_functions = {
    _update60 = _update60,
    _draw = _draw,
    btn = btn,
    btnp = btnp
  }

  local bstate, pstate, addr, is_replay = {}, {}, 0x8000, false

  local function updatebtns()
    for i = 0, 5 do
      pstate[i] = bstate[i]
    end
    if is_replay then
      local mask = peek(addr)
      addr = addr + 1
      if (mask == 0xff) then
        run()
      end
      for i = 0, 5 do
        bstate[i] = mask & (1 << i) ~= 0
      end
    else
      local mask = 0
      for i = 0, 5 do
        bstate[i] = original_functions.btn(i)
        if (bstate[i]) then
          mask = mask|(1 << i)
        end
      end
      if addr < 0x8000 + 0x42ff then
        poke(addr, mask)
        addr = addr + 1
      end
    end
  end

  local function doreplay()
    poke(addr, 0xff)
    memcpy(0, 0x8000, 0x4300)
    cstore(0, 0, 0x4300, "quantattack_replay.p8")
    dset(63, 1)
    run()
  end

  cartdata = function()
  end

  is_replay = dget(63) == 1
  if not is_replay then
    local seed = rnd(0xffff.ffff)
    poke4(addr, seed)
    addr = addr + 4
    srand(seed)
    menuitem(5, "replay", doreplay)
  else
    reload(0, 0, 0x4300, "quantattack_replay.p8")
    memcpy(0x8000, 0, 0x4300)
    reload(0, 0, 0x4300)
    local seed = peek4(addr)
    addr = addr + 4
    srand(seed)
    menuitem(5, "end replay",
      function()
        dset(63, 0)
        run()
      end)
  end

  _update60 = function()
    updatebtns()
    original_functions._update60()
  end

  btn = function(i)
    return bstate[i]
  end

  btnp = function(i)
    return bstate[i] and not pstate[i]
  end

  _draw = function()
    original_functions._draw()
    if is_replay then
      print("replay", 1, 6, 8)
    end
  end
end
