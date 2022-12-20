---@diagnostic disable: lowercase-global

local high_score_class = require("lib/high_score")

-- TODO: 引数の整理とリファクタリング
--- @class menu_item
--- @field target_state string
--- @field sx integer
--- @field sy integer
--- @field width integer
--- @field height integer
--- @field load_param string
--- @field label string
--- @field description string
--- @field high_score integer
local menu_item = new_class()

--- @param _target_state string
--- @param _sx integer
--- @param _sy integer
--- @param _width integer
--- @param _height integer
--- @param _load_param string
--- @param _label string
--- @param _description string
--- @param _high_score_slot integer
function menu_item:_init(_target_state, _sx, _sy, _width, _height, _load_param, _label, _description, _high_score_slot)
  local _ENV = self

  target_state, sx, sy, width, height, load_param, label, description, high_score =
  _target_state, _sx, _sy, _width, _height, _load_param, _label, _description,
      _high_score_slot and high_score_class(_high_score_slot):get() * 10
end

return menu_item
