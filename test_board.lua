
test('board', function(desc,it)
  desc('cols', function()
    it('should be 6', function()
      return board:new().cols == 6
    end)
  end)

  desc('rows', function()
    it('should be 13', function()
      return board:new().rows_plus_next_rows == 13
    end)
  end)

  desc('rows_plus_next_rows', function()
    it('should be 12', function()
      return board:new().rows == 12
    end)
  end)

  desc("top", function()
    it('should be 0 by default', function()
      return board:new().top == 0
    end)
  end)

  desc("left", function()
    it('should be 0 by default', function()
      return board:new().left == 0
    end)
  end)

  desc('new', function ()
    it('should be initialized with id gates', function ()
      local player_board = board:new()
      local result = true

      for x = 1, player_board.cols do
        for y = 1, player_board.rows_plus_next_rows do
          result = result and player_board:gate_at(x, y):is_i()
        end
      end

      return result
    end)      
  end)  
end)
