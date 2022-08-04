
function test(title, f)
  local desc = function(msg, f)
    printh('✽:desc:' .. msg)
    f()
  end

  local it = function(msg, f)
    printh('✽:it:' .. msg)
    local xs = {f()}
    for i =1, #xs do
      if xs[i] == true then
        printh('✽:assert:true')
      else
        print("it " .. msg)
        assert(false)
        printh('✽:assert:false')
      end
    end
    printh('✽:it_end')
  end

  printh('✽:test:' .. title)
  print(title)
  f(desc, it)
  printh('✽:test_end')
end
