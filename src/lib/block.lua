---@diagnostic disable: global-in-nil-env, lowercase-global, unbalanced-assignments, undefined-field, undefined-global

--- @class block_class
--- @field type "i" | "h" | "x" | "y" | "z" | "s" | "t" | "control" | "cnot_x" | "swap" | "g" | "?" block type
--- @field span 1 | 2 | 3 | 4 | 5 | 6 span of the block
--- @field height integer height of the block
--- @field render function
--- @field replace_with function
--- @field new_block block_class
--- @field change_state function
block_class = new_class()
block_class.block_match_animation_frame_count = 45
block_class.block_match_delay_per_block = 8
block_class.block_swap_animation_frame_count = 3
block_class.sprites = transform({
  -- default|landing|match
  h = "0|1,1,1,2,2,2,3,3,1,1,1,1|24,24,24,25,25,25,24,24,24,26,26,26,0,0,0,27",
  x = "16|17,17,17,18,18,18,19,19,17,17,17,17|40,40,40,41,41,41,40,40,40,42,42,42,16,16,16,43",
  y = "32|33,33,33,34,34,34,35,35,33,33,33,33|56,56,56,57,57,57,56,56,56,58,58,58,32,32,32,59",
  z = "48|49,49,49,50,50,50,51,51,49,49,49,49|12,12,12,13,13,13,12,12,12,14,14,14,48,48,48,15",
  s = "4|5,5,5,6,6,6,7,7,5,5,5,5|28,28,28,29,29,29,28,28,28,30,30,30,4,4,4,31",
  t = "20|21,21,21,22,22,22,23,23,21,21,21,21|44,44,44,45,45,45,44,44,44,46,46,46,20,20,20,47",
  control = "36|37,37,37,38,38,38,39,39,37,37,37,37|60,60,60,61,61,61,60,60,60,62,62,62,36,36,36,63",
  cnot_x = "52|53,53,53,54,54,54,55,55,53,53,53,53|64,64,64,65,65,65,64,64,64,66,66,66,52,52,52,67",
  swap = "8|9,9,9,10,10,10,11,11,9,9,9,9|80,80,80,81,81,81,80,80,80,82,82,82,8,8,8,83",
  ["?"] = "98|98,98,98,98,98,98,98,98,98,98,98,98|98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98",
  ["#"] = "113|113,113,113,113,113,113,113,113,113,113,113,113|113,113,113,113,113,113,113,113,113,113,113,113,113,113,113,113"
}, function(each)
  local default, landing, match = unpack(split(each, "|"))
  return {
    default = default,
    landing = split(landing),
    match = split(match)
  }
end)

--- @param _type "i" | "h" | "x" | "y" | "z" | "s" | "t" | "control" | "cnot_x" | "swap" | "g" | "?" block type
--- @param _span? 1 | 2 | 3 | 4 | 5 | 6 span of the block
--- @param _height? integer height of the block
function block_class._init(_ENV, _type, _span, _height)
  type, sprite_set, span, height, _state, _timer_landing = _type, sprites[_type], _span or 1, _height or 1, "idle", 0
end

-------------------------------------------------------------------------------
-- ブロックの種類と状態
-------------------------------------------------------------------------------

function block_class:is_idle()
  return self._state == "idle"
end

function block_class:is_hover()
  return self._state == "hover"
end

function block_class.is_fallable(_ENV)
  return not (type == "i" or type == "?" or is_swapping(_ENV) or is_freeze(_ENV))
end

function block_class:is_falling()
  return self._state == "falling"
end

function block_class.is_reducible(_ENV)
  return type ~= "i" and type ~= "?" and is_idle(_ENV)
end

function block_class:is_match()
  return self._state == "match"
end

-- おじゃまブロックが小さいブロックに分解した後の硬直中かどうか
function block_class:is_freeze()
  return self._state == "freeze"
end

function block_class:is_swapping()
  return self:_is_swapping_with_right() or self:_is_swapping_with_left()
end

--- @private
function block_class:_is_swapping_with_left()
  return self._state == "swapping_with_left"
end

--- @private
function block_class:_is_swapping_with_right()
  return self._state == "swapping_with_right"
end

function block_class:is_swappable_state()
  return self:is_idle() or self:is_falling()
end

function block_class:is_empty()
  return self.type == "i" and not self:is_swapping()
end

function block_class.is_single_block(_ENV)
  return type == 'h' or type == 'x' or type == 'y' or type == 'z' or type == 's' or type == 't'
end

-------------------------------------------------------------------------------
-- ブロック操作
-------------------------------------------------------------------------------

--- @param direction "left" | "right"
function block_class:swap_with(direction)
  self.chain_id = nil
  self:change_state("swapping_with_" .. direction)
end

function block_class:hover(timer)
  self.timer = timer or 12
  self:change_state("hover")
end

function block_class:fall()
  --#if assert
  assert(self:is_fallable(), "block " .. self.type .. "(" .. self.x .. ", " .. self.y .. ")")
  --#endif

  if self:is_falling() then
    return
  end

  self:change_state("falling")
end

--- @param other block_class
--- @param match_index integer
--- @param _chain_id string
--- @param garbage_span? integer
--- @param garbage_height? integer
function block_class.replace_with(_ENV, other, match_index, _chain_id, garbage_span, garbage_height)
  new_block, _match_index, _tick_match, chain_id, other.chain_id, _garbage_span, _garbage_height =
  other, match_index or 0, 1, _chain_id, _chain_id, garbage_span, garbage_height

  change_state(_ENV, "match")
end

-------------------------------------------------------------------------------
-- update and render
-------------------------------------------------------------------------------

function block_class.update(_ENV)
  if is_idle(_ENV) then
    if _timer_landing > 0 then
      _timer_landing = _timer_landing - 1
    end
  elseif is_swapping(_ENV) then
    if _tick_swap < block_swap_animation_frame_count then
      _tick_swap = _tick_swap + 1
    else
      chain_id = nil
      change_state(_ENV, "idle")
    end
  elseif is_hover(_ENV) then
    if timer > 0 then
      timer = timer - 1
    else
      change_state(_ENV, "idle")
    end
  elseif is_match(_ENV) then
    if _tick_match <= block_match_animation_frame_count + _match_index * block_match_delay_per_block then
      _tick_match = _tick_match + 1
    else
      change_state(_ENV, "idle")

      if _garbage_span then
        new_block._tick_freeze = 0
        new_block._freeze_frame_count = (_garbage_span * _garbage_height - _match_index) * block_match_delay_per_block
        new_block:change_state("freeze")
      end
    end
  elseif is_freeze(_ENV) then
    if _tick_freeze < _freeze_frame_count then
      _tick_freeze = _tick_freeze + 1
    else
      change_state(_ENV, "idle")
    end
  end
end

--- @param screen_x integer x position of the screen
--- @param screen_y integer y position of the screen
function block_class:render(screen_x, screen_y)
  local shake_dx, shake_dy, swap_screen_dx, sprite = 0, 0

  do
    local _ENV = self

    if type == "i" then
      return
    end

    swap_screen_dx = (_tick_swap or 0) * (8 / block_swap_animation_frame_count)
    if _is_swapping_with_left(_ENV) then
      swap_screen_dx = -swap_screen_dx
    end

    if is_idle(_ENV) and _timer_landing > 0 then
      sprite = sprite_set.landing[_timer_landing]
    elseif is_match(_ENV) then
      local sequence = sprite_set.match
      sprite = _tick_match <= block_match_delay_per_block and sequence[_tick_match] or sequence[#sequence]
    elseif _state == "over" then
      sprite = sprite_set.match[#sprite_set.match]
    else
      sprite = sprite_set.default
    end
  end

  if self.type == "?" then
    palt(0, false)
    pal(13, self.body_color)
  end

  if self._state == "over" then
    shake_dx, shake_dy = rnd(2) - 1, rnd(2) - 1
    pal(6, 9)
    pal(7, 1)
  end

  spr(sprite, screen_x + swap_screen_dx + shake_dx, screen_y + shake_dy)

  pal()
end

-------------------------------------------------------------------------------
-- observer pattern
-------------------------------------------------------------------------------

--- @param observer table
function block_class:attach(observer)
  self.observer = observer
end

--- @param new_state string
function block_class.change_state(_ENV, new_state)
  _timer_landing, _tick_swap =
  is_falling(_ENV) and 12 or 0, 0

  local old_state = _state
  _state = new_state

  observer:observable_update(_ENV, old_state)
end

-------------------------------------------------------------------------------
-- debug
-------------------------------------------------------------------------------

--#if debug
local type_string = {
  i = '_',
  control = '●',
  cnot_x = '+',
  swap = 'X'
}

local state_string = {
  idle = " ",
  swapping_with_left = "<",
  swapping_with_right = ">",
  hover = "^",
  falling = "|",
  match = "*",
  freeze = "f",
}

function block_class:_tostring()
  return (type_string[self.type] or self.type:upper()) .. state_string[self._state]
end

--#endif
