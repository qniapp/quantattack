pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
colors = {
  ["blue"] = 12,
  ["red"] = 8,
}

drop_particle = {
  create = function(x, y, init_size, col)
    local p = {}
    local left = false

    if flr(rnd(2)) == 0 then
      left = true
    end

    p.x = x
    p.y = y
    p.col = col
    p.width = init_size
    p.t = 0
    p.max_t = 30 + rnd(10)
    p.dx = (rnd(.8)) * .4
    p.dy = rnd(.05)
    p.ddy = .02

    if (left) then
      p.dx *= -1
    end

    add(drop_particles, p)
    return p
  end,

  update = function(p)
    if (p.t > p.max_t) then
      del(drop_particles, p)
    end
    if (p.t > p.max_t - 15) then
      p.col = 6
    end

    p.x = p.x + p.dx
    p.y = p.y + p.dy
    p.dy = p.dy + p.ddy
    p.t = p.t + 1
  end,

  draw = function(p)
    circfill(p.x, p.y, p.width, p.col)
  end
}

gate_reduction_rules = {
  reduce = function(self, board, x, y)
    if y + 1 > board.rows then
      return {}
    end

    -- hh -> i
    if (board:idle_gate_at(x, y).type == "h" and board:idle_gate_at(x, y + 1).type == "h") then
      return { gate.i(), gate.i() }
    end

    -- xx -> i
    if (board:idle_gate_at(x, y).type == "x" and board:idle_gate_at(x, y + 1).type == "x") then
      return { gate.i(), gate.i() }
    end

    -- yy -> i
    if (board:idle_gate_at(x, y).type == "y" and board:idle_gate_at(x, y + 1).type == "y") then
      return { gate.i(), gate.i() }
    end

    -- zz -> i
    if (board:idle_gate_at(x, y).type == "z" and board:idle_gate_at(x, y + 1).type == "z") then
      return { gate.i(), gate.i() }
    end

    -- zx -> y
    if (board:idle_gate_at(x, y).type == "z" and board:idle_gate_at(x, y + 1).type == "x") then
      return { gate.i(), gate.y() }
    end

    -- xz -> y
    if (board:idle_gate_at(x, y).type == "x" and board:idle_gate_at(x, y + 1).type == "z") then
      return { gate.i(), gate.y() }
    end

    -- ss -> z
    if (board:idle_gate_at(x, y).type == "s" and board:idle_gate_at(x, y + 1).type == "s") then
      return { gate.i(), gate.z() }
    end

    -- tt -> s
    if (board:idle_gate_at(x, y).type == "t" and board:idle_gate_at(x, y + 1).type == "t") then
      return { gate.i(), gate.s() }
    end

    if y + 2 > board.rows then
      return {}
    end

    -- hxh -> z
    if (board:idle_gate_at(x, y).type == "h" and board:idle_gate_at(x, y + 1).type == "x" and board:idle_gate_at(x, y + 2).type == "h") then
      return { gate.i(), gate.i(), gate.z() }
    end 

    -- hzh -> z
    if (board:idle_gate_at(x, y).type == "h" and board:idle_gate_at(x, y + 1).type == "z" and board:idle_gate_at(x, y + 2).type == "h") then
      return { gate.i(), gate.i(), gate.x() }
    end 

    -- szs -> z
    if (board:idle_gate_at(x, y).type == "s" and board:idle_gate_at(x, y + 1).type == "z" and board:idle_gate_at(x, y + 2).type == "s") then
      return { gate.i(), gate.i(), gate.z() }
    end 

    return {}
  end,
}

board = {
  cols = 6,
  rows = 12,

  new = function(self, top, left)
    local b = {
      init = function(self, top, left)
        self.gate = {}
        self.top = top
        self.left = left
        self.cols = board.cols
        self.rows = board.rows

        for x = 1, board.cols do
          self.gate[x] = {}
          for y = board.rows, 1, -1 do
            if y >= 5 then
              repeat
                self:set(x, y, self:_random_gate())
              until (self:idle_gate_at(x, y).type ~= "i" and #gate_reduction_rules:reduce(self, x, y) == 0)
            else
              self:set(x, y, gate.i())
            end
          end
        end
      end,

      idle_gate_at = function(self, x, y)
        assert(x >= 1 and x <= board.cols)
        assert(y >= 1 and y <= board.rows)

        if self.gate[x][y].state == "idle" then
          return self.gate[x][y]
        else
          return gate.i()
        end
      end,

      set = function(self, x, y, gate)
        assert(x >= 1 and x <= board.cols)
        assert(y >= 1 and y <= board.rows)

        self.gate[x][y] = gate
      end,

      update = function(self)
        self:reduce()
        self:drop_gates()
        self:update_gates()
      end,

      draw = function(self)
        for x = 1, board.cols do
          for y = 1, board.rows do
            local _x = self.left + (x - 1) * gate.size
            local _y = self.top + (y - 1) * gate.size
            wire:draw(_x, _y)

            if self.gate[x][y].state == "dropped" then
              self.gate[x][y]:draw(_x, _y + 4)
            elseif self.gate[x][y].state == "dropped1" then
              self.gate[x][y]:draw(_x, _y + 3)
            else
              self.gate[x][y]:draw(_x, _y)
            end
          end
        end
      end,

      swap = function(self, xl, xr, y)
        local left_gate = self.gate[xl][y]
        local right_gate = self.gate[xr][y]
        assert(left_gate ~= nil)
        assert(right_gate ~= nil)

        if left_gate.state ~= "idle" or right_gate.state ~= "idle" then
          return false
        end

        self:set(xl, y, right_gate)
        self:set(xr, y, left_gate)
      end,

      reduce = function(self)
        for x = 1, board.cols do
          for y = board.rows - 1, 1, -1 do
            if self.gate[x][y].state == "idle" then
              reduction = gate_reduction_rules:reduce(self, x, y)
              for index, gate in pairs(reduction) do
                self.gate[x][y + index - 1]:replace_with(gate)
              end
            end
          end
        end
      end,

      gates_in_action = function(self)
        local gates = {}

        for x = 1, board.cols do
          for y = 1, board.rows do
            if self.gate[x][y].state != "idle" then
              add(gates, self.gate[x][y])
            end
          end
        end

        return gates
      end,

      gates_dropped_bottom = function(self)
        local gates = {}

        for x = 1, board.cols do
          for y = 1, board.rows do
            if (self.gate[x][y].type ~= "i" and
                self.gate[x][y].state == "dropped" and
                (self.gate[x][y + 1] == nil or
                 (self.gate[x][y + 1].state != "dropped"))) then
              self.gate[x][y].x = x
              self.gate[x][y].y = y
              add(gates, self.gate[x][y])
            end
          end
        end

        return gates
      end,

      replaced_gates = function(self)
        local gates = {}

        for x = 1, board.cols do
          for y = 1, board.rows do
            if (self.gate[x][y].state == "replaced") then
              self.gate[x][y].x = x
              self.gate[x][y].y = y
              add(gates, self.gate[x][y])
            end
          end
        end

        return gates
      end,

      drop_gates = function(self)
        for x = 1, board.cols do
          for y = board.rows - 1, 1, -1 do
            local ty = y
            local lower_gate = self.gate[x][ty + 1]
            while (lower_gate ~= nil and
                   self.gate[x][ty].type != "i" and
                   self.gate[x][ty].state == "idle" and
                   lower_gate.state == "idle" and
                   lower_gate.type == "i") do
              self.gate[x][ty + 1] = self.gate[x][ty]
              self.gate[x][ty] = gate.i()
              ty += 1
              lower_gate = self.gate[x][ty + 1]
            end

            if (ty > y) then
              self.gate[x][ty]:dropped()
            end
          end
        end
      end,

      insert_gates_at_bottom = function(self)
        for x = 1, board.cols do
          for y = 1, board.rows - 1 do
            if y == 1 and self.gate[x][y].type ~= 'i' then
              self:game_over()
            else
              self.gate[x][y] = self.gate[x][y + 1]
            end
          end
        end

        for x = 1, board.cols do
          repeat
            self:set(x, board.rows, self:_random_gate())
          until (self:idle_gate_at(x, board.rows).type ~= "i" and
                 #gate_reduction_rules:reduce(self, x, board.rows - 1) == 0 and
                 #gate_reduction_rules:reduce(self, x, board.rows - 2) == 0)
        end
      end,

      update_gates = function(self)
        for x = 1, board.cols do
          for y = 1, board.rows do
            self.gate[x][y]:update()
          end
        end
      end,

      game_over = function(self)
        assert(false, "game over")
      end,

      -- private

      _random_gate = function(self)
        return gate:new(gate.types[flr(rnd(#gate.types)) + 1])
      end,
    }

    b:init(top, left)

    return b
  end,
}

wire = {
  _sprite = 6,

  draw = function(self, x, y)
    spr(self._sprite, x, y)
  end,
}

gate = {
  types = {"h", "x", "y", "z", "s", "t", "i"},

  sprites = {
    ["idle"] = {
      ["h"] = 0,
      ["x"] = 1,
      ["y"] = 2,
      ["z"] = 3,
      ["s"] = 4,
      ["t"] = 5,
      ["i"] = 6,
    }
  },
  -- todo: sprites_dropped → sprites.dropped
  sprites_dropped = {
    ["h"] = 16,
    ["x"] = 17,
    ["y"] = 18,
    ["z"] = 19,
    ["s"] = 20,
    ["t"] = 21,
  },
  -- todo: sprites_dropped1 → sprites.dropped1
  -- todo: もっとまともな名前にする
  sprites_dropped1 = {
    ["h"] = 32,
    ["x"] = 33,
    ["y"] = 34,
    ["z"] = 35,
    ["s"] = 36,
    ["t"] = 37,
  },
  -- todo: sprites_flash → sprites.flash
  -- todo: スプライトを使わなくても pal でできる? 要検討
  sprites_flash = {
    ["h"] = 48,
    ["x"] = 49,
    ["y"] = 50,
    ["z"] = 51,
    ["s"] = 52,
    ["t"] = 53,
  },
  size = 8,

  new = function(self, type)
    return {
      type = type,
      next_type = nil,
      state = "idle",

      frame_count_since_replace = 0,
      frame_count_since_dropped = 0,

      draw = function(self, x, y)
        if self.type == "i" then return end

        spr(self:_sprite(), x, y)
      end,

      replace_with = function(self, other)
        assert(self.type ~= "i")
        assert(other.type)

        if self.state != "idle" then
          return
        end

        self.next_type = other.type
        self:change_state("replacing")
        self.frame_count_since_replace = 0
      end,

      dropped = function(self)
        self:change_state("dropped")
        self.frame_count_since_dropped = 0
      end,

      change_state = function(self, new_state)
        assert(new_state)

        self.state = new_state
      end,

      update = function(self)
        if self.state == "idle" then
          return
        elseif self.state == "replacing" then
          if self.frame_count_since_replace < 60 then
            self.frame_count_since_replace += 1
          else
            self.type = self.next_type
            if self.type == "i" then
              self:change_state("idle")
            else
              self:change_state("replaced")
            end
            self.frame_count_since_replace = 0
          end
        elseif self.state == "replaced" then
          self:change_state("idle")
        elseif self.state == "dropped" then
          self.frame_count_since_dropped += 1
          if (self.frame_count_since_dropped == 3) then
            self:change_state("dropped1")
          end
        elseif self.state == "dropped1" then
          self.frame_count_since_dropped += 1
          if (self.frame_count_since_dropped == 5) then
            self:change_state("idle")
          end
        else
          assert(false, "we should never get here")
        end
      end,

      -- private

      _sprite = function(self)
        if self.state == "idle" then
          return gate.sprites[self.state][self.type]
        elseif self.state == "replacing" then
          if self.frame_count_since_replace % 4 == 0 or self.frame_count_since_replace % 4 == 1 then
            return gate.sprites_flash[self.type]
          else
            return gate.sprites.idle[self.type]
          end
        elseif self.state == "replaced" then
          return gate.sprites.idle[self.type]
        elseif self.state == "dropped" then
          return gate.sprites_dropped[self.type]
        elseif self.state == "dropped1" then
          return gate.sprites_dropped1[self.type]
        else
          assert(false, "we should never get here")
        end
      end
    }
  end,
}

gate.x = function()
  return gate:new("x")
end
gate.y = function()
  return gate:new("y")
end
gate.z = function()
  return gate:new("z")
end
gate.s = function()
  return gate:new("s")
end
gate.i = function()
  return gate:new("i")
end

-- player's cursor class

player_cursor = {
  _sprites = {
    ["corner"] = 22,
    ["middle"] = 38
  },

  new = function(self, x, y, board)
    local c = {
      init = function(self, x, y, board)
        self.x = x
        self.y = y
        self.board = board
        self._tick = 0
        self:_change_state("idle")
      end,

      move_left = function(self)
        if self.x == 1 then
          self:flash()
        else
          self.x -= 1
        end
      end,

      move_right = function(self)
        if self.x == board.cols - 1 then
          self:flash()
        else
          self.x += 1
        end
      end,

      move_up = function(self)
        if self.y == 1 then
          self:flash()
        else
          self.y -= 1
        end
      end,

      move_down = function(self)
        if self.y == board.rows then
          self:flash()
        else
          self.y += 1
        end
      end,

      flash = function(self)
        self:_change_state("flash")
      end,

      update = function(self)
        assert(self._tick >= 0 and self._tick < 30)

        -- tick == 0 ... 14: state -> "idle"
        if self._tick == 15 then
          self:_change_state("shrunk")
        end

        -- tick == 15 ... 29: state -> "shrunk"
        if self._tick == 29 then
          self:_change_state("idle")
        end

        self._tick += 1
        if self._tick == 30 then
          self._tick = 0
        end
      end,

      draw = function(self)
        -- top left
        local xtl = self.board.left + (self.x - 1) * gate.size - 5
        local ytl = self.board.top + (self.y - 1) * gate.size - 5

        -- top right
        local xtr = self.board.left + self.x * gate.size + 4
        local ytr = ytl

        -- bottom left
        local xbl = xtl
        local ybl = self.board.top + self.y * gate.size - 4

        -- bottom right
        local xbr = self.board.left + self.x * gate.size + 4
        local ybr = ybl

        -- top middle
        local xtm = self.board.left + (self.x - 1) * gate.size + 4
        local ytm = ytl

        -- bottom middle
        local xbm = self.board.left + (self.x - 1) * gate.size + 4
        local ybm = ybl

        if self.state == "shrunk" then
          xtl += 1
          ytl += 1
          xtr -= 1
          ytr += 1
          xbl += 1
          ybl -= 1
          xbr -= 1
          ybr -= 1
          ytm += 1
          ybm -= 1
        end

        if self.state == "flash" then
          pal(colors.blue, colors.red)
        end

        spr(player_cursor._sprites.corner, xtl, ytl)
        spr(player_cursor._sprites.corner, xtr, ytr, 1, 1, true, false)
        spr(player_cursor._sprites.corner, xbl, ybl, 1, 1, false, true)
        spr(player_cursor._sprites.corner, xbr, ybr, 1, 1, true, true)
        spr(player_cursor._sprites.middle, xtm, ytm)
        spr(player_cursor._sprites.middle, xbm, ybm, 1, 1, false, true)

        pal(colors.blue, colors.blue)
      end,

      -- private

      _change_state = function(self, new_state)
        assert(new_state)
        assert(new_state == "idle" or new_state == "shrunk" or new_state == "flash")

        if new_state == "idle" then
          assert(self.state == nil or self.state == "shrunk" or self.state == "flash")
        end
        if new_state == "shrunk" then
          assert(self.state == "idle" or self.state == "flash")
        end

        self.state = new_state
      end,
    }

    c:init(x, y, board)

    return c
  end,
}

game = {
  init = function(self)
    drop_particles = {}
    self.board = board:new(32, 2)
    self.player_cursor = player_cursor:new(1, 1, self.board)
    self.frame_count = 0
    self.num_raise_gates = 0
  end,

  update = function(self, board)
    self.frame_count += 1

    foreach(drop_particles, drop_particle.update)

    if btnp(0) then
      self.player_cursor:move_left()
    end

    if btnp(1) then
      self.player_cursor:move_right()
    end

    if btnp(2) then
      self.player_cursor:move_up()
    end

    if btnp(3) then
      self.player_cursor:move_down()
    end

    if (btnp(4)) then
      local swapped = self.board:swap(self.player_cursor.x, self.player_cursor.x + 1, self.player_cursor.y)
      if swapped == false then
        self.player_cursor:flash()
      end
    end

    self.board:reduce()
    self.board:drop_gates()
    self.board:update_gates()
    foreach(self.board:gates_dropped_bottom(), function(each)
      assert(each.state == "dropped")
        local x = self.board.left + (each.x - 1) * gate.size
        local y = self.board.top + (each.y - 1) * gate.size
        drop_particle.create(x + 3, y + 7, 0, 9)
        drop_particle.create(x + 3, y + 7, 0, 9)
        drop_particle.create(x + 3, y + 7, 0, 10)
        drop_particle.create(x + 3, y + 7, 0, 10)
    end)
    self.player_cursor:update()

    if self.frame_count == 30 then
      if #self.board:gates_in_action() == 0 then
        self.num_raise_gates += 1
        if self.num_raise_gates == 8 then
          self.num_raise_gates = 0
          self.board:insert_gates_at_bottom()
          self.player_cursor:move_up()
        end
      end

      self.frame_count = 0
    end
  end,

  draw_stats = function(self)
    cursor(0, 0)
    color(7)
    print("cpu: " .. stat(1) * 100)
    print("fps: " .. stat(7))
  end,

  draw = function(self)
    cls()

    self.board:draw()
    self.player_cursor:draw()
    self:draw_stats()
  end,    
}

function _init()
  game:init()
end

function _update60()
  game:update()
end

function _draw()
  game:draw()

  foreach(drop_particles, drop_particle.draw)
end
__gfx__
66666660006660006666666066666660444444402222222000050000000000000000000000000000000000000000000000000000000000000000000000000000
61666160066166006166616061111160446666402666662000050000000000000000000000000000000000000000000000000000000000000000000000000000
61666160666166606616166066661660464444402226222000050000000000000000000000000000000000000000000000000000000000000000000000000000
61111160611111606661666066616660446664402226222000050000000000000000000000000000000000000000000000000000000000000000000000000000
61666160666166606661666066166660444446402226222000050000000000000000000000000000000000000000000000000000000000000000000000000000
61666160066166006661666061111160466664402226222000050000000000000000000000000000000000000000000000000000000000000000000000000000
66666660006660006666666066666660444444402222222000050000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000
66666660006660006666666066666660444444402222222000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666660066666006666666066666660444444402222222000000000033333000000000000000000000000000000000000000000000000000000000000000000
66666660666666606666666066666660444444402222222000000000037773000000000000000000000000000000000000000000000000000000000000000000
666666606666666066666660666666604444444022222220000ccc00037333000000000000000000000000000000000000000000000000000000000000000000
666666606666666066666660666666604444444022222220000c0000037300000000000000000000000000000000000000000000000000000000000000000000
616661600111110061161160611111604466664026666620000c0000033300000000000000000000000000000000000000000000000000000000000000000000
61111160006160006611166061111160466666402226222000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666660006660006666666066666660444444402222222000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666660066666006666666066666660444444402222222000000000333333300000000000000000000000000000000000000000000000000000000000000000
66666660666666606666666066666660444444402222222000000000377777300000000000000000000000000000000000000000000000000000000000000000
6666666066666660666666606666666044444440222222200ccccc00333733300000000000000000000000000000000000000000000000000000000000000000
616661606661666061666160611111604466644026666620000c0000003730000000000000000000000000000000000000000000000000000000000000000000
611111600111110066111660661116604666664022262220000c0000003330000000000000000000000000000000000000000000000000000000000000000000
61666160006160006661666061111160446664402226222000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000666600000000000000000000000000000000000000000000000000000000000000000000000000
07000700000700000700070007777700007777000777770006000060000000000000000000000000000000000000000000000000000000000000000000000000
07000700000700000070700000007000070000000007000060000006000000000000000000000000000000000000000000000000000000000000000000000000
07777700077777000007000000070000007770000007000060000006000000000000000000000000000000000000000000000000000000000000000000000000
07000700000700000007000000700000000007000007000060000006000000000000000000000000000000000000000000000000000000000000000000000000
07000700000700000007000007777700077770000007000060000006000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000006000060000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000666600000000000000000000000000000000000000000000000000000000000000000000000000
