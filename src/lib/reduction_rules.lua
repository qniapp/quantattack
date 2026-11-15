---@diagnostic disable: lowercase-global

--- ブロックのマッチパターン
reduction_rules = transform(
  -- NOTE: ルールの行数を昇り順にならべておくことで、
  -- マッチする時に途中で探索を切り上げることができるようにする
    {
      h =
      "h\nh|,,\n,-1,|10&h\nx\nh|,,z\n,-1,\n,-2,|20&h\ny\nh|,,y\n,-1,\n,-2,|20&h\nz\nh|,,x\n,-1,\n,-2,|20&h\nswap,swap\n?,h|,,\ntrue,-2,|50&h\nx\nswap,swap\n?,h|,,z\n,-1,\ntrue,-3,|60&h\ny\nswap,swap\n?,h|,,y\n,-1,\ntrue,-3,|60&h\nswap,swap\n?,x\n?,h|,,z\ntrue,-2,\ntrue,-3,|60&h\nswap,swap\n?,y\n?,h|,,y\ntrue,-2,\ntrue,-3,|60&h\nz\nswap,swap\n?,h|,,x\n,-1,\ntrue,-3,|60&h\nswap,swap\n?,z\n?,h|,,x\ntrue,-2,\ntrue,-3,|60",
      x =
      "x\nx|,,\n,-1,|10&x,x\ncontrol,cnot_x\nx|,,\ntrue,,\n,-2,|90&x,x\ncnot_x,control\nx|,,\ntrue,,\n,-2,|90&x\ncnot_x,control\nx|,,\n,-2,|80&x\nswap,swap\n?,x|,,\ntrue,-2,|50",
      y =
      "y\ny|,,\n,-1,|10&y\nswap,swap\n?,y|,,\ntrue,-2,|50&y,x\ncontrol,cnot_x\ny|,,\ntrue,,\n,-2,|90&y,z\ncnot_x,control\ny|,,\ntrue,,\n,-2,|90",
      z =
      "z\nz|,,\n,-1,|10&z,z\ncontrol,cnot_x\n?,z|,,\ntrue,,\ntrue,-2,|90&z\ncontrol,cnot_x\nz|,,\n,-2,|80&z\nswap,swap\n?,z|,,\ntrue,-2,|50",
      s =
      "s\ns|,,z\n,-1,|10&s\nx\ns|,,x\n,-1,\n,-2,|20&s\ny\ns|,,y\n,-1,\n,-2,|20&s\nz\ns|,,\n,-1,\n,-2,|20&s\nswap,swap\n?,s|,,z\ntrue,-2,|50&s\nx\nswap,swap\n?,s|,,x\n,-1,\ntrue,-3,|60&s\ny\nswap,swap\n?,s|,,y\n,-1,\ntrue,-3,|60&s\nz\nswap,swap\n?,s|,,\n,-1,\ntrue,-3,|60&s\nswap,swap\n?,x\n?,s|,,x\ntrue,-2,\ntrue,-3,|60&s\nswap,swap\n?,y\n?,s|,,y\ntrue,-2,\ntrue,-3,|60&s\nswap,swap\n?,z\n?,s|,,\ntrue,-2,\ntrue,-3,|60",
      t =
      "t\nt|,,s\n,-1,|10&t\ns\nt|,,z\n,-1,\n,-2,|20&t\nswap,swap\n?,t|,,s\ntrue,-2,|50&t\nz\ns\nt|,,\n,-1,\n,-2,\n,-3,|30&t\ns\nz\nt|,,\n,-1,\n,-2,\n,-3,|30&t\ns\nswap,swap\n?,t|,,z\n,-1,\ntrue,-3,|60&t\nswap,swap\n?,s\n?,t|,,z\ntrue,-2,\ntrue,-3,|60&t\nswap,swap\n?,z\n?,s\n?,t|,,\ntrue,-2,\ntrue,-3,\ntrue,-4,|70&t\nswap,swap\n?,s\n?,z\n?,t|,,\ntrue,-2,\ntrue,-3,\ntrue,-4,|70&t\nz\nswap,swap\n?,s\n?,t|,,\n,-1,\ntrue,-3,\ntrue,-4,|70&t\ns\nswap,swap\n?,z\n?,t|,,\n,-1,\ntrue,-3,\ntrue,-4,|70&t\nz\ns\nswap,swap\n?,t|,,\n,-1,\n,-2,\ntrue,-4,|70&t\ns\nz\nswap,swap\n?,t|,,\n,-1,\n,-2,\ntrue,-4,|70",
      control = "control,cnot_x\nswap,swap\ncnot_x,control|,,\ntrue,,\n,-2,\ntrue,-2,|200",
      cnot_x =
      "cnot_x,control\ncnot_x,control|,,\ntrue,,\n,-1,\ntrue,-1,|40&cnot_x,control\ncontrol,cnot_x\ncnot_x,control|,,swap\ntrue,,swap\n,-1,\ntrue,-1,\n,-2,\ntrue,-2,|100",
      swap = "swap,swap\nswap,swap|,,\ntrue,,\n,-1,\ntrue,-1,|300"
    },
  function(gate_rules)
    return transform(
      split(gate_rules, "&"),
      function(each)
        local pattern, reduce_to, score = unpack_split(each, "|")

        return {
          transform(split(pattern, "\n"), split),
          transform(split(reduce_to, "\n"), function(to)
            local dx, dy, block_type = unpack_split(to)
            return {
              dx = dx ~= "",
              dy = tonum(dy) or 0,
              block_type = block_type == "" and 'i' or block_type
            }
          end),
          score
        }
      end
    )
  end
)
