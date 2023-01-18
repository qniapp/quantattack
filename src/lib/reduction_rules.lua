-- map function
local function transform(t, func)
  local transformed_t = {}
  for key, value in pairs(t) do
    transformed_t[key] = func(value)
  end
  return transformed_t
end

return transform(
  transform(
  -- NOTE: ルールの行数を昇り順にならべておくことで、
  -- マッチする時に途中で探索を切り上げることができるようにする
    {
      h = "h\nh|,,\n,-1,|2|&h\nx\nh|,,\n,-1,\n,-2,z|2|3&h\nz\nh|,,\n,-1,\n,-2,x|3|3&h,h\ncontrol,cnot_x\nh,h|,,\ntrue,,\n,-1,cnot_x\ntrue,-1,control\n,-2,\ntrue,-2,|6|10&h\nswap,swap\n?,h|,,\ntrue,-2,|2|5&h,z\ncnot_x,control\nh,z|true,,\ntrue,-2,|2|10&h\nx\nswap,swap\n?,h|,,\n,-1,z\ntrue,-3,|3|7&h\nswap,swap\n?,x\n?,h|,,z\ntrue,-2,\ntrue,-3,|3|7&h\nz\nswap,swap\n?,h|,,\n,-1,x\ntrue,-3,|3|7&h\nswap,swap\n?,z\n?,h|,,x\ntrue,-2,\ntrue,-3,|3|7",
      x = "x\nx|,,\n,-1,|2|&x\nz|,,\n,-1,y|2|2&x,x\ncontrol,cnot_x\nx|,,\ntrue,,\n,-2,|3|8&x\ncnot_x,control\nx|,,\n,-2,|2|6&x\nswap,swap\n?,x|,,\ntrue,-2,|2|5&x\nswap,swap\n?,z|,,y\ntrue,-2,|2|6&x\nh,z\ncnot_x,control\nh\nx|,,\ntrue,-1,\n,-4,|3|10",
      y = "y\ny|,,\n,-1,|2|&y\nswap,swap\n?,y|,,\ntrue,-2,|2|5",
      z = "z\nz|,,\n,-1,|2|&z\nx|,,\n,-1,y|2|2&z,z\ncontrol,cnot_x\n?,z|,,\ntrue,,\ntrue,-2,|3|8&z\ncontrol,cnot_x\nz|,,\n,-2,|2|6&z\nswap,swap\n?,z|,,\ntrue,-2,|2|5&z\nh,x\ncnot_x,control\nh,x|,,\ntrue,-1,\ntrue,-3,|3|10&z\nh\ncnot_x,control\nh\nz|,,\n,-4,|2|10",
      s = "s\ns|,,\n,-1,z|2|&s\nz\ns|,,\n,-1,\n,-2,z|3|3&s\nswap,swap\n?,s|,,z\ntrue,-2,|2|5&s\nz\nswap,swap\n?,s|,,\n,-1,z\ntrue,-3,|3|7&s\nswap,swap\n?,z\n?,s|,,z\ntrue,-2,\ntrue,-3,|3|7",
      t = "t\nt|,,\n,-1,s|2|&t\ns\nt|,,\n,-1,\n,-2,z|3|3&t\nswap,swap\n?,t|,,s\ntrue,-2,|2|5&t\nz\ns\nt|,,\n,-1,\n,-2,\n,-3,|4|4&t\ns\nz\nt|,,\n,-1,\n,-2,\n,-3,|4|4&t\ns\nswap,swap\n?,t|,,\n,-1,z\ntrue,-3,|3|7&t\nswap,swap\n?,s\n?,t|,,z\ntrue,-2,\ntrue,-3,|3|7&t\nswap,swap\n?,z\n?,s\n?,t|,,\ntrue,-2,\ntrue,-3,\ntrue,-4,|4|8&t\nswap,swap\n?,s\n?,z\n?,t|,,\ntrue,-2,\ntrue,-3,\ntrue,-4,|4|8",
      control = "control,cnot_x\nswap,swap\ncnot_x,control|,,\ntrue,,\n,-2,\ntrue,-2,|4|10",
      cnot_x = "cnot_x,control\ncnot_x,control|,,\ntrue,,\n,-1,\ntrue,-1,|4|5&cnot_x,control\ncontrol,cnot_x\ncnot_x,control|,,\ntrue,,\n,-1,\ntrue,-1,\n,-2,swap\ntrue,-2,swap|6|10",
      swap = "swap,swap\nswap,swap|,,\ntrue,,\n,-1,\ntrue,-1,|4|30"
    },
    function(rule_string) return split(rule_string, "&") end),
  function(gate_rules)
    return transform(
      gate_rules,
      function(each)
        local pattern, reduce_to, block_count, score = unpack(split(each, "|"))

        return {
          transform(split(pattern, "\n"), split),
          transform(split(reduce_to, "\n"), function(to)
            local attrs = split(to)
            return {
              dx = attrs[1] ~= "",
              dy = attrs[2] == "" and nil or tonum(attrs[2]),
              block_type = attrs[3] == "" and 'i' or attrs[3]
            }
          end),
          tonum(block_count),
          tonum(score),
          each -- original string
        }
      end
    )
  end
)
