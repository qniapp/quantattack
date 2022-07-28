pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
global = {}

-- gates
global["gates"] = {"h", "x", "y", "z", "s", "t", "i"}

global["grid_sprite"] = {}
global["grid_sprite"]["h"] = 0
global["grid_sprite"]["x"] = 1
global["grid_sprite"]["y"] = 2
global["grid_sprite"]["z"] = 3
global["grid_sprite"]["s"] = 4
global["grid_sprite"]["t"] = 5
global["grid_sprite"]["i"] = 6

-- grid
global["grid"] = {}
global["cols"] = 10
global["rows"] = 10

-- cursor position
global["cursor_x"] = 5
global["cursor_y"] = 5

-- colors
global["bg_color"] = 0
global["cursor_color"] = 10

function move_cursor()
 -- left
 if btnp(0) then
  if global.cursor_x >= 2 then
   global.cursor_x -= 1
  end
 end

 -- right
 if btnp(1) then
  if global.cursor_x <= 8 then 
   global.cursor_x += 1
  end
 end

 -- up
 if btnp(2) then
  if global.cursor_y > 1 then
   global.cursor_y -= 1
  end 
 end

 -- down
 if btnp(3) then
  if global.cursor_y < 10 then
   global.cursor_y += 1
  end
 end

 -- swap
 if (btnp(4)) then
  left_gate = global.grid[global.cursor_x][global.cursor_y]
  right_gate = global.grid[global.cursor_x + 1][global.cursor_y]
  global.grid[global.cursor_x][global.cursor_y] = right_gate
  global.grid[global.cursor_x + 1][global.cursor_y] = left_gate
 end
end

function random_gate_id()
 return flr(rnd(#global.gates - 1)) + 1
end

function reduceable(name, x, y)
 -- h  x  y  z    i
 -- h, x, y, z -> i
 --
 -- s
 -- s -> z
 --
 -- t
 -- t -> s
 if (global.grid[x][y + 1] == name) then return true end

 -- z
 -- x -> y
 if (name == "z" and global.grid[x][y + 1] == "x") then return true end
 -- x
 -- z -> y
 if (name == "x" and global.grid[x][y + 1] == "z") then return true end

 -- h
 -- x
 -- h -> z
 if (y + 2 <= global.rows and name == "h" and global.grid[x][y + 1] == "x" and global.grid[x][y + 2] == "h") then return true end
 -- h
 -- z
 -- h -> x
 if (y + 2 <= global.rows and name == "h" and global.grid[x][y + 1] == "z" and global.grid[x][y + 2] == "h") then return true end
 -- s
 -- z
 -- s -> z
 if (y + 2 <= global.rows and name == "s" and global.grid[x][y + 1] == "z" and global.grid[x][y + 2] == "s") then return true end

 return false
end

function random_gate(x,y)
 repeat
  id = random_gate_id()
  name = global.gates[id]
 until (not reduceable(name, x, y))

 return name
end

function init_grid()
 for x = 1,global.cols,1 do
  global.grid[x] = {}
  for y = global.rows,1,-1 do
   global.grid[x][y] = random_gate(x,y)
  end
 end 
end

function draw_top_empty_step()
 for x = 1,global.cols,1 do
  sprite_id = 6 -- todo: define wire sprite id
  spr(sprite_id, x*8, 8)
 end
end

function draw_grid()
 for x,col in pairs(global.grid) do
  for y,gate in pairs(col) do
   sprite = global.grid_sprite[gate]
   spr(sprite, x*8, y*8+8)
  end
 end
end

function draw_zero_kets()
 for x = 1,global.cols do
  sprite_id = 16 -- todo: define global zero ket sprite id
  spr(sprite_id, x*8, (global.rows + 2)*8)
 end
end

function clear_screen()
 rectfill(0,0,127,127,global.bg_color)
end

function draw_cursor()
 rectx = global.cursor_x * 8 - 1
 recty = (global.cursor_y + 1) * 8 - 1
 rect(rectx,recty,rectx+16,recty+8,global.cursor_color)
end

function reduce_gates()
 num_reduced = 0

 for x = 1,global.cols,1 do
  for y = global.rows-1,1,-1 do
   if (global.grid[x][y] == "h" and global.grid[x][y+1] == "h") then
    global.grid[x][y] = "i"
    global.grid[x][y+1] = "i"
    num_reduced += 2
   end
   if (global.grid[x][y] == "x" and global.grid[x][y+1] == "x") then
    global.grid[x][y] = "i"
    global.grid[x][y+1] = "i"
    num_reduced += 2
   end   
   if (global.grid[x][y] == "y" and global.grid[x][y+1] == "y") then
    global.grid[x][y] = "i"
    global.grid[x][y+1] = "i"
    num_reduced += 2
   end 
   if (global.grid[x][y] == "z" and global.grid[x][y+1] == "z") then
    global.grid[x][y] = "i"
    global.grid[x][y+1] = "i"
    num_reduced += 2
   end
   if (global.grid[x][y] == "s" and global.grid[x][y+1] == "s") then
    global.grid[x][y] = "i"
    global.grid[x][y+1] = "z"
    num_reduced += 1
   end
   if (global.grid[x][y] == "t" and global.grid[x][y+1] == "t") then
    global.grid[x][y] = "i"
    global.grid[x][y+1] = "s"
    num_reduced += 1
   end    
   if (global.grid[x][y] == "z" and global.grid[x][y+1] == "x") then
    global.grid[x][y] = "i"
    global.grid[x][y+1] = "y"
    num_reduced += 1
   end
   if (global.grid[x][y] == "x" and global.grid[x][y+1] == "z") then
    global.grid[x][y] = "i"
    global.grid[x][y+1] = "y"
    num_reduced += 1
   end
   -- hxh -> z
   if (y+2 <= global.rows and global.grid[x][y] == 'h' and global.grid[x][y+1] == 'x' and global.grid[x][y+2] == 'h') then
    global.grid[x][y] = 'i'
    global.grid[x][y+1] = 'i'
    global.grid[x][y+2] = 'z'
    num_reduced += 2
   end
   -- hzh -> x
   if (y+2 <= global.rows and global.grid[x][y] == 'h' and global.grid[x][y+1] == 'z' and global.grid[x][y+2] == 'h') then
    global.grid[x][y] = 'i'
    global.grid[x][y+1] = 'i'
    global.grid[x][y+2] = 'x'
    num_reduced += 2
   end
   -- szs -> z
   if (y+2 <= global.rows and global.grid[x][y] == 's' and global.grid[x][y+1] == 'z' and global.grid[x][y+2] == 's') then
    global.grid[x][y] = 'i'
    global.grid[x][y+1] = 'i'
    global.grid[x][y+2] = 'z'
    num_reduced += 2
   end  
  end
 end

 return num_reduced
end

function drop_gates()
 for x = 1,global.cols,1 do
  for y = global.rows-1,1,-1 do
   if (global.grid[x][y+1] == "i") then
    global.grid[x][y+1] = global.grid[x][y]
    global.grid[x][y] = "i"
   end
  end
 end
end

function _init()
 init_grid()
end

function _update()
 move_cursor()
 repeat
  num_reduced_gates = reduce_gates()
  drop_gates()
 until (num_reduced_gates == 0)
end

function _draw()
 clear_screen()
 draw_top_empty_step()
 draw_grid()
 draw_zero_kets()
 draw_cursor()
end	

__gfx__
33333330003330003333333033333330444444402222222000050000000000000000000000000000000000000000000000000000000000000000000000000000
37333730033733003733373037777730447777402777772000050000000000000000000000000000000000000000000000000000000000000000000000000000
37333730333733303373733033337330474444402227222000050000000000000000000000000000000000000000000000000000000000000000000000000000
37777730377777303337333033373330447774402227222000050000000000000000000000000000000000000000000000000000000000000000000000000000
37333730333733303337333033733330444447402227222000050000000000000000000000000000000000000000000000000000000000000000000000000000
37333730033733003337333037777730477774402227222000050000000000000000000000000000000000000000000000000000000000000000000000000000
33333330003330003333333033333330444444402222222000050000000000000000000000000000000000000000000000000000000000000000000000000000
00050000000500000005000000050000000500000005000000050000000000000000000000000000000000000000000000000000000000000000000000000000
00050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06606600003330000333330003333300033333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60000060033733000373730003777300037773000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777000037773000337330003373300033733000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07000700033733000337330003777300037773000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777000003330000333330003333300033333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
