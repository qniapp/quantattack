score_popup = {
  _all = {},
  _colors = {7, 8, 9, 10, 11, 12},

  create = function(self, x, y, string)
    local p = {}

    p.x = x
    p.y = y
    p.string = string
    p.tick = 0
    p.max_tick = 25
    p.dy = -.2

    add(score_popup._all, p)

    return p
  end,

  update = function(self)
    foreach(score_popup._all, function(each)
      if each.tick > each.max_tick then
        del(score_popup._all, each)
      end

      each.y += each.dy
      each.tick += 1
    end)
  end,

  draw = function(self)
    foreach(score_popup._all, function(each)
      local c = self._colors[flr(rnd(#self._colors)) + 1]
      color(colors.dark_blue)
      ?'\-f' .. each.string .. '\^g\-h' .. each.string .. '\^g\|f' .. each.string .. '\^g\|h' .. each.string, each.x, each.y
      ?each.string, each.x, each.y, c
    end)
  end,
}