player = {
  ["steps"] = 0,
  cnot_probability = function(self)
    return self.steps / 50 + 0.3
  end,
}

game = {
  _button = {
    ["left"] = 0,
    ["right"] = 1,
    ["up"] = 2,
    ["down"] = 3,
    ["x"] = 4,
    ["o"] = 5,
  },

  _sfx = {
    ["move_cursor"] = 0,
    ["gate_drop"] = 1,
    ["puff"] = 3,
  },

  init = function(self)
    self._state = "solo"
    self.board = board:new(18, 3)
    self.board:initialize_with_random_gates()
    self.player_cursor = player_cursor:new(1, 1, self.board)
    self.tick = 0
    self.dots_gates_raised = 0
    self.duration_raise_gates = 30 -- 0.5 seconds
  end,

  update = function(self, board)
    if self._state == "solo" then
      self:_handle_button_events()

      self.board:reduce()
      self.board:drop_gates()
      self.board:update_gates()

      self:_create_gate_drop_particles()
      self:_create_gate_puff_particles()

      self:_maybe_change_cursor_color()
      self.player_cursor:update()

      self:_maybe_raise_gates()

      puff_particle:update()
      dropping_particle:update()

      self.tick += 1
    elseif self._state == "game over" then
      if btnp(5) then
        self:init()
      end

      self.player_cursor:update()
    else
      assert(false, "unknown state")
    end
  end,

  draw = function(self)
    cls()

    if self._state == "solo" then
      self.board:draw()
      self.player_cursor:draw()

      puff_particle:draw()
      dropping_particle:draw()

      self:draw_scores()
      self:draw_stats()
    elseif self._state == "game over" then
      cursor(73, 50)
      color(colors.red)
      print("game over")
      cursor(57, 58)
      color(colors.white)
      print("push ❎ to replay")

      self.board:draw()
      self.player_cursor:draw()

      puff_particle:draw()
      dropping_particle:draw()

      self:draw_scores()
      self:draw_stats()
    end
  end,    

  -- private

  _handle_button_events = function(self)
    if btnp(game._button.left) then
      self.player_cursor:move_left()
      sfx(game._sfx.move_cursor)
    end

    if btnp(game._button.right) then
      self.player_cursor:move_right()
      sfx(game._sfx.move_cursor)
    end

    if btnp(game._button.up) then
      self.player_cursor:move_up()
      sfx(game._sfx.move_cursor)
    end

    if btnp(game._button.down) then
      self.player_cursor:move_down()
      sfx(game._sfx.move_cursor)
    end

    if btnp(game._button.x) then
      local swapped = self.board:swap(self.player_cursor.x, self.player_cursor.x + 1, self.player_cursor.y)
      if swapped == false then
        self.player_cursor.warn = true
      end
    end
  end,

  _maybe_change_cursor_color = function(self)
    local left_gate = self.board:gate_at(self.player_cursor.x, self.player_cursor.y)
    local right_gate = self.board:gate_at(self.player_cursor.x + 1, self.player_cursor.y)

    self.player_cursor.warn = not self.board:is_swappable(left_gate, right_gate)
  end,

  _maybe_raise_gates = function(self)
    if self.tick == self.duration_raise_gates then
      if #self.board:gates_in_action() == 0 then
        self.dots_gates_raised += 1
        self.board:raise_one_dot()

        if self.dots_gates_raised == quantum_gate.size then
          if self.board:is_game_over() then
            self._state = "game over"
            self.player_cursor.game_over = true
          else
            self.dots_gates_raised = 0
            self.board:insert_gates_at_bottom()
            self.player_cursor:move_up()
            player.steps += 1
          end
        end
      end
      self.tick = 0
    end
  end,

  _create_gate_drop_particles = function(self)
    local bottommost_gates = self.board:bottommost_gates_of_fallen_gates()

    foreach(bottommost_gates, function(each)
      local x = self.board:screen_x(each.x)
      local y = self.board:screen_y(each.y)

      dropping_particle:create(x + flr(rnd(quantum_gate.size)), y + quantum_gate.size, 1, colors.white)
      dropping_particle:create(x + flr(rnd(quantum_gate.size)), y + quantum_gate.size, 1, colors.white)
      dropping_particle:create(x + flr(rnd(quantum_gate.size)), y + quantum_gate.size, 1, colors.white)
    end)

    if #bottommost_gates > 0 then
      sfx(self._sfx.gate_drop)
    end  
  end,

  _create_gate_puff_particles = function(self)
    foreach(self.board:gates_to_puff(), function(each)
      local x = self.board:screen_x(each.x) + 3
      local y = self.board:screen_y(each.y) + 3

      puff_particle:create(x, y, 3, colors.blue)
      puff_particle:create(x, y, 3, colors.blue)
      puff_particle:create(x, y, 2, colors.blue)
      puff_particle:create(x, y, 2, colors.blue)
      puff_particle:create(x, y, 2, colors.blue)
      puff_particle:create(x, y, 2, colors.blue)
      puff_particle:create(x, y, 2, colors.blue)
      puff_particle:create(x, y, 2, colors.light_grey)
      puff_particle:create(x, y, 1, colors.blue)
      puff_particle:create(x, y, 1, colors.blue)
      puff_particle:create(x, y, 1, colors.light_grey)
      puff_particle:create(x, y, 1, colors.light_grey)
      puff_particle:create(x, y, 0, colors.dark_purple)

      sfx(self._sfx.puff)
    end)
  end,

  draw_scores = function(self)
    cursor(60, 17)
    color(colors.white)
    print(player.steps .. " steps")
  end,

  draw_stats = function(self)
    local cpu_usage = stat(1)
    local cpu_usage_color = colors.green
    if cpu_usage >= 1 then
      cpu_usage_color = colors.red
    end

    local fps = stat(7)
    local fps_color = colors.green
    if fps < 60 then
      fps_color = colors.red
    end

    cursor(2, 116)
    color(fps_color)
    print("fps: " .. fps .. "/60")

    cursor(50, 116)
    color(cpu_usage_color)
    print("cpu: " .. cpu_usage)
  end, 
}