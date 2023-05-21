---@diagnostic disable: lowercase-global

--- ブロックのマッチパターン
reduction_rules = transform(
  transform(
  -- NOTE: ルールの行数を昇り順にならべておくことで、
  -- マッチする時に途中で探索を切り上げることができるようにする
    {
      h =
      "h\nh|,,\n,-1,|10&h\nx\nh|,,\n,-1,\n,-2,z|20&h\ny\nh|,,\n,-1,\n,-2,y|20&h\nz\nh|,,\n,-1,\n,-2,x|20&h\nswap,swap\n?,h|,,\ntrue,-2,|50&h\nx\nswap,swap\n?,h|,,\n,-1,z\ntrue,-3,|60&h\ny\nswap,swap\n?,h|,,\n,-1,y\ntrue,-3,|60&h\nswap,swap\n?,x\n?,h|,,z\ntrue,-2,\ntrue,-3,|60&h\nswap,swap\n?,y\n?,h|,,y\ntrue,-2,\ntrue,-3,|60&h\nz\nswap,swap\n?,h|,,\n,-1,x\ntrue,-3,|60&h\nswap,swap\n?,z\n?,h|,,x\ntrue,-2,\ntrue,-3,|60",
      x =
      "x\nx|,,\n,-1,|10&x,x\ncontrol,cnot_x\nx|,,\ntrue,,\n,-2,|90&x,x\ncnot_x,control\nx|,,\ntrue,,\n,-2,|90&x\ncnot_x,control\nx|,,\n,-2,|80&x\nswap,swap\n?,x|,,\ntrue,-2,|50",
      y =
      "y\ny|,,\n,-1,|10&y\nswap,swap\n?,y|,,\ntrue,-2,|50&y,x\ncontrol,cnot_x\ny|,,\ntrue,,\n,-2,|90&y,z\ncnot_x,control\ny|,,\ntrue,,\n,-2,|90",
      z =
      "z\nz|,,\n,-1,|10&z,z\ncontrol,cnot_x\n?,z|,,\ntrue,,\ntrue,-2,|90&z\ncontrol,cnot_x\nz|,,\n,-2,|80&z\nswap,swap\n?,z|,,\ntrue,-2,|50",
      s =
      "s\ns|,,\n,-1,z|10&s\nx\ns|,,\n,-1,\n,-2,x|20&s\ny\ns|,,\n,-1,\n,-2,y|20&s\nz\ns|,,\n,-1,\n,-2,|20&s\nswap,swap\n?,s|,,z\ntrue,-2,|50&s\nx\nswap,swap\n?,s|,,\n,-1,x\ntrue,-3,|60&s\ny\nswap,swap\n?,s|,,\n,-1,y\ntrue,-3,|60&s\nz\nswap,swap\n?,s|,,\n,-1,\ntrue,-3,|60&s\nswap,swap\n?,x\n?,s|,,x\ntrue,-2,\ntrue,-3,|60&s\nswap,swap\n?,y\n?,s|,,y\ntrue,-2,\ntrue,-3,|60&s\nswap,swap\n?,z\n?,s|,,\ntrue,-2,\ntrue,-3,|60",
      t =
      "t\nt|,,\n,-1,s|10&t\ns\nt|,,\n,-1,\n,-2,z|20&t\nswap,swap\n?,t|,,s\ntrue,-2,|50&t\nz\ns\nt|,,\n,-1,\n,-2,\n,-3,|30&t\ns\nz\nt|,,\n,-1,\n,-2,\n,-3,|30&t\ns\nswap,swap\n?,t|,,\n,-1,z\ntrue,-3,|60&t\nswap,swap\n?,s\n?,t|,,z\ntrue,-2,\ntrue,-3,|60&t\nswap,swap\n?,z\n?,s\n?,t|,,\ntrue,-2,\ntrue,-3,\ntrue,-4,|70&t\nswap,swap\n?,s\n?,z\n?,t|,,\ntrue,-2,\ntrue,-3,\ntrue,-4,|70&t\nz\nswap,swap\n?,s\n?,t|,,\n,-1,\ntrue,-3,\ntrue,-4,|70&t\ns\nswap,swap\n?,z\n?,t|,,\n,-1,\ntrue,-3,\ntrue,-4,|70&t\nz\ns\nswap,swap\n?,t|,,\n,-1,\n,-2,\ntrue,-4,|70&t\ns\nz\nswap,swap\n?,t|,,\n,-1,\n,-2,\ntrue,-4,|70",
      control = "control,cnot_x\nswap,swap\ncnot_x,control|,,\ntrue,,\n,-2,\ntrue,-2,|200",
      cnot_x =
      "cnot_x,control\ncnot_x,control|,,\ntrue,,\n,-1,\ntrue,-1,|40&cnot_x,control\ncontrol,cnot_x\ncnot_x,control|,,\ntrue,,\n,-1,\ntrue,-1,\n,-2,swap\ntrue,-2,swap|100",
      swap = "swap,swap\nswap,swap|,,\ntrue,,\n,-1,\ntrue,-1,|300"
    },
    function(rule_string) return split(rule_string, "&") end),
  function(gate_rules)
    return transform(
      gate_rules,
      function(each)
        local pattern, reduce_to, score = unpack(split(each, "|"))

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
          tonum(score)
        }
      end
    )
  end
)
