pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
#include colors.lua
#include dropping_particle.lua
#include game.lua
#include player_cursor.lua
#include quantum_gate.lua
#include board.lua
#include puff_particle.lua
#include gate_reduction_rules.lua

function test(title,f)
  local desc=function(msg,f)
    printh('✽:desc:'..msg)
    f()
  end

  local it=function(msg,f)
    printh('✽:it:'..msg)
    local xs={f()}
    for i=1,#xs do
      if xs[i] == true then
        printh('✽:assert:true')
      else
        printh('✽:assert:false')
      end
    end
    printh('✽:it_end')
  end

  printh('✽:test:'..title)
  f(desc,it)
  printh('✽:test_end')
end

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
    local player_board = board:new()

    it('should be initialized with id gates', function ()
      result = true

      for x = 1, player_board.cols do
        for y = 1, player_board.rows_plus_next_rows do
          result = result and player_board.gate[x][y]:is_i()
        end
      end

      return result
    end)      
  end)  
end)

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
