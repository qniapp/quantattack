---@diagnostic disable: lowercase-global

---
-- パーティクルを表示

particles = derived_class(effect_set)()

--- パーティクルの集合を作る
function particles:create(coord, data)
  foreach(split(data, "|"), function(each)
    radius, end_radius, particle_color, particle_color_fade, dx, dy, ddx, ddy, max_tick = unpack_split(each)

    self:_add(function(_ENV)
      _x, _y, _dx, _dy, _radius, _end_radius, _color, _color_fade, _tick, _max_tick, _ddx, _ddy =
          coord[1], coord[2], dx == "" and rnd(1) or dx, dy == "" and rnd(1) or dy, radius, end_radius, particle_color,
          particle_color_fade,
          0, max_tick + rnd(10), ddx, ddy

      if dx == "" then
        -- move to the left
        if ceil_rnd(2) == 1 then
          _dx, _ddx = _dx * -1, _ddx * -1
        end

        -- move upwards
        if ceil_rnd(2) == 1 then
          _dy, _ddy = _dy * -1, _ddy * -1
        end
      end
    end)
  end)
end

--- パーティクルの位置等を更新
function particles._update(_ENV, all)
  if _tick > _max_tick then
    del(all, _ENV)
  end
  if _tick > _max_tick * .5 then
    _color, _radius = _color_fade, _end_radius
  end

  _x, _y, _dx, _dy, _tick = _x + _dx, _y + _dy, _dx + _ddx, _dy + _ddy, _tick + 1
end

--- パーティクルを描画。
function particles._render(_ENV)
  circfill(_x, _y, _radius, _color)
end
