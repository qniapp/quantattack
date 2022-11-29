require("engine/test/bustedhelper")
require("lib/helpers")

local foo_class = new_class()

function foo_class:_init()
  self.state = ":idle"
end

function foo_class:bar()
  local _ENV = self -- self を省略したいとき

  printh("state = " .. state)
end

describe('self を省略できる #solo', function()
  it('呼び出された側で self. を省略できる', function()
    local foo = foo_class()
    assert.has_no.errors(function() foo:bar() end)
  end)
end)
