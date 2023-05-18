---@diagnostic disable: lowercase-global

--- すべてのエフェクトのベースクラス
effect_set = new_class()

function effect_set:_init()
  self.all = {}
end

function effect_set:_add(f)
  local _ENV = setmetatable({}, { __index = _ENV })
  f(_ENV)
  add(self.all, _ENV)
end

function effect_set:update_all()
  foreach(self.all, function(each)
    self._update(each, self.all)
  end)
end

function effect_set:render_all()
  foreach(self.all, function(each)
    self._render(each)
  end)
end

--- 各種エフェクトを require する
-- TODO: require をなくす (1 つあたり 9 トークン減る)

require("lib/effects/bubbles")
require("lib/effects/ions")
require("lib/effects/particles")

--#ifn title
require("lib/effects/ripple")
--#endif

--#if endless
require("lib/effects/sash")
--#endif

--#if rush
require("lib/effects/sash")
--#endif
