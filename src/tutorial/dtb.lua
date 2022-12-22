---@diagnostic disable: lowercase-global

require ("lib/helpers")

-- call this before you start using dtb.
-- optional parameter is the number of lines that are displayed. default is 3.
function dtb_init(numlines)
  dtb_queu = {}
  dtb_queuf = {}
  dtb_numlines = 3
  if numlines then
    dtb_numlines = numlines
  end
  _dtb_clean()
end

-- this will add a piece of text to the queu. the queu is processed automatically.
function dtb_disp(txt, callback)
  local lines = {}
  local currline = ""
  local curword = ""
  local curchar = ""
  local upt = function()
    if #curword + #currline > 27 then
      add(lines, currline)
      currline = ""
    end
    currline = currline .. curword
    curword = ""
  end
  for i = 1, #txt do
    curchar = sub(txt, i, i)
    curword = curword .. curchar
    if curchar == " " then
      upt()
    elseif #curword > 26 then
      curword = curword .. "-"
      upt()
    end
  end
  upt()
  if currline ~= "" then
    add(lines, currline)
  end
  add(dtb_queu, lines)
  if callback == nil then
    callback = 0
  end
  add(dtb_queuf, callback)
end

-- functions with an underscore prefix are ment for internal use, don't worry about them.
function _dtb_clean()
  dtb_dislines = {}
  for i = 1, dtb_numlines do
    add(dtb_dislines, "")
  end
  dtb_curline = 0
  dtb_ltime = 0
end

function _dtb_nextline()
  dtb_curline = dtb_curline + 1
  for i = 1, #dtb_dislines - 1 do
    dtb_dislines[i] = dtb_dislines[i + 1]
  end
  dtb_dislines[#dtb_dislines] = ""
  sfx(2)
end

function _dtb_nexttext()
  if dtb_queuf[1] ~= 0 then
    dtb_queuf[1]()
  end
  del(dtb_queuf, dtb_queuf[1])
  del(dtb_queu, dtb_queu[1])
  _dtb_clean()
  sfx(2)
end

-- make sure that this function is called each update.
function dtb_update()
  if #dtb_queu > 0 then
    if dtb_curline == 0 then
      dtb_curline = 1
    end
    local dislineslength = #dtb_dislines
    local curlines = dtb_queu[1]
    local curlinelength = #dtb_dislines[dislineslength]
    local complete = curlinelength >= #curlines[dtb_curline]
    if complete and dtb_curline >= #curlines then
      if btnp(5) then
        _dtb_nexttext()
        return
      end
    elseif dtb_curline > 0 then
      dtb_ltime = dtb_ltime - 1
      if not complete then
        if dtb_ltime <= 0 then
          local curchari = curlinelength + 1
          local curchar = sub(curlines[dtb_curline], curchari, curchari)
          dtb_ltime = 1
          if curchar ~= " " then
            sfx(25)
          end
          if curchar == "." then
            dtb_ltime = 6
          end
          dtb_dislines[dislineslength] = dtb_dislines[dislineslength] .. curchar
        end
        if btnp(5) then
          dtb_dislines[dislineslength] = curlines[dtb_curline]
        end
      else
        if btnp(5) then
          _dtb_nextline()
        end
      end
    end
  end
end

function dtb_draw()
  if #dtb_queu > 0 then
    local dislineslength = #dtb_dislines
    local offset = 0
    if dtb_curline < dislineslength then
      offset = dislineslength - dtb_curline
    end

    -- 「次へ」ボタン
    if dtb_curline > 0 and #dtb_dislines[#dtb_dislines] == #dtb_queu[1][dtb_curline] then
      spr(99, 113, 21)
    end

    for i = 1, dislineslength do
      print_outlined(dtb_dislines[i], 8, i * 8 + 24 - (dislineslength + offset) * 8, 7, 0)
    end
  end
end
