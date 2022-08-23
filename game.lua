game = {
  button = {
    left = 0,
    right = 1,
    up = 2,
    down = 3,
    x = 4,
    o = 5,
  },

  sfx = {
    move_cursor = 0,
    gate_drop = 1,
    swap = 2,
    puff = 3,
    match = 4,
    garbage_drop = 5,
  },

  init = function(self)
    self.state_machine = state_machine:new()
    self.board = board:new(18, 3)
    self.board:initialize_with_random_gates()
    self.player_cursor = player_cursor:new(self.board)
    self.tick = 0
    self.duration_raise_gates = 30 -- 0.5 seconds
    self.z_pushed = false

    self.state_machine:add_state(
      "start",

      -- transition function
      function(g)
        if btn(game.button.x) then
          g.z_pushed = true
        elseif self.z_pushed then
          g.z_pushed = false
          return "solo"
        end

        return "start"
      end,
  
      -- update function
      function(g)
        -- nop
      end,

      -- draw function
      function(g)
        cls()
        print("qitaev", 50, 40, colors.white)
        print("push ❎ or z to start", 24, 70, colors.green)
      end    
    )

    self.state_machine:add_state(
      "solo",

      -- transition function
      function(g)
        if (g.board.raised_dots == quantum_gate.size) and g.board:is_game_over() then
          return "game over"
        end
        return "solo"
      end,
  
      -- update function
      function(g)
        g:_handle_button_events()
        g.board:update()

        g:_create_gate_drop_particles()
        g:_create_gate_puff_particles()

        g:_maybe_change_cursor_color()
        g.player_cursor:update()

        if (g:_maybe_raise_gates()) then
          g:_maybe_add_garbage_unitary()
        end

        puff_particle:update()
        drop_particle:update()
        score_popup:update()

        g.tick += 1      
      end,

      -- draw function
      function(g)
        g.board:draw()
        g.player_cursor:draw()

        puff_particle:draw()
        drop_particle:draw()
        score_popup:draw()

        g:draw_scores()
        g:draw_stats()      
      end    
    )

    self.state_machine:add_state(
      "game over",

      -- transition function
      function()
        return "game over"
      end,
  
      -- update function
      function(g)
        if (btnp(game.button.o)) g:init()

        g.player_cursor.game_over = true
        g.board:update_gates()
        g.player_cursor:update()
      end,

      -- draw function
      function(g)

        g.board:draw()
        g.player_cursor:draw()

        puff_particle:draw()
        drop_particle:draw()

        g:draw_scores()

        rectfill(10, 47, 117, 70, colors.white)
        print("game over", 47, 52, colors.red)
        print("push 🅾️ or x to replay", 21, 62, colors.black)

        g:draw_stats()
      end
    )

    self.state_machine:set_state("start")
  end,

  update = function(self, board)
    self.state_machine:update(self)
  end,

  draw = function(self)
    cls()
    self.state_machine:draw(self)
  end,    

  -- private

  _handle_button_events = function(self)
    if btnp(game.button.left) then
      self.player_cursor:move_left()
      sfx(game.sfx.move_cursor)
    end

    if btnp(game.button.right) then
      self.player_cursor:move_right()
      sfx(game.sfx.move_cursor)
    end

    if btnp(game.button.up) then
      self.player_cursor:move_up()
      sfx(game.sfx.move_cursor)
    end

    if btnp(game.button.down) then
      self.player_cursor:move_down()
      sfx(game.sfx.move_cursor)
    end

    if btnp(game.button.x) then
      local swapped = self.board:swap(self.player_cursor.x, self.player_cursor.x + 1, self.player_cursor.y)
      if swapped == false then
        self.player_cursor.cannot_swap = true
      end
    end
  end,

  _maybe_change_cursor_color = function(self)
    self.player_cursor.cannot_swap = not self.board:is_swappable(self.player_cursor.x, self.player_cursor.x + 1, self.player_cursor.y)
  end,

  _maybe_raise_gates = function(self)
    if (self.tick != self.duration_raise_gates) return false

    self.tick = 0

    if (#self.board:gates_busy() > 0) return false

    self.board.raised_dots += 1

    if (self.board.raised_dots == quantum_gate.size) and
       (not self.board:is_game_over()) then
      self.board.raised_dots = 0
      self.board:insert_gates_at_bottom()
      self.player_cursor:move_up()
      player.steps += 1
    end

    return true
  end,

  _maybe_add_garbage_unitary = function(self)
    if (rnd(1) >= 0.1) return

    self.board:add_garbage_unitary()
  end,

  _create_gate_drop_particles = function(self)
    local bottommost_gates = self.board:bottommost_gates_of_dropped_gates()

    foreach(bottommost_gates, function(each)
      local x = self.board:screen_x(each.x)
      local y = self.board:screen_y(each.y)

      drop_particle:create(x + flr(rnd(quantum_gate.size)), y + quantum_gate.size, 1, colors.white)
      drop_particle:create(x + flr(rnd(quantum_gate.size)), y + quantum_gate.size, 1, colors.white)
      drop_particle:create(x + flr(rnd(quantum_gate.size)), y + quantum_gate.size, 1, colors.white)
    end)

    if (#bottommost_gates > 0) sfx(self.sfx.gate_drop)
  end,

  _create_gate_puff_particles = function(self)
    foreach(self.board:gates_to_puff(), function(each)
      local x = self.board:screen_x(each.x) + 3
      local y = self.board:screen_y(each.y) + 3

      puff_particle:create(x, y, 3, colors.white)
      puff_particle:create(x, y, 3, colors.white)
      puff_particle:create(x, y, 2, colors.white)
      puff_particle:create(x, y, 2, colors.white)
      puff_particle:create(x, y, 2, colors.white)
      puff_particle:create(x, y, 2, colors.white)
      puff_particle:create(x, y, 2, colors.white)
      puff_particle:create(x, y, 2, colors.light_grey)
      puff_particle:create(x, y, 1, colors.white)
      puff_particle:create(x, y, 1, colors.white)
      puff_particle:create(x, y, 1, colors.light_grey)
      puff_particle:create(x, y, 1, colors.light_grey)
      puff_particle:create(x, y, 0, colors.dark_purple)

      sfx(self.sfx.puff)
    end)
  end,

  draw_scores = function(self)
    cursor(60, 17)
    color(colors.white)
    print(player.steps .. " steps")

    cursor(60, 25)
    color(colors.white)
    if player.score == 0 then
      print("score " .. player.score)
    else
      print("score " .. player.score .. "00")
    end
  end,

  draw_stats = function(self)
    local cpu_usage = stat(1)
    local cpu_usage_color = colors.green
    if (cpu_usage >= 1) cpu_usage_color = colors.red

    local fps = stat(7)
    local fps_color = colors.green
    if (fps < 60) fps_color = colors.red

    cursor(2, 116)
    color(fps_color)
    print("fps: " .. fps .. "/60")

    cursor(50, 116)
    color(cpu_usage_color)
    print("cpu: " .. cpu_usage)
  end, 
}