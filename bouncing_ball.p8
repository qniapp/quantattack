pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
function _init()
 board = {}
 board_cols = 6
 board_rows = 12
 board_offset_x = 10
 board_offset_y = 10
 for x = 1, board_cols do
  board[x] = {}
 end

 board_dy = 0
 
 sprite_size = 8
 gate_top_y = 10

 garbage = nil

 --
 --  *  *
 -- ******
 -- 
 board[1][12] = "*"
 board[2][11] = "*"
 board[2][12] = "*"
 board[4][12] = "*"
 board[4][11] = "*"
 board[4][10] = "*"
 board[5][11] = "*"
 board[5][12] = "*"
 board[6][12] = "*"
end

function drop_garbage()
 return {
  y = screen_y(1),
  dy = 16,
  ddy = 0,
  dy_loss = 0.5,
  hit_gate = false,
  hit_bottom = false,
  update_y = function(self)
   self.y_prev = self.y
   self.y += self.dy
  end,
  update_dy = function(self)
   if (self.hit_bottom) then 
    self.dy += self.ddy
   end
  end,
  is_dropped = function(self)
   return self.y == screen_y(gate_top_y - 1) and (self.y == self.y_prev)
  end,
 }
end

function _update60()
 if btnp(4) and garbage == nil then
  garbage = drop_garbage()
 end

 if (garbage == nil) return

 if garbage:is_dropped() then
  garbage = nil
  gate_top_y -= 1
  for x = 1, board_cols do
   board[x][gate_top_y] = "g"
  end
  return
 end

 garbage:update_y()

 if not garbage.hit_bottom then
  if garbage.dy < 0.1 then
   garbage.hit_bottom = true
   garbage.dy = 40
  end

  if garbage.y > screen_y(gate_top_y) then
   garbage.hit_gate = true
   garbage.ddy = 0.98
   garbage.dy = garbage.dy * 0.3
  end
 else
  if garbage.y > screen_y(gate_top_y) - sprite_size then
   garbage.y = screen_y(gate_top_y) - sprite_size
   garbage.dy = -garbage.dy * garbage.dy_loss
  end
 end

 if garbage.hit_gate then
  board_dy = garbage.y - screen_y(gate_top_y) + sprite_size
 end

 garbage:update_dy()
end

function _draw()
 cls()

 -- draw existing gates
 for x = 1, board_cols do
  for y = 1, board_rows do
   if board[x][y] == "*" then
    draw_gate(16, x, y, board_dy)
   end
   if board[x][y] == "g" then
    local spr_id = 1
    if (x == 1) spr_id = 0
    if (x == board_cols) spr_id = 2
    draw_gate(spr_id, x, y, board_dy)
   end
  end
 end

 -- draw garbage unitary
 if (garbage != nil) then
  for x = 1, board_cols do
   local spr_id = 1
   if (x == 1) spr_id = 0
   if (x == board_cols) spr_id = 2
   spr(spr_id, screen_x(x), garbage.y)
  end
 end

 -- draw board borders
 line(board_offset_x - 2, board_offset_y,
      board_offset_x - 2, screen_y(board_rows + 1),
      7) -- left
 line(board_offset_x - 1, screen_y(board_rows + 1),
      board_offset_x + board_cols * sprite_size - 1, screen_y(board_rows + 1),
      7) -- bottom
 line(board_offset_x + board_cols * sprite_size, board_offset_y,
      board_offset_x + board_cols * sprite_size, screen_y(board_rows + 1),
      7) -- right
 rectfill(board_offset_x - 1, screen_y(board_rows + 1) + 1,
          board_offset_x + board_cols * sprite_size - 1, 127,
          0) -- mask
end

function draw_gate(spr_id, x, y, dy)
 spr(spr_id, screen_x(x), screen_y(y) + (dy or 0))
end

function screen_x(x)
 return board_offset_x + (x - 1) * sprite_size
end

function screen_y(y)
 return board_offset_y + (y - 1) * sprite_size
end

__gfx__
07777777777777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77ddddddddddddddddddd77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d7777777777777777777d7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d7777777777777777777d7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d7777777777777777777d7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77ddddddddddddddddddd77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777777777777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbbb30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbbb30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbbb30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbbb30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbbb30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
