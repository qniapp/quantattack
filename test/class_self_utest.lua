require("engine/test/bustedhelper")
require("lib/helpers")

global_variable = "global_variable"
local foo_class = new_class()

function foo_class:_init()
  self.state = "idle"
end

-- self を省略したいときの書きかた
function foo_class.access_instance_variable(_ENV)
  local foo = "state = " .. state
end

-- こちらは失敗
function foo_class.access_global_variable(_ENV)
  printh("global_variable = " .. global_variable)
end

describe('self を省略できる', function()
  it('呼び出された側で self. を省略できる', function()
    local foo = foo_class()
    assert.has_no.errors(function() foo:access_instance_variable() end)
    assert.has.errors(function() foo:access_global_variable() end)
  end)
end)
